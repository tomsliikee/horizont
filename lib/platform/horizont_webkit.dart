import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Something the native side reports about one web view, or about the app
/// (a link from another app).
sealed class BridgeEvent {
  const BridgeEvent(this.identifier);

  /// The web view it concerns; null for app-wide events.
  final int? identifier;
}

/// Find in page: match [active] (0-based) of [count].
class FindEvent extends BridgeEvent {
  const FindEvent(super.identifier, this.active, this.count, this.done);
  final int active;
  final int count;
  final bool done;
}

/// The page wants to download a file.
class DownloadEvent extends BridgeEvent {
  const DownloadEvent(
    super.identifier, {
    required this.url,
    required this.userAgent,
    required this.contentDisposition,
    required this.mimeType,
    required this.contentLength,
    required this.cookies,
  });
  final String url;
  final String userAgent;
  final String contentDisposition;
  final String mimeType;
  final int contentLength;
  final String? cookies;
}

/// `window.open` or `target=_blank`: [url] wants a new tab.
class NewWindowEvent extends BridgeEvent {
  const NewWindowEvent(super.identifier, this.url, this.userGesture);
  final String url;
  final bool userGesture;
}

/// Tracker requests blocked on [pageHost] since the last report.
class BlockedEvent extends BridgeEvent {
  const BlockedEvent(super.identifier, this.pageHost, this.counts);
  final String? pageHost;
  final Map<String, int> counts;
  int get total => counts.values.fold(0, (a, b) => a + b);
}

/// The renderer of the view died; the page must be loaded again.
class RenderGoneEvent extends BridgeEvent {
  const RenderGoneEvent(super.identifier);
}

/// Another app asked Horizont to open [url] (default browser, D19, or a
/// pinned shortcut).
class OpenUrlEvent extends BridgeEvent {
  const OpenUrlEvent(this.url) : super(null);
  final String url;
}

/// A button of an ongoing notification was tapped.
class LiveActionEvent extends BridgeEvent {
  const LiveActionEvent(this.id, this.action, this.payload) : super(null);
  final int id;
  final String action;
  final String payload;
}

/// Dart side of the Kotlin bridge (`HorizontWebKitPlugin`, PLAN 4.5). It finds
/// the native `WebView` of a controller by the identifier the plugin exposes.
/// Every call answers a harmless default where the bridge is missing (tests,
/// other platforms).
/// The device has no speech recognition to search with.
class VoiceUnavailable implements Exception {
  const VoiceUnavailable();
}

abstract final class HorizontWebKit {
  static const _channel = MethodChannel('at.haiden.horizont/webkit');
  static final _events = StreamController<BridgeEvent>.broadcast();
  static var _listening = false;

  /// What the native side reports, for every web view.
  static Stream<BridgeEvent> get events {
    if (!_listening) {
      _listening = true;
      _channel.setMethodCallHandler(_onCall);
    }
    return _events.stream;
  }

  static Future<Object?> _onCall(MethodCall call) async {
    final args = call.arguments;
    if (args is! Map) return null;
    final id = (args['identifier'] as num?)?.toInt();
    final event = switch (call.method) {
      'onFind' => FindEvent(
        id,
        (args['active'] as num?)?.toInt() ?? 0,
        (args['count'] as num?)?.toInt() ?? 0,
        args['done'] == true,
      ),
      'onDownload' => DownloadEvent(
        id,
        url: args['url'] as String? ?? '',
        userAgent: args['userAgent'] as String? ?? '',
        contentDisposition: args['contentDisposition'] as String? ?? '',
        mimeType: args['mimeType'] as String? ?? '',
        contentLength: (args['contentLength'] as num?)?.toInt() ?? -1,
        cookies: args['cookies'] as String?,
      ),
      'onNewWindow' => NewWindowEvent(
        id,
        args['url'] as String? ?? '',
        args['userGesture'] == true,
      ),
      'onBlocked' => BlockedEvent(id, args['pageHost'] as String?, {
        for (final e in ((args['counts'] as Map?) ?? const {}).entries)
          if (e.key is String && e.value is num)
            e.key as String: (e.value as num).toInt(),
      }),
      'onRenderGone' => RenderGoneEvent(id),
      'onOpenUrl' => OpenUrlEvent(args['url'] as String? ?? ''),
      'onLiveAction' => LiveActionEvent(
        (args['id'] as num?)?.toInt() ?? 0,
        args['action'] as String? ?? '',
        args['payload'] as String? ?? '',
      ),
      _ => null,
    };
    if (event != null) _events.add(event);
    return null;
  }

