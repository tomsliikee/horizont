import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Scrolled further than this and the solid band becomes the soft edge
/// (`P:983`).
const scrolledThreshold = 6.0;

/// What the status bar area looks like (PLAN 5.1).
class StatusBarLook {
  const StatusBarLook({required this.colors, required this.edge});

  /// Colours of the band under the status bar, left to right. One colour is
  /// a plain band; more make a gradient across the width.
  final List<Color> colors;

  /// The colour in the middle, what a single value stands for.
  Color get color => colors[colors.length ~/ 2];

  /// True for the soft edge: 85 % colour fading out below the bar, 16 px
  /// taller. False for the solid band that is only the bar high.
  final bool edge;

  @override
  bool operator ==(Object other) =>
      other is StatusBarLook &&
      listEquals(other.colors, colors) &&
      other.edge == edge;

  @override
  int get hashCode => Object.hash(Object.hashAll(colors), edge);
}

/// The rows of PLAN 5.1 that exist before private mode (M7).
///
/// [pageColors] are the last colours the page showed along its top, null
/// before the first report; then the app surface shows rather than a guess.
StatusBarLook statusBarLook({
  required bool onPage,
  required bool tint,
  required List<Color>? pageColors,
  required bool scrolled,
  required Color surface,
}) {
  // Start page and app screens: always the surface with the edge.
  if (!onPage) return StatusBarLook(colors: [surface], edge: true);
  if (!tint || pageColors == null || pageColors.isEmpty) {
    return StatusBarLook(colors: [surface], edge: scrolled);
  }
  return StatusBarLook(
    colors: [for (final c in pageColors) scrolled ? c.withAlpha(0xD9) : c],
    edge: scrolled,
  );
}
