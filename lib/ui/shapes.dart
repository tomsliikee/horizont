import 'dart:math' as math;

import 'package:flutter/physics.dart';
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

/// Points on the outline of [preset] in a [size] square, the same number for
/// every preset, so two outlines can be blended point by point (PLAN 6.3).
List<Offset> presetPoints(ShapePreset preset, double size) =>
    _points.putIfAbsent((preset, size), () {
      const count = 240;
      final radius = size / 2;
      final r0 = radius / (1 + preset.amplitude);
      return List.generate(count, (i) {
        final t = i / count * math.pi * 2;
        final r = r0 * (1 + preset.amplitude * math.cos(preset.lobes * t));
        return Offset(radius + r * math.sin(t), radius - r * math.cos(t));
      }, growable: false);
    });

final _points = <(ShapePreset, double), List<Offset>>{};

/// The outline between [from] and [to] at [t], turned by [turns].
class MorphShapePainter extends CustomPainter {
  MorphShapePainter({
    required this.from,
    required this.to,
    required this.t,
    required this.color,
    this.turns = 0,
  });

  final ShapePreset from;
  final ShapePreset to;
  final double t;
  final Color color;
  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final a = presetPoints(from, side);
    final b = presetPoints(to, side);
    final path = Path();
    for (var i = 0; i < a.length; i++) {
      final p = Offset.lerp(a[i], b[i], t)!;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    if (turns != 0) {
      canvas
        ..translate(side / 2, side / 2)
        ..rotate(turns * math.pi * 2)
        ..translate(-side / 2, -side / 2);
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(MorphShapePainter old) =>
      old.from != from ||
      old.to != to ||
      old.t != t ||
      old.color != color ||
      old.turns != turns;
}

/// A [ShapeBadge] whose outline morphs to the new [preset] when it changes,
/// on a spatial spring, and turns a little while it does.
class MorphingShapeBadge extends StatefulWidget {
  const MorphingShapeBadge({
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
  State<MorphingShapeBadge> createState() => _MorphingShapeBadgeState();
}

class _MorphingShapeBadgeState extends State<MorphingShapeBadge>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this, value: 1);
  late ShapePreset _from = widget.preset;

  @override
  void didUpdateWidget(MorphingShapeBadge old) {
    super.didUpdateWidget(old);
    if (old.preset != widget.preset) {
      _from = old.preset;
      _c.value = 0;
      final description = SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 200,
        ratio: 0.8,
      );
      _c.animateWith(SpringSimulation(description, 0, 1, 0));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(
                  painter: MorphShapePainter(
                    from: _from,
                    to: widget.preset,
                    t: _c.value,
                    color: widget.color,
                    // A sixth of a turn over the morph, back at rest.
                    turns: math.sin(_c.value.clamp(0.0, 1.0) * math.pi) / 12,
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
