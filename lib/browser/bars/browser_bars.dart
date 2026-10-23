import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/settings.dart';
import '../../theme/motion.dart';
import '../../ui/motion/spring.dart';
import '../browser_providers.dart';
import '../web_engine.dart';
import 'bar_actions.dart';
import 'bar_layouts.dart';

/// Room the top part of [layout] takes from the page, below the status bar.
double topReserveOf(BarLayout layout) => switch (layout) {
  BarLayout.oben => 72,
  BarLayout.expressiv => 60,
  _ => 0,
};

/// The bars of the chosen layout, floating over the page (PLAN 3, M9). While
/// the page is read downwards they morph into the minimal pill, at the page
/// end they may sink away (D4), and they step aside for the keyboard. A
/// sideways drag on the bottom bar switches tabs; a swipe up opens the
/// overview (PLAN 6.2). Only transforms and opacity move.
class BrowserBars extends StatefulWidget {
  const BrowserBars({
    super.key,
    required this.layout,
    required this.page,
    required this.actions,
    required this.mode,
    required this.keyboardUp,
    required this.engineLabel,
    required this.onExpand,
    this.onSwipeUpdate,
    this.onSwipeEnd,
  });

  final BarLayout layout;
  final PageState page;
  final BarActions actions;
  final BarMode mode;
  final bool keyboardUp;
  final String engineLabel;
  final VoidCallback onExpand;

  /// The finger's way sideways on the bottom bar, in pixels.
  final ValueChanged<double>? onSwipeUpdate;

  /// The finger let go, with its velocity in pixels per second.
  final ValueChanged<double>? onSwipeEnd;

  @override
  State<BrowserBars> createState() => _BrowserBarsState();
}