  static Future<T?> _call<T>(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('bridge $method failed: ${e.message}');
      return null;
    }
  }

  /// What the native side sees for the `WebView` with [identifier].
  static Future<Map<String, Object?>?> probe(int identifier) async {
    try {
      return await _channel.invokeMapMethod<String, Object?>('probe', {
        'identifier': identifier,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Prepares a new view before its first load: the [profile] (private
  /// mode), the page [script] at document start, request blocking, Safe
  /// Browsing, new windows, find and download listeners. Answers whether the
  /// profile and the script were set.
  static Future<({bool found, bool profile, bool script})> setup(
    int identifier, {
    String? profile,
    String? script,
    bool blocking = false,
    bool safeBrowsing = true,
  }) async {
    final result = await _call<Map<Object?, Object?>>('setup', {
      'identifier': identifier,
      'profile': profile,
      'script': script,
      'blocking': blocking,
      'safeBrowsing': safeBrowsing,
    });
    return (
      found: result?['found'] == true,
      profile: result?['profile'] == true,
      script: result?['script'] == true,
    );
  }

  static Future<void> release(int identifier) =>
      _call<void>('release', {'identifier': identifier});

  /// The colours along the top of the native view, left to right, as
  /// 0xAARRGGBB; each is the average of the top rows of its column.
  static Future<List<int>?> captureTop(int identifier) async {
    final raw = await _call<List<dynamic>>('captureTop', {
      'identifier': identifier,
    });
    if (raw == null) return null;
    return [
      for (final v in raw)
        if (v is int) v & 0xFFFFFFFF,
    ];
  }

  /// A picture of what the native view shows, [width] pixels wide, as WebP.
  static Future<Uint8List?> capture(int identifier, int width) =>
      _call<Uint8List>('capture', {'identifier': identifier, 'width': width});

  static Future<void> find(int identifier, String text) =>
      _call<void>('find', {'identifier': identifier, 'text': text});

  static Future<void> findNext(int identifier, {required bool forward}) =>
      _call<void>('findNext', {'identifier': identifier, 'forward': forward});

  static Future<void> clearMatches(int identifier) =>
      _call<void>('clearMatches', {'identifier': identifier});

  static Future<void> setDesktopMode(int identifier, {required bool on}) =>
      _call<void>('setDesktopMode', {'identifier': identifier, 'on': on});

  static Future<void> setBlocking(int identifier, {required bool on}) =>
      _call<void>('setBlocking', {'identifier': identifier, 'on': on});

  static Future<void> setSafeBrowsing(int identifier, {required bool on}) =>
      _call<void>('setSafeBrowsing', {'identifier': identifier, 'on': on});

  /// Makes pages see the app's light/dark choice as `prefers-color-scheme`
  /// (R6): `light`, `dark` or `system`.
  static Future<void> setNightMode(String mode) =>
      _call<void>('setNightMode', {'mode': mode});

  /// Saves the page as a web archive at [path]; the saved path or null.
  static Future<String?> saveWebArchive(int identifier, String path) =>
      _call<String>('saveWebArchive', {'identifier': identifier, 'path': path});

  /// The cookies the web view would send to [url], for downloads.
  static Future<String?> cookies(String url) =>
      _call<String>('cookies', {'url': url});

  /// Empties the cookies and storage of the profile [name].
  static Future<void> clearProfile(String name) =>
      _call<void>('clearProfile', {'name': name});

  /// Deletes profiles starting with [prefix] except [keep] (old private
  /// sessions). Profiles still in use stay until the next start.
  static Future<int> deleteProfiles(String prefix, {String? keep}) async =>
      await _call<int>('deleteProfiles', {'prefix': prefix, 'keep': keep}) ?? 0;

  /// Deletes cookies, storage and the cache of the default profile.
  static Future<void> clearAllData(int? identifier) =>
      _call<void>('clearAllData', {'identifier': identifier});

  static Future<bool> share(String text, {String? subject}) async =>
      await _call<bool>('share', {'text': text, 'subject': subject}) ?? false;

  /// Hands [uri] to another app; [fallback] is the page's fallback address
  /// when no app took it.
  static Future<({bool opened, String? fallback})> openExternal(
    String uri,
  ) async {
    final r = await _call<Map<Object?, Object?>>('openExternal', {'uri': uri});
    return (opened: r?['opened'] == true, fallback: r?['fallback'] as String?);
  }

  /// Asks the launcher to pin a shortcut to [url]; false where it cannot.
  static Future<bool> pinShortcut({
    required String url,
    required String title,
    required String letter,
    required int background,
    required int foreground,
  }) async =>
      await _call<bool>('pinShortcut', {
        'url': url,
        'title': title,
        'letter': letter,
        'background': background,
        'foreground': foreground,
      }) ??
      false;

  static Future<bool> openPasswordSettings() async =>
      await _call<bool>('openPasswordSettings') ?? false;

  static Future<bool> openDefaultBrowserSettings() async =>
      await _call<bool>('openDefaultBrowserSettings') ?? false;

  /// Asks Android for runtime [permissions]; which were granted.
  static Future<Map<String, bool>> requestPermissions(
    List<String> permissions,
  ) async {
    final r = await _call<Map<Object?, Object?>>('requestPermissions', {
      'permissions': permissions,
    });
    return {for (final p in permissions) p: r?[p] == true};
  }

  /// Vibrates for [kind] (a `Haptic` name); [strong] composes it harder.
  static Future<void> haptic(String kind, {required bool strong}) =>
      _call<void>('haptic', {'kind': kind, 'strong': strong});

  /// Scans a QR code with the Play services scanner; its text, or null.
  static Future<String?> scanQr() => _call<String>('scanQr');

  /// Asks the system's speech recognition for a search; the words, or null
  /// when cancelled. Throws [VoiceUnavailable] when the device has none.
  static Future<String?> voiceSearch() async {
    try {
      return await _channel.invokeMethod<String>('voiceSearch');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      if (e.code == 'unavailable') throw const VoiceUnavailable();
      return null;
    }
  }

  /// Whether the clipboard holds a link, without reading it.
  static Future<bool> clipHasLink() async =>
      await _call<bool>('clipHasLink') ?? false;

  /// The clipboard's text; Android tells the user it was read.
  static Future<String?> clipText() => _call<String>('clipText');

  /// The address the app was started with by another app, once.
  static Future<String?> initialUrl() => _call<String>('initialUrl');

  /// Shows or updates an ongoing notification with progress (a Live Update on
  /// Android 16 and newer). [progress] is 0 to 100, negative while unknown;
  /// [actions] are (label, action name) pairs reported as [LiveActionEvent].
  static Future<void> liveShow({
    required int id,
    required String title,
    required String text,
    required int progress,
    String? chip,
    List<(String, String)> actions = const [],
    String payload = '',
  }) => _call<bool>('liveShow', {
    'id': id,
    'title': title,
    'text': text,
    'progress': progress,
    'chip': chip,
    'actions': [
      for (final (label, action) in actions) [label, action],
    ],
    'payload': payload,
  });

  static Future<void> liveCancel(int id) =>
      _call<void>('liveCancel', {'id': id});
}
