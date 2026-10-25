import 'dart:math' as math;

/// The geometry of the Horizont logo: a scalloped sun rising over a curved
/// horizon, with two lines of its reflection below. Pure Dart, so both the
/// app's painter (`horizont_logo.dart`) and `tool/gen_icon.dart`, which
/// writes the launcher icon's vector drawables, draw from the same numbers.
///
/// Units are those of an adaptive icon: a 108 square, of which the launcher
/// shows the middle 72 ([visibleInset] on each side) and guarantees the
/// circle of radius 33 around the centre.
abstract final class LogoGeometry {
  static const double size = 108;
  static const double visibleInset = 18;

  /// The horizon is an arc of a large circle; [horizonY] is its top, at the
  /// centre.
  static const double horizonY = 60;
  static const double _earthRadius = 180;

  /// The sun is the design system's `sunny` shape (12 lobes, amplitude 0.06),
  /// centred on the horizon.
  static const double sunRadius = 21;
  static const int sunLobes = 12;
  static const double sunAmplitude = 0.06;

  static const double horizonStroke = 4;
  static const double reflectionStroke = 3.5;

  /// The reflection lines: height and half width.
  static const List<(double y, double halfWidth)> reflections = [
    (71, 11),
    (78, 5.5),
  ];

  /// The horizon's height at [x].
  static double horizonAt(double x) {
    final dx = x - size / 2;
    return horizonY +
        _earthRadius -
        math.sqrt(_earthRadius * _earthRadius - dx * dx);
  }

  /// Points along the horizon from [from] to [to].
  static List<(double, double)> horizon({
    double from = -2,
    double to = size + 2,
    int steps = 48,
  }) => [
    for (var i = 0; i <= steps; i++)
      (from + (to - from) * i / steps, horizonAt(from + (to - from) * i / steps)),
  ];

  /// The ground below the horizon, to the edges of the full square.
  static List<(double, double)> ground() => [
    ...horizon(),
    (size + 2, size + 2),
    (-2, size + 2),
  ];

  /// The sun's outline. With [upperHalf] only the part above its centre line,
  /// closed along that line (the monochrome layer has no ground to hide the
  /// rest).
  static List<(double, double)> sun({bool upperHalf = false}) {
    const cx = size / 2;
    const cy = horizonY;
    const r0 = sunRadius / (1 + sunAmplitude);
    const steps = 192;
    final points = <(double, double)>[];
    final from = upperHalf ? -math.pi / 2 : 0.0;
    final span = upperHalf ? math.pi : math.pi * 2;
    for (var i = 0; i <= steps; i++) {
      final t = from + span * i / steps;
      final r = r0 * (1 + sunAmplitude * math.cos(sunLobes * t));
      points.add((cx + r * math.sin(t), cy - r * math.cos(t)));
    }
    return points;
  }
}
