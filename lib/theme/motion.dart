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
