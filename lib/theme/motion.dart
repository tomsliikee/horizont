import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

/// The Material 3 Expressive spring tokens. Spatial springs move, scale and
/// morph things and may overshoot; effect springs drive colour, opacity and
/// numbers and never overshoot.
abstract final class HorizontMotion {
  static const Motion spatialFast =
      MaterialSpringMotion.expressiveSpatialFast();
  static const Motion spatial = MaterialSpringMotion.expressiveSpatialDefault();
  static const Motion spatialSlow =
      MaterialSpringMotion.expressiveSpatialSlow();

  /// Softer and bouncier than [spatialSlow] (stiffness 240, damping ratio
  /// 0.6), for a change meant to be watched: the bar becoming the pill.
  static const Motion playful = SpringMotion(
    SpringDescription(mass: 1, stiffness: 240, damping: 18.6),
  );
  static const Motion effectsFast =
      MaterialSpringMotion.expressiveEffectsFast();
  static const Motion effects = MaterialSpringMotion.expressiveEffectsDefault();
  static const Motion effectsSlow =
      MaterialSpringMotion.expressiveEffectsSlow();

  /// True when the system asks for no animations ("Remove animations",
  /// battery saver). Spatial springs then become effect springs, so nothing
  /// overshoots.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [spatial] unless motion is reduced.
  static Motion spatialFor(BuildContext context, [Motion spatial = spatial]) =>
      reduced(context) ? effects : spatial;
}
