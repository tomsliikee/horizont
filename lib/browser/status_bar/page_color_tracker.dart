import 'dart:ui';

import 'page_color.dart';
import 'page_message.dart';

/// Decides which page reports change the tint: small changes are ignored, and
/// the capture of the page top runs at most once per [sampleInterval].
class PageColorTracker {
  PageColorTracker({DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const sampleInterval = Duration(milliseconds: 200);

  final DateTime Function() _now;
  List<Color>? _colors;
  DateTime? _lastSample;

  /// The colours along the top of the page, left to right.
  List<Color>? get colors => _colors;

  /// The colour in the middle, for a single value (the tab's card).
  Color? get color {
    final c = _colors;
    return c == null ? null : c[c.length ~/ 2];
  }

  /// Applies a colour the page script reported; true when the tint changed.
  /// Only the fallback: a capture of the page shows more.
  bool report(ColorMessage message) {
    final next = message.color;
    if (next == null) return false;
    return _set([next]);
  }

  /// Colours from a capture of the page top; true when they changed.
  bool reportSample(List<Color> next) => next.isNotEmpty && _set(next);

  /// Whether a capture may be taken now. Calling it counts as taking one.
  bool mayTakeSample() {
    final now = _now();
    final last = _lastSample;
    if (last != null && now.difference(last) < sampleInterval) return false;
    _lastSample = now;
    return true;
  }

  bool _set(List<Color> next) {
    final current = _colors;
    if (current != null && current.length == next.length) {
      var same = true;
      for (var i = 0; i < next.length; i++) {
        if (colorDistance(current[i], next[i]) >= minColorDistance) {
          same = false;
          break;
        }
      }
      if (same) return false;
    }
    _colors = next;
    return true;
  }
}
