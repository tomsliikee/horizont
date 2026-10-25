import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/settings.dart';
import '../../theme/extensions.dart';
import '../../theme/motion.dart';
import '../../ui/floating_surface.dart';
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

/// The one surface of a shrinking bar, for tests.
const barSurfaceKey = ValueKey('bar-surface');

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
    _keysOnPill = _shrink.value > 0.5;
    _shrink.addListener(_onShrink);
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
    unawaited(
      _shrink.springTo(
        shrink,
        motion: HorizontMotion.spatialFor(context, HorizontMotion.playful),
      ),
    );
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

  // Where the full bar and the pill's address surface lie, measured after
  // layout (PLAN N5). The one surface of the shrinking bar is drawn between
  // them. Rects are relative to the bottom left of the bottom stack (y grows
  // downwards from 0 at the bottom edge), because the stack changes height
  // when one form goes offstage, and an offstage box has no place of its own,
  // only a size: both forms sit bottom centre in the stack.
  final _stack = GlobalKey();
  final _full = GlobalKey();
  final _pillContent = GlobalKey();
  final _pillSurface = GlobalKey();
  EdgeInsets _fullPadding = EdgeInsets.zero;
  EdgeInsets _pillPadding = EdgeInsets.zero;
  Rect? _fullRect;
  Rect? _pillRect;

  /// The keys of the actions (where search and menu grow from) go to
  /// whichever form of the bar is mostly there.
  bool _keysOnPill = false;

  void _onShrink() {
    final onPill = _shrink.value > 0.5;
    if (onPill != _keysOnPill) setState(() => _keysOnPill = onPill);
  }

  void _measure(Duration _) {
    if (!mounted) return;
    RenderBox? box(GlobalKey key) {
      final object = key.currentContext?.findRenderObject();
      return object is RenderBox && object.attached && object.hasSize
          ? object
          : null;
    }

    final stack = box(_stack);
    final fullBox = box(_full);
    final content = box(_pillContent);
    final surface = box(_pillSurface);
    if (stack == null) return;
    final width = stack.size.width;
    // A box of [size] placed bottom centre inside [padding].
    Rect slot(Size size, EdgeInsets padding) => Rect.fromLTWH(
      (width - size.width - padding.horizontal) / 2 + padding.left,
      -padding.bottom - size.height,
      size.width,
      size.height,
    );
    final full = fullBox == null ? null : slot(fullBox.size, _fullPadding);
    Rect? pill;
    if (content != null && surface != null) {
      final inner =
          surface.localToGlobal(Offset.zero, ancestor: content) & surface.size;
      pill = inner.shift(slot(content.size, _pillPadding).topLeft);
    }
    if (full != _fullRect || pill != _pillRect) {
      setState(() {
        _fullRect = full;
        _pillRect = pill;
      });
    }
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
    final current = _parts(widget.layout, keys: !_keysOnPill);
    final previous = _previous == null ? null : _parts(_previous!, keys: false);
    final minimal = widget.layout == BarLayout.minimal
        ? null
        : minimalBar(
            context,
            widget.page,
            _keysOnPill ? widget.actions : widget.actions.withoutKeys(),
            withKeys: _keysOnPill,
            onTapAddress: widget.onExpand,
            surfaceKey: _pillSurface,
            bare: true,
            shrunk: true,
          );
    _fullPadding = current.bottomPadding;
    _pillPadding = minimal?.bottomPadding ?? EdgeInsets.zero;
    final shadows = HorizontShadows.of(context);
    WidgetsBinding.instance.addPostFrameCallback(_measure);
    final bars = AnimatedBuilder(
      animation: Listenable.merge([_shrink, _hide, _swap]),
      builder: (context, _) {
        final s = _shrink.value;
        final h = _hide.value.clamp(0.0, 1.2);
        final swap = _swap.value.clamp(0.0, 1.0);
        final shown = (1 - h).clamp(0.0, 1.0);
        final hiddenShift = 160 * h;

        // One surface goes from the full bar's outline to the pill's: the
        // bar's content fades early and rides along, the pill's content
        // comes in late (PLAN N5). Nothing is scaled; a scale would make
        // Impeller rasterise the address text anew every frame.
        // The spring overshoots both ways; the surface follows a little past
        // the pill (it dips smaller and bounces back) but not past the bar.
        final m = s.clamp(0.0, 1.2);
        final full = _fullRect;
        final pill = _pillRect;
        final morph = minimal != null && full != null && pill != null;
        // Width leads, height follows (m²): the bar first draws in at the
        // sides, then drops into the thin pill, like a drop of glass.
        final hm = m <= 1 ? m * m : m;
        final surface = morph
            ? Rect.fromLTRB(
                lerpDouble(full.left, pill.left, m)!,
                lerpDouble(full.top, pill.top, hm)!,
                lerpDouble(full.right, pill.right, m)!,
                lerpDouble(full.bottom, pill.bottom, hm)!,
              )
            : null;
        // The bar's content is gone a third of the way, the pill's comes in
        // over the last part, so the surface itself is what is seen moving.
        final barFade = (1 - m * 3).clamp(0.0, 1.0);
        final pillFade = ((m - 0.6) * 2.5).clamp(0.0, 1.0);
        Offset follow(Rect? from) => surface == null || from == null
            ? Offset.zero
            : surface.center - from.center;

        Widget bottomOf(BarParts parts, double presence, {Key? key}) => Padding(
          padding: parts.bottomPadding,
          child: KeyedSubtree(
            key: key,
            child: Opacity(
              opacity: (presence * barFade * shown).clamp(0.0, 1.0),
              child: Transform.translate(
                offset:
                    Offset(0, hiddenShift + (1 - presence) * 60) + follow(full),
                child: IgnorePointer(
                  ignoring: s > 0.5 || h > 0.5 || presence < 0.5,
                  child: parts.bottom,
                ),
              ),
            ),
          ),
        );

        Widget topOf(BarParts parts, double presence) => Opacity(
          opacity: (presence * (1 - s).clamp(0.0, 1.0) * shown).clamp(0.0, 1.0),
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

        final radius = lerpDouble(
          current.bottomRadius,
          minimal?.bottomRadius ?? 22,
          m.clamp(0, 1),
        )!;
        return Stack(
          children: [
            if (previous?.top != null)
              Positioned(
                top: media.viewPadding.top + 8,
                left: 0,
                right: 0,
                child: topOf(previous!, 1 - swap),
              ),
            if (current.top != null && s < 0.999)
              Positioned(
                top: media.viewPadding.top + 8,
                left: 0,
                right: 0,
                child: RepaintBoundary(child: topOf(current, swap)),
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
                    key: _stack,
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (previous != null) bottomOf(previous, 1 - swap),
                      if (surface != null && s > 0.001)
                        Positioned(
                          left: surface.left,
                          bottom: -surface.bottom,
                          width: surface.width,
                          height: surface.height,
                          child: IgnorePointer(
                            child: Opacity(
                              // Under the full bar at first, so its pieces
                              // seem to flow together.
                              opacity: ((m * 6).clamp(0.0, 1.0) * shown).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Transform.translate(
                                offset: Offset(0, hiddenShift),
                                child: FloatingSurface(
                                  key: barSurfaceKey,
                                  borderRadius: BorderRadius.circular(
                                    math.min(radius, surface.shortestSide / 2),
                                  ),
                                  shadows: BoxShadow.lerpList(
                                    shadows.floating,
                                    shadows.button,
                                    m.clamp(0, 1),
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Both forms stay laid out, so their places are known
                      // when the bar starts to shrink; the one not seen is
                      // offstage.
                      Offstage(
                        offstage: s >= 0.999,
                        child: bottomOf(current, swap, key: _full),
                      ),
                      if (minimal != null)
                        Offstage(
                          offstage: s <= 0.001,
                          child: Padding(
                            padding: minimal.bottomPadding,
                            child: Opacity(
                              opacity: ((morph ? pillFade : m) * shown).clamp(
                                0.0,
                                1.0,
                              ),
                              child: Transform.translate(
                                offset: Offset(0, hiddenShift) + follow(pill),
                                child: IgnorePointer(
                                  ignoring: s < 0.5 || h > 0.5,
                                  child: KeyedSubtree(
                                    key: _pillContent,
                                    child: minimal.bottom,
                                  ),
                                ),
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
    // The same widgets either way, so nothing in the bars is made anew.
    return NoGlassBlur(off: widget.page.url != null, child: bars);
  }
}