class _BrowserBarsState extends State<BrowserBars>
    with TickerProviderStateMixin {
  /// 0 full, 1 shrunk to the minimal pill.
  late final _shrink = AnimationController.unbounded(vsync: this);

  /// 0 shown, 1 sunk below the edge.
  late final _hide = AnimationController.unbounded(vsync: this);

  /// 0 the old layout, 1 the new one, after a layout change.
  late final _swap = AnimationController.unbounded(vsync: this, value: 1);
  BarLayout? _previous;
  double _drag = 0;
  bool _horizontal = false;

  @override
  void initState() {
    super.initState();
    _apply(animate: false);
  }

  @override
  void didUpdateWidget(BrowserBars old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode || old.keyboardUp != widget.keyboardUp) {
      _apply(animate: true);
    }
    if (old.layout != widget.layout) {
      _previous = old.layout;
      _swap.value = 0;
      unawaited(
        _swap.springTo(1, motion: HorizontMotion.spatialSlow).then((_) {
          if (mounted) setState(() => _previous = null);
        }),
      );
    }
  }

  void _apply({required bool animate}) {
    final shrink = widget.mode == BarMode.shrunk ? 1.0 : 0.0;
    final hide = widget.mode == BarMode.hidden || widget.keyboardUp ? 1.0 : 0.0;
    if (!animate) {
      _shrink.value = shrink;
      _hide.value = hide;
      return;
    }
    final spatial = HorizontMotion.spatialFor(context, HorizontMotion.spatial);
    unawaited(_shrink.springTo(shrink, motion: spatial));
    unawaited(
      _hide.springTo(
        hide,
        motion: widget.keyboardUp ? HorizontMotion.effectsFast : spatial,
      ),
    );
  }

  @override
  void dispose() {
    _shrink.dispose();
    _hide.dispose();
    _swap.dispose();
    super.dispose();
  }

  BarParts _parts(BarLayout layout, {bool keys = true}) {
    final c = context;
    final p = widget.page;
    final a = keys ? widget.actions : widget.actions.withoutKeys();
    return switch (layout) {
      BarLayout.kompakt => compactBar(c, p, a),
      BarLayout.zweireihig => twoRowBar(c, p, a),
      BarLayout.expressiv => expressiveBar(c, p, a),
      BarLayout.oben => topBar(c, p, a),
      BarLayout.karte => cardBar(c, p, a, widget.engineLabel),
      BarLayout.minimal => minimalBar(c, p, a),
    };
  }

  void _dragUpdate(DragUpdateDetails d) {
    if (!_horizontal) return;
    _drag += d.delta.dx;
    widget.onSwipeUpdate?.call(_drag);
  }

  void _dragEnd(DragEndDetails d) {
    if (!_horizontal) return;
    _horizontal = false;
    widget.onSwipeEnd?.call(d.velocity.pixelsPerSecond.dx);
    _drag = 0;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Room for three-button navigation; the gesture bar is already allowed for.
    final lift = math.max(0.0, media.viewPadding.bottom - 24);
    final current = _parts(widget.layout);
    final previous = _previous == null ? null : _parts(_previous!, keys: false);
    final minimal = widget.layout == BarLayout.minimal
        ? null
        : minimalBar(
            context,
            widget.page,
            widget.actions.withoutKeys(),
            withKeys: false,
            onTapAddress: widget.onExpand,
          );
    return AnimatedBuilder(
      animation: Listenable.merge([_shrink, _hide, _swap]),
      builder: (context, _) {
        final s = _shrink.value;
        final h = _hide.value.clamp(0.0, 1.2);
        final swap = _swap.value;
        final full = (1 - s).clamp(0.0, 1.0);
        final hiddenShift = 160 * h;

        Widget bottomOf(BarParts parts, double presence) => Opacity(
          opacity: (presence * full * (1 - h).clamp(0.0, 1.0)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, hiddenShift + 28 * s + (1 - presence) * 60),
            child: Transform.scale(
              scale: 1 - 0.08 * s.clamp(0.0, 1.2),
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                ignoring: s > 0.5 || h > 0.5 || presence < 0.5,
                child: parts.bottom,
              ),
            ),
          ),
        );

        Widget topOf(BarParts parts, double presence) => Opacity(
          opacity: (presence * full * (1 - h).clamp(0.0, 1.0)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(
              0,
              -(parts.topReserve + 24) * (s.clamp(0.0, 1.0) + (1 - presence)),
            ),
            child: IgnorePointer(
              ignoring: s > 0.5 || h > 0.5 || presence < 0.5,
              child: parts.top,
            ),
          ),
        );

        return Stack(
          children: [
            if (previous?.top != null)
              Positioned(
                top: media.viewPadding.top + 8,
                left: 0,
                right: 0,
                child: topOf(previous!, 1 - swap.clamp(0.0, 1.0)),
              ),
            if (current.top != null && s < 0.999)
              Positioned(
                top: media.viewPadding.top + 8,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: topOf(current, swap.clamp(0.0, 1.0)),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: lift,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onHorizontalDragStart: (_) {
                  _horizontal = widget.onSwipeUpdate != null;
                  _drag = 0;
                },
                onHorizontalDragUpdate: _dragUpdate,
                onHorizontalDragEnd: _dragEnd,
                onVerticalDragEnd: (d) {
                  if (d.velocity.pixelsPerSecond.dy < -600) {
                    HapticFeedback.mediumImpact();
                    widget.actions.tabs();
                  }
                },
                child: RepaintBoundary(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (previous != null)
                        bottomOf(previous, 1 - swap.clamp(0.0, 1.0)),
                      // Only what can be seen is built.
                      if (s < 0.999) bottomOf(current, swap.clamp(0.0, 1.0)),
                      if (minimal != null && s > 0.001)
                        Opacity(
                          opacity:
                              (s.clamp(0.0, 1.0) * (1 - h).clamp(0.0, 1.0)),
                          child: Transform.translate(
                            offset: Offset(0, hiddenShift + 18 * (1 - s)),
                            child: Transform.scale(
                              scale: 0.86 + 0.14 * s,
                              alignment: Alignment.bottomCenter,
                              child: IgnorePointer(
                                ignoring: s < 0.5 || h > 0.5,
                                child: minimal.bottom,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
