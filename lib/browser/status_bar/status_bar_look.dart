import 'dart:ui';

/// Scrolled further than this and the solid band becomes the soft edge
/// (`P:983`).
const scrolledThreshold = 6.0;

/// What the status bar area looks like (PLAN 5.1).
class StatusBarLook {
  const StatusBarLook({required this.color, required this.edge});

  /// Colour of the band under the status bar.
  final Color color;

  /// True for the soft edge: 85 % colour fading out below the bar, 16 px
  /// taller. False for the solid band that is only the bar high.
  final bool edge;

  @override
  bool operator ==(Object other) =>
      other is StatusBarLook && other.color == color && other.edge == edge;

  @override
  int get hashCode => Object.hash(color, edge);
}

/// The rows of PLAN 5.1 that exist before private mode (M7).
///
/// [pageColor] is the last colour the page reported, null before the first
/// report; then the app surface shows rather than a guess.
StatusBarLook statusBarLook({
  required bool onPage,
  required bool tint,
  required Color? pageColor,
  required bool scrolled,
  required Color surface,
}) {
  // Start page and app screens: always the surface with the edge.
  if (!onPage) return StatusBarLook(color: surface, edge: true);
  if (!tint || pageColor == null) {
    return StatusBarLook(color: surface, edge: scrolled);
  }
  return StatusBarLook(
    color: scrolled ? pageColor.withAlpha(0xD9) : pageColor,
    edge: scrolled,
  );
}
