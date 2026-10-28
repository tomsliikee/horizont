import 'package:material_ui/material_ui.dart';

import 'logo_geometry.dart';

/// The colours of the logo. [brand] is the launcher icon; [themed] is how
/// Android draws the monochrome layer with a Material You palette.
@immutable
class LogoColors {
  const LogoColors({
    required this.sky,
    required this.ground,
    required this.sun,
    required this.line,
    this.monochrome = false,
  });

  /// `primary`, its dark `on-primary`, `seed-orange` and the dark `primary`
  /// of `referenz/tokens.json`. `tool/gen_icon.dart` writes the same values.
  static const brand = LogoColors(
    sky: Color(0xFF0045FC),
    ground: Color(0xFF00228B),
    sun: Color(0xFFF26B3A),
    line: Color(0xFFB9C3FF),
  );

  /// One tone on a container, as a themed launcher icon.
  factory LogoColors.themed(ColorScheme scheme) => LogoColors(
    sky: scheme.primaryContainer,
    ground: scheme.primaryContainer,
    sun: scheme.onPrimaryContainer,
    line: scheme.onPrimaryContainer,
    monochrome: true,
  );

  final Color sky;
  final Color ground;
  final Color sun;
  final Color line;

  /// Draws only the monochrome layer's shapes: no ground, the sun cut at
  /// the horizon.
  final bool monochrome;
}

/// The Horizont logo as the launcher shows it: the visible 72 of the
/// adaptive icon's 108, clipped to [shape].
class HorizontLogo extends StatelessWidget {
  const HorizontLogo({
    super.key,
    this.size = 96,
    this.colors = LogoColors.brand,
    this.shape = const CircleBorder(),
    this.rise = 1,
  });

  final double size;
  final LogoColors colors;
  final ShapeBorder shape;

  /// How far the sun is up, 0 (behind the ground) to 1; the reflection
  /// grows with it.
  final double rise;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: CustomPaint(painter: HorizontLogoPainter(colors, rise: rise)),
    ),
  );
}

class HorizontLogoPainter extends CustomPainter {
  HorizontLogoPainter(this.colors, {this.rise = 1});

  final LogoColors colors;
  final double rise;

  static Path _polygon(List<(double, double)> points) {
    final path = Path()..moveTo(points.first.$1, points.first.$2);
    for (final (x, y) in points.skip(1)) {
      path.lineTo(x, y);
    }
    return path..close();
  }

  static Path _line(List<(double, double)> points) {
    final path = Path()..moveTo(points.first.$1, points.first.$2);
    for (final (x, y) in points.skip(1)) {
      path.lineTo(x, y);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const visible = LogoGeometry.size - 2 * LogoGeometry.visibleInset;
    canvas
      ..save()
      ..scale(size.width / visible, size.height / visible)
      ..translate(-LogoGeometry.visibleInset, -LogoGeometry.visibleInset);

    final fill = Paint()..isAntiAlias = true;
    final stroke = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRect(
      const Rect.fromLTWH(0, 0, LogoGeometry.size, LogoGeometry.size),
      fill..color = colors.sky,
    );
    // Only the full logo has ground to hide a sun that is not up yet.
    final sink = colors.monochrome
        ? 0.0
        : (1 - rise) * (LogoGeometry.sunRadius * 2 + 4);
    canvas.drawPath(
      _polygon(LogoGeometry.sun(upperHalf: colors.monochrome))
          .shift(Offset(0, sink)),
      fill..color = colors.sun,
    );
    if (!colors.monochrome) {
      canvas.drawPath(
        _polygon(LogoGeometry.ground()),
        fill..color = colors.ground,
      );
    }
    canvas.drawPath(
      _line(LogoGeometry.horizon(from: 8, to: LogoGeometry.size - 8)),
      stroke
        ..color = colors.line
        ..strokeWidth = LogoGeometry.horizonStroke,
    );
    for (final (y, full) in LogoGeometry.reflections) {
      final half = full * (colors.monochrome ? 1 : rise.clamp(0.0, 1.0));
      if (half <= 0) continue;
      canvas.drawLine(
        Offset(LogoGeometry.size / 2 - half, y),
        Offset(LogoGeometry.size / 2 + half, y),
        stroke
          ..color = colors.sun
          ..strokeWidth = LogoGeometry.reflectionStroke,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HorizontLogoPainter old) =>
      old.colors != colors || old.rise != rise;
}
