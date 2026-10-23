import 'dart:ui' show FontVariation;

import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../theme/motion.dart';

/// A number that counts to a new value lighter and settles at full weight
/// (design system, Numbers). Effect spring: it never overshoots.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.format,
  });

  final int value;
  final TextStyle style;

  /// Text for a value; plain digits by default.
  final String Function(int value)? format;

  @override
  Widget build(BuildContext context) {
    return SingleMotionBuilder(
      value: value.toDouble(),
      motion: HorizontMotion.effectsSlow,
      builder: (context, shown, _) {
        final distance = (value - shown).abs();
        // Lighter while it is still far from the target.
        final settling = (distance / (value.abs() + 1)).clamp(0.0, 1.0);
        final weight = 800 - 300 * settling;
        final rounded = shown.round();
        return Text(
          format?.call(rounded) ?? '$rounded',
          style: style.copyWith(
            fontVariations: [
              for (final v in style.fontVariations ?? const <FontVariation>[])
                if (v.axis != 'wght') v,
              FontVariation('wght', (weight / 25).round() * 25),
            ],
          ),
        );
      },
    );
  }
}
