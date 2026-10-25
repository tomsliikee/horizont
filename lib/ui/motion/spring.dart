import 'dart:async';

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
  }) => _settle(animateWith(_simulation(target, motion, velocity)), target);

  /// [springTo] running in reverse, so the status ends `dismissed`: what a
  /// route waits for before it goes away.
  TickerFuture springBackTo(
    double target, {
    Motion motion = HorizontMotion.spatial,
    double? velocity,
  }) => _settle(animateBackWith(_simulation(target, motion, velocity)), target);

  /// A spring stops within its tolerance of [target], not on it; a value of
  /// 0.9999 would keep an opacity layer alive for good. Once it has come to
  /// rest (not when retargeted) the value is set to [target] exactly.
  TickerFuture _settle(TickerFuture future, double target) {
    unawaited(
      future.then((_) {
        if (!isAnimating) value = target;
      }),
    );
    return future;
  }

  SpringSimulation _simulation(double target, Motion motion, double? v) {
    final description = motion is SpringMotion
        ? motion.description
        : SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 1);
    return SpringSimulation(
      description,
      value,
      target,
      v ?? velocity,
      tolerance: const Tolerance(distance: 0.0005, velocity: 0.01),
    );
  }
}
