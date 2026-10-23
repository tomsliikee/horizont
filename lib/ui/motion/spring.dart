import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../theme/motion.dart';

/// Drives an unbounded [AnimationController] with the design system's
/// springs, so a value can overshoot and keeps the velocity it had when it
/// is retargeted or let go (PLAN 6.1).
extension SpringController on AnimationController {
  /// Springs from where the value is now to [target]. [velocity] is in units
  /// per second; by default the current velocity carries over.
  TickerFuture springTo(
    double target, {
    Motion motion = HorizontMotion.spatial,
    double? velocity,
  }) {
    final description = motion is SpringMotion
        ? motion.description
        : SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 1);
    final simulation = SpringSimulation(
      description,
      value,
      target,
      velocity ?? this.velocity,
      tolerance: const Tolerance(distance: 0.0005, velocity: 0.01),
    );
    return animateWith(simulation);
  }
}
