import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The prototype's polar shape `r = r0 * (1 + amp * cos(n * theta))`, fitted
/// into a [size] square (`shape()` in the prototype, P:758).
Path shapePath(int n, double amp, double size) {
  final radius = size / 2;
  final r0 = radius / (1 + amp);
  final steps = math.max(96, n * 24);
  final path = Path();
  for (var i = 0; i <= steps; i++) {
    final t = i / steps * math.pi * 2;
    final r = r0 * (1 + amp * math.cos(n * t));
    final x = radius + r * math.sin(t);
    final y = radius - r * math.cos(t);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path..close();
}

/// A named shape: lobe count and amplitude.
enum ShapePreset {
  hero9(9, 0.07),
  hero6(6, 0.08),
  sunny(12, 0.06),
  flower(8, 0.12),
  fav4(4, 0.10),
  fav6(6, 0.07),
  fav8(8, 0.06),
  fav5(5, 0.09);

  const ShapePreset(this.lobes, this.amplitude);

  final int lobes;
  final double amplitude;

  /// The four shapes the favourites cycle through.
  static const favourites = [fav4, fav6, fav8, fav5];
}

final _cache = <(ShapePreset, double), Path>{};

/// [shapePath] of [preset], cached per size.
Path presetPath(ShapePreset preset, double size) => _cache.putIfAbsent((
  preset,
  size,
), () => shapePath(preset.lobes, preset.amplitude, size));

class ExpressiveShapePainter extends CustomPainter {
  const ExpressiveShapePainter({required this.preset, required this.color});

  final ShapePreset preset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      presetPath(preset, size.shortestSide),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(ExpressiveShapePainter old) =>
      old.preset != preset || old.color != color;
}

/// A shape with [child] (a number, icon or letter) centred on it.
class ShapeBadge extends StatelessWidget {
  const ShapeBadge({
    super.key,
    required this.preset,
    required this.size,
    required this.color,
    required this.child,
  });

  final ShapePreset preset;
  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ExpressiveShapePainter(preset: preset, color: color),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
