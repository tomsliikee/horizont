import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/motion.dart';
import 'spring.dart';

/// Lets [child] rise into place [index] steps after its list appeared: a
/// short way up and a fade, on springs (PLAN 6.2, suggestion rows 20 ms
/// apart). With reduced motion it only fades.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 24),
    this.offset = 18,
    this.maxDelayed = 12,
  });

  final int index;
  final Widget child;
  final Duration step;

  /// How far below its place it starts, in pixels.
  final double offset;

  /// Items beyond this many appear together with the last delayed one.
  final int maxDelayed;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = widget.step * widget.index.clamp(0, widget.maxDelayed);
    _timer = Timer(delay, () {
      if (mounted) unawaited(_c.springTo(1, motion: HorizontMotion.spatial));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = HorizontMotion.reduced(context);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: reduced
              ? child
              : Transform.translate(
                  offset: Offset(0, (1 - t) * widget.offset),
                  child: child,
                ),
        );
      },
    );
  }
}
