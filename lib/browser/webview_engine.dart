import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../platform/horizont_webkit.dart';
import 'status_bar/page_message.dart';
import 'web_engine.dart';

/// [WebEngine] over `webview_flutter`.
class WebViewEngine implements WebEngine {
  WebViewEngine() : _controller = WebViewController() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'HorizontPage',
        onMessageReceived: (message) {
          final parsed = PageMessage.parse(message.message);
          if (parsed != null) _messages.add(parsed);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (url) {
            _set(_state.value.copyWith(loading: true, progress: 0), url: url);
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
        ),
      );
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      // Flutter already places the view below the status bar; without this
      // Android 15+ pads the page a second time (PLAN 5.3).
      unawaited(
        platform.setInsetsForWebContentToIgnore(const [
          AndroidWebViewInsets.systemBars,
          AndroidWebViewInsets.displayCutout,
        ]),
      );
    }
  }

  /// Hybrid Composition scrolls evenly at 120 Hz on the Pixel 10 Pro; Texture
  /// Layer Hybrid Composition mixed in long stretches at 60 Hz (M3, measured
  /// on a Wikipedia article, `docs/spikes.md`). `--dart-define=HYBRID=false`
  /// switches back (R1).
  static const hybridComposition = bool.fromEnvironment(
    'HYBRID',
    defaultValue: true,
  );

  final WebViewController _controller;
  final _state = ValueNotifier(const PageState());
  final _blocked = StreamController<Uri>.broadcast();
  final _messages = StreamController<PageMessage>.broadcast();
  Future<String>? _script;

  /// Where the next finished load scrolls to, set by [load].
  double _pendingScrollY = 0;

  @override
  ValueListenable<PageState> get state => _state;

  @override
  Stream<Uri> get blockedLinks => _blocked.stream;

  @override
  Stream<PageMessage> get messages => _messages.stream;

  Future<String> get _pageScript =>
      _script ??= rootBundle.loadString('assets/js/horizont_page.js');

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

  /// Asks the Kotlin bridge about this engine's native view (logged for the
  /// M2 spike, `adb logcat -s flutter`) and has it run the page script at
  /// document start, before the page's own scripts.
  Future<void> attachBridge() async {
    final id = nativeId;
    if (id == null) return;
    debugPrint('bridge probe: ${await HorizontWebKit.probe(id)}');
    final ok = await HorizontWebKit.addDocumentStartScript(
      id,
      await _pageScript,
    );
    debugPrint('document start script: $ok');
  }

  @override
  Future<void> scrollToTop() => _controller.runJavaScript(
    'window.__horizontPage ? window.__horizontPage.scrollToTop() : window.scrollTo(0, 0)',
  );

  @override
  Future<Color?> sampleTop() async {
    final id = nativeId;
    final argb = id == null ? null : await HorizontWebKit.captureTop(id);
    return argb == null ? null : Color(argb);
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
    const allowed = {'http', 'https', 'about'};
    if (allowed.contains(uri.scheme)) return NavigationDecision.navigate;
    _blocked.add(uri);
    return NavigationDecision.prevent;
  }

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
    _state.value = state;
    unawaited(_refreshHistory());
  }

  Future<void> _refreshHistory() async {
    final back = await _controller.canGoBack();
    final forward = await _controller.canGoForward();
    if (_state.value.canGoBack != back ||
        _state.value.canGoForward != forward) {
      _state.value = _state.value.copyWith(
        canGoBack: back,
        canGoForward: forward,
      );
    }
  }

  @override
  Future<void> load(Uri uri, {double scrollY = 0}) {
    _pendingScrollY = scrollY;
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
  Future<void> loadAsset(String key) => _controller.loadFlutterAsset(key);

  @override
  Future<void> goBack() => _controller.goBack();

  @override
  Future<void> goForward() => _controller.goForward();

  @override
  Future<void> reload() => _controller.reload();

  @override
  Future<void> revealFocusedField() => _controller.runJavaScript(
    "document.activeElement?.scrollIntoView({block: 'center'})",
  );

  @override
  Future<void> goToStart() => _controller.loadRequest(Uri.parse('about:blank'));

  @override
  void dispose() {
    _state.dispose();
    unawaited(_blocked.close());
    unawaited(_messages.close());
  }
}
