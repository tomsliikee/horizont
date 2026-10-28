import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../platform/horizont_webkit.dart';
import 'downloads/file_name.dart';
import 'status_bar/page_message.dart';
import 'web_engine.dart';

/// How a new [WebViewEngine] is set up.
@immutable
class EngineOptions {
  const EngineOptions({
    this.profile,
    this.blocking = true,
    this.safeBrowsing = true,
    this.httpsOnly = _always,
  });

  /// The `androidx.webkit` profile; private tabs use their own (PLAN 4.4).
  final String? profile;
  final bool blocking;
  final bool safeBrowsing;

  /// Read on every navigation, so the setting applies at once.
  final bool Function() httpsOnly;

  static bool _always() => true;
}

/// [WebEngine] over `webview_flutter`.
class WebViewEngine implements WebEngine {
  WebViewEngine([this.options = const EngineOptions()])
    : _controller = WebViewController() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'HorizontPage',
        onMessageReceived: (message) {
          final parsed = PageMessage.parse(message.message);
          if (parsed != null) _messages.add(parsed);
        },
      )
      ..addJavaScriptChannel('HorizontBlob', onMessageReceived: _onBlobChunk)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (url) {
            _set(
              _state.value.copyWith(
                loading: true,
                progress: 0,
                clearError: true,
                reader: false,
              ),
              url: url,
            );
            unawaited(_injectScript());
          },
          onProgress: (percent) =>
              _set(_state.value.copyWith(progress: percent / 100)),
          onUrlChange: (change) => _set(_state.value, url: change.url),
          onPageFinished: (url) async {
            unawaited(_injectScript());
            _set(_state.value.copyWith(loading: false, progress: 1), url: url);
            _restoreScroll();
            final title = await _controller.getTitle();
            _set(_state.value.copyWith(title: title ?? ''));
          },
          onWebResourceError: _onError,
          onSslAuthError: (error) {
            unawaited(error.cancel());
            final url = _state.value.url ?? _lastRequested;
            if (url != null) {
              _set(
                _state.value.copyWith(
                  loading: false,
                  error: PageError(
                    PageErrorKind.certificate,
                    url,
                    description: error.platform.description,
                  ),
                ),
              );
            }
          },
          onHttpAuthRequest: (request) {
            final event = HttpAuthEvent(request.host, request.realm);
            _request(event, () => event.answer.complete(null));
            unawaited(
              event.answer.future.then((pair) {
                if (pair == null) {
                  request.onCancel();
                } else {
                  request.onProceed(
                    WebViewCredential(user: pair.$1, password: pair.$2),
                  );
                }
              }),
            );
          },
        ),
      );
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      _configureAndroid(platform);
    }
    _bridgeSub = HorizontWebKit.events.listen(_onBridge);
    _ready = _setup();
  }

  /// Hybrid Composition scrolls evenly at 120 Hz on the Pixel 10 Pro; Texture
  /// Layer Hybrid Composition mixed in long stretches at 60 Hz (M3, measured
  /// on a Wikipedia article, `docs/spikes.md`). `--dart-define=HYBRID=false`
  /// switches back (R1).
  static const hybridComposition = bool.fromEnvironment(
    'HYBRID',
    defaultValue: true,
  );

  final EngineOptions options;
  final WebViewController _controller;
  final _state = ValueNotifier(const PageState());
  final _events = StreamController<EngineEvent>.broadcast();
  final _messages = StreamController<PageMessage>.broadcast();
  late final StreamSubscription<BridgeEvent> _bridgeSub;
  late final Future<void> _ready;
  static Future<String>? _script;
  static Future<String>? _readerScript;
  String? _defaultUserAgent;

  /// Where the next finished load scrolls to, set by [load].
  double _pendingScrollY = 0;

  /// The address HTTPS-only turned an `http:` request into.
  Uri? _upgraded;
  final _insecureHosts = <String>{};
  Uri? _lastRequested;

  @override
  ValueListenable<PageState> get state => _state;

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Stream<PageMessage> get messages => _messages.stream;

  @override
  Future<void> get ready => _ready;

  static Future<String> get _pageScript =>
      _script ??= rootBundle.loadString('assets/js/horizont_page.js');

  static Future<String> get _reader => _readerScript ??= () async {
    final parts = await Future.wait([
      rootBundle.loadString('assets/js/readability.js'),
      rootBundle.loadString('assets/js/horizont_reader.js'),
    ]);
    return '${parts[0]}\n;${parts[1]}';
  }();

  void _configureAndroid(AndroidWebViewController platform) {
    // Flutter already places the view below the status bar; without this
    // Android 15+ pads the page a second time (PLAN 5.3).
    unawaited(
      platform.setInsetsForWebContentToIgnore(const [
        AndroidWebViewInsets.systemBars,
        AndroidWebViewInsets.displayCutout,
      ]),
    );
    unawaited(platform.setMediaPlaybackRequiresUserGesture(true));
    unawaited(platform.setGeolocationEnabled(true));
    unawaited(
      platform.setWebAuthenticationSupport(WebAuthenticationSupport.forBrowser),
    );
    unawaited(
      platform.setOnJavaScriptAlertDialog((request) async {
        final event = JsDialogEvent(JsDialogKind.alert, request.message);
        _request(event, () => event.answer.complete(null));
        await event.answer.future;
      }),
    );
    unawaited(
      platform.setOnJavaScriptConfirmDialog((request) async {
        final event = JsDialogEvent(JsDialogKind.confirm, request.message);
        _request(event, () => event.answer.complete(false));
        return await event.answer.future == true;
      }),
    );
    unawaited(
      platform.setOnJavaScriptTextInputDialog((request) async {
        final event = JsDialogEvent(
          JsDialogKind.prompt,
          request.message,
          defaultText: request.defaultText ?? '',
        );
        _request(event, () => event.answer.complete(null));
        final answer = await event.answer.future;
        return answer is String ? answer : '';
      }),
    );
    unawaited(
      platform.setOnShowFileSelector((params) async {
        final event = FileChooserEvent(
          params.acceptTypes,
          multiple: params.mode == FileSelectorMode.openMultiple,
        );
        _request(event, () => event.answer.complete(const []));
        return event.answer.future;
      }),
    );
    unawaited(
      platform.setOnPlatformPermissionRequest((request) async {
        final kinds = <SitePermissionKind>{
          for (final t in request.types)
            if (t == WebViewPermissionResourceType.camera)
              SitePermissionKind.camera
            else if (t == WebViewPermissionResourceType.microphone)
              SitePermissionKind.microphone,
        };
        if (kinds.isEmpty) {
          await request.deny();
          return;
        }
        final event = PermissionEvent(_origin(), kinds);
        _request(event, () => event.answer.complete(false));
        if (await event.answer.future) {
          await request.grant();
        } else {
          await request.deny();
        }
      }),
    );
    unawaited(
      platform.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (params) async {
          final event = PermissionEvent(params.origin, const {
            SitePermissionKind.location,
          });
          _request(event, () => event.answer.complete(false));
          final allow = await event.answer.future;
          return GeolocationPermissionsResponse(allow: allow, retain: false);
        },
      ),
    );
    unawaited(
      platform.setCustomWidgetCallbacks(
        onShowCustomWidget: (widget, hidden) =>
            _events.add(FullscreenEvent(widget, hidden)),
        onHideCustomWidget: () => _events.add(const FullscreenExitEvent()),
      ),
    );
  }

  String _origin() {
    final url = _state.value.url;
    return url == null ? '' : '${url.scheme}://${url.authority}';
  }

  /// Sends a request to the UI; with nobody listening (a tab in the
  /// background) it gets the safe answer at once.
  void _request(EngineEvent event, VoidCallback fallback) {
    if (_events.hasListener) {
      _events.add(event);
    } else {
      fallback();
    }
  }

  /// The fallback when the bridge cannot add the script at document start:
  /// the script guards against running twice.
  Future<void> _injectScript() async {
    try {
      await _controller.runJavaScript(await _pageScript);
    } on Object catch (e) {
      debugPrint('page script not injected: $e');
    }
  }

  /// The id the Kotlin bridge uses to find the native `WebView`; null off
  /// Android.
  int? get nativeId {
    final platform = _controller.platform;
    return platform is AndroidWebViewController
        ? platform.webViewIdentifier
        : null;
  }

  /// Prepares the native view before the first load: the profile first
  /// (R3), then the page script at document start, blocking and listeners.
  Future<void> _setup() async {
    final id = nativeId;
    if (id == null) return;
    final result = await HorizontWebKit.setup(
      id,
      profile: options.profile,
      script: await _pageScript,
      blocking: options.blocking,
      safeBrowsing: options.safeBrowsing,
    );
    debugPrint('bridge setup: $result');
  }

  void _onBridge(BridgeEvent event) {
    final id = nativeId;
    if (id == null || event.identifier != id) return;
    switch (event) {
      case FindEvent(:final active, :final count, :final done):
        if (done || count > 0) {
          _events.add(FindResultEvent(count == 0 ? 0 : active + 1, count));
        }
      case DownloadEvent():
        unawaited(_onDownload(event));
      case NewWindowEvent(:final url):
        final uri = Uri.tryParse(url);
        if (uri != null) _events.add(NewTabEvent(uri));
      case BlockedEvent(:final pageHost):
        _events.add(TrackersBlockedEvent(pageHost ?? '', event.total));
      case RenderGoneEvent():
        _events.add(const PageCrashedEvent());
      case OpenUrlEvent() || LiveActionEvent():
        break;
    }
  }

  Future<void> _onDownload(DownloadEvent event) async {
    final url = Uri.tryParse(event.url);
    if (url == null) return;
    final name = downloadFileName(
      url: url,
      contentDisposition: event.contentDisposition,
      mimeType: event.mimeType,
    );
    if (url.scheme == 'data') {
      final data = UriData.fromUri(url);
      _events.add(
        DownloadRequestEvent(
          url: url,
          fileName: name,
          mimeType: data.mimeType,
          size: null,
          userAgent: event.userAgent,
          cookies: null,
          referer: _state.value.url,
          bytes: data.contentAsBytes(),
        ),
      );
      return;
    }
    if (url.scheme == 'blob') {
      _pendingBlob = (token: _blobToken++, name: name, url: url);
      final token = _pendingBlob!.token;
      await _controller.runJavaScript('''
(function(){
  var ch = window.HorizontBlob; if (!ch) return;
  fetch(${jsonEncode(event.url)}).then(function(r){return r.blob();}).then(function(b){
    var size = 393216, n = Math.max(1, Math.ceil(b.size / size)), i = 0;
    function next(){
      if (i >= n) return;
      var reader = new FileReader();
      reader.onload = function(){
        var d = String(reader.result); d = d.substring(d.indexOf(',') + 1);
        ch.postMessage(JSON.stringify({t: $token, i: i, n: n, m: b.type, d: d}));
        i++; next();
      };
      reader.readAsDataURL(b.slice(i * size, (i + 1) * size));
    }
    next();
  }).catch(function(){ ch.postMessage(JSON.stringify({t: $token, i: -1})); });
})();''');
      return;
    }
    _events.add(
      DownloadRequestEvent(
        url: url,
        fileName: name,
        mimeType: event.mimeType,
        size: event.contentLength > 0 ? event.contentLength : null,
        userAgent: event.userAgent,
        cookies: event.cookies,
        referer: _state.value.url,
      ),
    );
  }

  ({int token, String name, Uri url})? _pendingBlob;
  var _blobToken = 1;
  final _blobParts = <int, String>{};

  /// A part of a `blob:` download, sent by the script above. Pages can call
  /// the channel too, so only the expected token is taken.
  void _onBlobChunk(JavaScriptMessage message) {
    final pending = _pendingBlob;
    if (pending == null) return;
    final Object? json;
    try {
      json = jsonDecode(message.message);
    } on FormatException {
      return;
    }
    if (json is! Map || json['t'] != pending.token) return;
    final i = json['i'];
    if (i is! int || i < 0) {
      _pendingBlob = null;
      _blobParts.clear();
      return;
    }
    final n = json['n'];
    final d = json['d'];
    if (n is! int || d is! String || n > 4096) return;
    _blobParts[i] = d;
    if (_blobParts.length < n) return;
    final builder = BytesBuilder(copy: false);
    for (var k = 0; k < n; k++) {
      final part = _blobParts[k];
      if (part == null) return;
      builder.add(base64Decode(part));
    }
    _pendingBlob = null;
    _blobParts.clear();
    final mime = json['m'] is String ? json['m'] as String : '';
    _events.add(
      DownloadRequestEvent(
        url: pending.url,
        fileName: pending.name == 'download'
            ? downloadFileName(url: pending.url, mimeType: mime)
            : pending.name,
        mimeType: mime,
        size: builder.length,
        userAgent: '',
        cookies: null,
        referer: _state.value.url,
        bytes: builder.takeBytes(),
      ),
    );
  }

  void _onError(WebResourceError error) {
    if (error.isForMainFrame == false) return;
    final url = Uri.tryParse(error.url ?? '') ?? _lastRequested;
    if (url == null) return;
    final type = error.errorType;
    if (_upgraded != null && url.host == _upgraded!.host) {
      _set(
        _state.value.copyWith(
          loading: false,
          error: PageError(
            PageErrorKind.insecure,
            _upgraded!.replace(scheme: 'http'),
          ),
        ),
      );
      _upgraded = null;
      return;
    }
    final kind = switch (type) {
      WebResourceErrorType.hostLookup ||
      WebResourceErrorType.connect ||
      WebResourceErrorType.timeout ||
      WebResourceErrorType.io => PageErrorKind.offline,
      WebResourceErrorType.failedSslHandshake => PageErrorKind.certificate,
      WebResourceErrorType.unsupportedScheme ||
      WebResourceErrorType.unknown ||
      null => null,
      _ => PageErrorKind.failed,
    };
    if (kind == null) return;
    _set(
      _state.value.copyWith(
        loading: false,
        error: PageError(kind, url, description: error.description),
      ),
    );
  }

  @override
  Future<void> scrollToTop() => _controller.runJavaScript(
    'window.__horizontPage ? window.__horizontPage.scrollToTop() : window.scrollTo(0, 0)',
  );

  @override
  Future<List<Color>?> sampleTop() async {
    final id = nativeId;
    final argb = id == null ? null : await HorizontWebKit.captureTop(id);
    if (argb == null || argb.isEmpty) return null;
    return [for (final v in argb) Color(v)];
  }

  @override
  Widget buildView() {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: platform,
          displayWithHybridComposition: hybridComposition,
        ),
      );
    }
    return WebViewWidget(controller: _controller);
  }

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null || !request.isMainFrame) return NavigationDecision.navigate;
    if (uri.scheme == 'http' &&
        options.httpsOnly() &&
        !_insecureHosts.contains(uri.host) &&
        !_isLocal(uri.host)) {
      final secure = uri.replace(
        scheme: 'https',
        port: uri.hasPort && uri.port != 80 ? uri.port : null,
      );
      _upgraded = secure;
      unawaited(_controller.loadRequest(secure));
      return NavigationDecision.prevent;
    }
    const allowed = {'http', 'https', 'about', 'data', 'blob', 'file'};
    if (allowed.contains(uri.scheme)) {
      if (uri.scheme == 'https' && _upgraded?.host != uri.host) {
        _upgraded = null;
      }
      return NavigationDecision.navigate;
    }
    _events.add(ExternalLinkEvent(uri));
    return NavigationDecision.prevent;
  }

  static bool _isLocal(String host) =>
      host == 'localhost' ||
      RegExp(r'^(?:\d{1,3}\.){3}\d{1,3}$').hasMatch(host) ||
      host.endsWith('.local');

  /// Records [url] and refreshes back/forward, which only the web view knows.
  void _set(PageState next, {String? url}) {
    var state = next;
    if (url != null) {
      final uri = Uri.tryParse(url);
      // about:blank is the empty tab: the start page shows instead.
      state = uri == null || uri.scheme == 'about'
          ? state.copyWith(clearUrl: true, title: '')
          : state.copyWith(url: uri);
    }
    if (_disposed) return;
    _state.value = state;
    unawaited(_refreshHistory());
  }

  var _disposed = false;

  Future<void> _refreshHistory() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    if (_disposed) return;
    if (_state.value.canGoBack != back ||
        _state.value.canGoForward != forward) {
      _state.value = _state.value.copyWith(
        canGoBack: back,
        canGoForward: forward,
      );
    }
  }

  @override
  Future<void> load(Uri uri, {double scrollY = 0}) async {
    await _ready;
    _pendingScrollY = scrollY;
    _lastRequested = uri;
    return _controller.loadRequest(uri);
  }

  /// Scrolls to the position a restored tab had. Pages lay out late, so it is
  /// done again shortly after.
  void _restoreScroll() {
    final y = _pendingScrollY;
    if (y <= 0) return;
    _pendingScrollY = 0;
    Future<void> scroll() =>
        _controller.runJavaScript('window.scrollTo(0, $y)');
    unawaited(scroll());
    Timer(const Duration(milliseconds: 300), () => unawaited(scroll()));
  }

  @override
  Future<double> readScrollY() async {
    // A page that has not been scrolled to its stored place yet is still
    // "at" that place; asking it now would answer 0.
    if (_pendingScrollY > 0) return _pendingScrollY;
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'window.__horizontPage ? window.__horizontPage.scrollY() : window.scrollY',
      );
      return double.tryParse(result.toString()) ?? 0;
    } on Object {
      return 0;
    }
  }

  @override
  Future<Uint8List?> captureThumbnail(int width) async {
    final id = nativeId;
    return id == null ? null : HorizontWebKit.capture(id, width);
  }

  @override
  Future<void> loadAsset(String key) async {
    await _ready;
    return _controller.loadFlutterAsset(key);
  }

  @override
  Future<void> loadFile(String path) async {
    await _ready;
    return _controller.loadFile(path);
  }

  @override
  Future<void> goBack() => _controller.goBack();

  @override
  Future<void> goForward() => _controller.goForward();

  @override
  Future<void> reload() {
    final error = _state.value.error;
    if (error != null) {
      _set(_state.value.copyWith(clearError: true));
      return _controller.loadRequest(error.url);
    }
    return _controller.reload();
  }

  @override
  Future<void> revealFocusedField() => _controller.runJavaScript(
    // Only a field of the page; the body is "focused" when nothing is.
    "(function(){var e=document.activeElement;"
    "if(e&&(/^(INPUT|TEXTAREA|SELECT)\$/.test(e.tagName)||e.isContentEditable))"
    "e.scrollIntoView({block:'center'});})()",
  );

  @override
  Future<void> goToStart() => _controller.loadRequest(Uri.parse('about:blank'));

  @override
  Future<void> setTextZoom(int percent) async {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setTextZoom(percent.clamp(50, 200));
    }
  }

  @override
  Future<void> setDesktopMode(bool on) async {
    _defaultUserAgent ??= await _controller.getUserAgent();
    final mobile = _defaultUserAgent ?? '';
    final desktop = mobile
        .replaceFirst(
          RegExp(r'\(Linux; Android [^)]*\)'),
          '(X11; Linux x86_64)',
        )
        .replaceAll(' Mobile', '');
    await _controller.setUserAgent(on ? desktop : null);
    final id = nativeId;
    if (id != null) await HorizontWebKit.setDesktopMode(id, on: on);
    _set(_state.value.copyWith(desktop: on));
    if (_state.value.url != null) await _controller.reload();
  }

  @override
  Future<void> find(String text) async {
    final id = nativeId;
    if (id == null) return;
    if (text.isEmpty) {
      await HorizontWebKit.clearMatches(id);
      _events.add(const FindResultEvent(0, 0));
    } else {
      await HorizontWebKit.find(id, text);
    }
  }

  @override
  Future<void> findNext({bool forward = true}) async {
    final id = nativeId;
    if (id != null) await HorizontWebKit.findNext(id, forward: forward);
  }

  @override
  Future<void> clearFind() async {
    final id = nativeId;
    if (id != null) await HorizontWebKit.clearMatches(id);
  }

  @override
  Future<bool> setReader(bool on, {ReaderStyle? style}) async {
    try {
      if (on) {
        await _controller.runJavaScript(await _reader);
        String hex(Color c) =>
            '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
        final s = style!;
        final args = jsonEncode({
          'background': hex(s.background),
          'text': hex(s.text),
          'muted': hex(s.muted),
          'accent': hex(s.accent),
          'zoom': s.textZoom,
        });
        final result = await _controller.runJavaScriptReturningResult(
          'window.__horizontReader(true, $args)',
        );
        final ok = result == true || result.toString() == 'true';
        if (ok) _set(_state.value.copyWith(reader: true));
        return ok;
      }
      await _controller.runJavaScript(
        'window.__horizontReader && window.__horizontReader(false)',
      );
      _set(_state.value.copyWith(reader: false));
      return true;
    } on Object catch (e) {
      debugPrint('reader failed: $e');
      return false;
    }
  }

  @override
  Future<PageInfo> readPageInfo() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'window.__horizontPage ? window.__horizontPage.info() : "{}"',
      );
      var raw = result.toString();
      // Android hands strings back JSON-encoded.
      if (raw.startsWith('"')) raw = jsonDecode(raw) as String;
      final map = jsonDecode(raw);
      if (map is! Map) return const PageInfo();
      final w = map['w'];
      final f = map['f'];
      return PageInfo(
        words: w is num ? w.toInt() : 0,
        readFraction: f is num ? f.toDouble().clamp(0, 1) : 0,
      );
    } on Object {
      return const PageInfo();
    }
  }

  @override
  Future<String?> saveArchive(String path) async {
    final id = nativeId;
    return id == null ? null : HorizontWebKit.saveWebArchive(id, path);
  }

  @override
  Future<void> setProtection({
    required bool blocking,
    required bool safe,
  }) async {
    final id = nativeId;
    if (id == null) return;
    await HorizontWebKit.setBlocking(id, on: blocking);
    await HorizontWebKit.setSafeBrowsing(id, on: safe);
  }

  @override
  Future<void> continueInsecure(Uri url) async {
    _insecureHosts.add(url.host);
    _set(_state.value.copyWith(clearError: true));
    await _controller.loadRequest(url.replace(scheme: 'http'));
  }

  @override
  void dispose() {
    _disposed = true;
    final id = nativeId;
    if (id != null) unawaited(HorizontWebKit.release(id));
    unawaited(_bridgeSub.cancel());
    // Stop media and timers of a view that is going away.
    unawaited(_controller.loadRequest(Uri.parse('about:blank')));
    _state.dispose();
    unawaited(_events.close());
    unawaited(_messages.close());
  }
}
