import 'package:material_ui/material_ui.dart';

import '../../theme/motion.dart';
import 'spring.dart';

/// Moves [child] smoothly when the layout puts it somewhere else (FLIP):
/// after each layout it compares its position with the last one and springs
/// from the old place to the new. Used for the reflow of tab cards when one
/// closes (PLAN 6.2). Only a transform moves; nothing lays out again.
class FlipSlot extends StatefulWidget {
  const FlipSlot({super.key, required this.child, this.appear = false});

  final Widget child;

  /// Pops in from small when it first appears (a new tab card).
  final bool appear;

  @override
  State<FlipSlot> createState() => _FlipSlotState();
}

class _FlipSlotState extends State<FlipSlot> with TickerProviderStateMixin {
  late final _dx = AnimationController.unbounded(vsync: this);
  late final _dy = AnimationController.unbounded(vsync: this);
  late final _scale = AnimationController.unbounded(
    vsync: this,
    value: widget.appear ? 0.4 : 1,
  );
  Offset? _last;

  @override
  void initState() {
    super.initState();
    if (widget.appear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scale.springTo(1, motion: HorizontMotion.spatialFast);
      });
    }
  }

  @override
  void dispose() {
    _dx.dispose();
    _dy.dispose();
    _scale.dispose();
    super.dispose();
  }

  void _measure() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    // In content coordinates, so scrolling is not taken for a move.
    final scroll = Scrollable.maybeOf(context)?.position;
    final pixels = scroll == null || !scroll.hasPixels ? 0.0 : scroll.pixels;
    final now = box.localToGlobal(Offset.zero) + Offset(0, pixels);
    final last = _last;
    _last = now;
    if (last == null) return;
    // What is still in flight counts: the child is drawn at now + offset.
    final delta = last - now;
    if (delta.distanceSquared < 0.25) return;
    if (HorizontMotion.reduced(context)) return;
    _dx.value += delta.dx;
    _dy.value += delta.dy;
    _dx.springTo(0, motion: HorizontMotion.spatial);
    _dy.springTo(0, motion: HorizontMotion.spatial);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });
    return AnimatedBuilder(
      animation: Listenable.merge([_dx, _dy, _scale]),
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(_dx.value, _dy.value),
        child: Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _scale.value.clamp(0.0, 1.0), child: child),
        ),
      ),
    );
  }
}
