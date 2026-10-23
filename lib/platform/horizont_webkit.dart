import 'package:flutter/services.dart';

/// Dart side of the Kotlin bridge (`HorizontWebKitPlugin`, PLAN 4.5). It finds
/// the native `WebView` of a controller by the identifier the plugin
/// exposes. In milestone 2 it only answers what the platform supports; the
/// profile, download and request calls come with their milestones.
abstract final class HorizontWebKit {
  static const _channel = MethodChannel('at.haiden.horizont/webkit');

  /// What the native side sees for the `WebView` with [identifier]: whether
  /// it was found, the class of its `WebViewClient`, and which `androidx.webkit`
  /// features this device supports. Null where the bridge is not there.
  static Future<Map<String, Object?>?> probe(int identifier) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>('probe', {
        'identifier': identifier,
      });
      return result;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Makes the native view run [script] in every page before the page's own
  /// scripts. False where the device does not support it.
  static Future<bool> addDocumentStartScript(
    int identifier,
    String script,
  ) async {
    try {
      return await _channel.invokeMethod<bool>('addDocumentStartScript', {
            'identifier': identifier,
            'script': script,
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// The average colour of the top rows of the native view as 0xAARRGGBB;
  /// null when it cannot be captured.
  static Future<int?> captureTop(int identifier) async {
    try {
      return await _channel.invokeMethod<int>('captureTop', {
        'identifier': identifier,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// A picture of what the native view shows, scaled to [width] pixels wide,
  /// as WebP; null when it cannot be captured.
  static Future<Uint8List?> capture(int identifier, int width) async {
    try {
      return await _channel.invokeMethod<Uint8List>('capture', {
        'identifier': identifier,
        'width': width,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
