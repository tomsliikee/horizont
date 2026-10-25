import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../theme/motion.dart';
import 'spring.dart';

/// Shows [child] while [visible], rising 16 px into place on a spatial spring
/// and drifting 8 px up on an effect spring as it leaves, then taking it out
/// of the tree (PLAN N3: the start page over the web page). Only position
/// and opacity move; a scale would make Impeller rasterise every glyph
/// again each frame (N5).
///
/// [backdrop] covers what lies below at once when it comes in (the empty
/// web view would flash white in dark mode) and fades with it when it goes.
class SpringPresence extends StatefulWidget {
  const SpringPresence({
    super.key,
    required this.visible,
    required this.child,
    this.backdrop,
  });

  final bool visible;
  final Widget child;
  final Color? backdrop;

  @override
  State<SpringPresence> createState() => _SpringPresenceState();
}

class _SpringPresenceState extends State<SpringPresence>
    with SingleTickerProviderStateMixin {
  late final _shown = AnimationController.unbounded(
    vsync: this,
    value: widget.visible ? 1 : 0,
  );
  late Widget _kept = widget.child;

  @override
  void didUpdateWidget(SpringPresence old) {
    super.didUpdateWidget(old);
    if (widget.visible) _kept = widget.child;
    if (old.visible == widget.visible) return;
    if (widget.visible) {
      unawaited(_shown.springTo(1, motion: HorizontMotion.spatialFor(context)));
    } else {
      unawaited(
        _shown
            .springTo(0, motion: HorizontMotion.effects)
            .then((_) => mounted ? setState(() {}) : null),
      );
    }
  }

  @override
  void dispose() {
    _shown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _shown.value <= 0.001 && !_shown.isAnimating) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _shown,
      child: _kept,
      builder: (context, child) {
        final v = _shown.value;
        final dy = widget.visible ? 16 * (1 - v) : -8 * (1 - v);
        final content = Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, dy), child: child),
        );
        final backdrop = widget.backdrop;
        return IgnorePointer(
          ignoring: !widget.visible,
          child: backdrop == null
              ? content
              : ColoredBox(
                  color: backdrop.withValues(
                    alpha: widget.visible ? 1 : v.clamp(0.0, 1.0),
                  ),
                  child: content,
                ),
        );
      },
    );
  }
}
