import 'dart:async';

import '../data/settings.dart';
import '../platform/horizont_webkit.dart';

/// What a vibration means; the native side picks how it feels.
enum Haptic {
  /// A plain tap on a button.
  tap,

  /// A step while dragging or choosing: a segment, a list place.
  tick,

  /// A gesture went far enough to do something when let go.
  threshold,

  /// The finger pulled back below the threshold.
  release,

  /// Something finished well: a download, a saved bookmark.
  confirm,

  /// Nothing more that way: the last tab, no history.
  reject,
  toggleOn,
  toggleOff,

  /// A long press picked something up.
  dragStart,

  /// A long press that opens a menu.
  longPress,
}

/// The one way the app vibrates. The level comes from the settings; the
/// system's touch feedback setting applies on top.
abstract final class Haptics {
  static var level = HapticLevel.normal;

  static void play(Haptic haptic) {
    if (level == HapticLevel.off) return;
    unawaited(
      HorizontWebKit.haptic(haptic.name, strong: level == HapticLevel.strong),
    );
  }
}
