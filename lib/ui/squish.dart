import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../theme/motion.dart';

/// Shared press feedback: the child squeezes to about 0.92 on a spatial
/// spring that overshoots a little on release. No ripple. Every tappable
/// widget is built on this instead of hand-rolling press behaviour.
///
/// With [morph] the child is built from how far the press is (0 to 1, a
/// little past while the spring overshoots), so a button can change its
/// shape while pressed, as Material 3 Expressive buttons do.
class Squish extends StatefulWidget {
  const Squish({
    super.key,
    this.child,
    this.morph,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.pressedScale = 0.92,
    this.haptic = true,
    this.turns = 0,
  }) : assert(child != null || morph != null);

  final Widget? child;
  final Widget Function(BuildContext context, double pressed)? morph;
  final VoidCallback? onTap;

  /// A second thing a press can do; the press ticks harder when it fires.
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final double pressedScale;
  final bool haptic;

  /// How far it turns while pressed, in turns (favourites spin a little).
  final double turns;

  @override
  State<Squish> createState() => _SquishState();
}

class _SquishState extends State<Squish> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      container: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: enabled
            ? () {
                if (widget.haptic) HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        onLongPress: enabled && widget.onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              }
            : null,
        child: SingleMotionBuilder(
          value: _pressed ? widget.pressedScale : 1,
          motion: HorizontMotion.spatialFor(
            context,
            HorizontMotion.spatialFast,
          ),
          child: widget.child,
          builder: (context, scale, child) {
            // How far into the press it is, 0 to 1 (overshoot included).
            final pressed = (1 - scale) / (1 - widget.pressedScale);
            final scaled = Transform.scale(
              scale: scale,
              child: widget.morph?.call(context, pressed) ?? child,
            );
            if (widget.turns == 0) return scaled;
            return Transform.rotate(
              angle: pressed * widget.turns * 2 * 3.141592653589793,
              child: scaled,
            );
          },
        ),
      ),
    );
  }
}
