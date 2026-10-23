import 'dart:ui';

import 'page_color.dart';
import 'page_message.dart';

/// Decides which page reports change the tint: small changes are ignored, and
/// the costly capture fallback runs at most once per [sampleInterval].
class PageColorTracker {
  PageColorTracker({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const sampleInterval = Duration(seconds: 1);

  final DateTime Function() _now;
  Color? _color;
  DateTime? _lastSample;

  Color? get color => _color;

  /// Applies a colour report; true when the tint colour changed.
  bool report(ColorMessage message) {
    final next = message.color;
    if (next == null) return false;
    return _set(next);
  }

  /// A colour from a capture of the page top; true when it changed.
  bool reportSample(Color next) => _set(next);

  /// Whether a capture may be taken now. Calling it counts as taking one.
  bool mayTakeSample() {
    final now = _now();
    final last = _lastSample;
    if (last != null && now.difference(last) < sampleInterval) return false;
    _lastSample = now;
    return true;
  }

  bool _set(Color next) {
    final current = _color;
    if (current != null && colorDistance(current, next) < minColorDistance) {
      return false;
    }
    _color = next;
    return true;
  }
}
