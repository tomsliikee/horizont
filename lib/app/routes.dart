import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/extensions.dart';
import '../theme/motion.dart';
import '../ui/motion/spring.dart';

/// The global rect of the widget behind [key], or null before layout.
Rect? rectOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

/// Closes a grown sheet with its animation; handed to the sheet's builder.
typedef CloseSheet = Future<void> Function([Object? result]);

/// Shows a sheet that grows out of [origin] (the button that opened it):
/// it starts as the button's shape and opens to its own rect with radius 32
/// on a spatial spring; pulling it down shrinks it back, a fling closes it
/// (PLAN 6.2, Menu sheet). Inset 8 on three sides (`P:263`); the scrim covers
/// the status bar too.
Future<T?> showGrowSheet<T>(
  BuildContext context, {
  required Rect? origin,
  required Widget Function(BuildContext context, CloseSheet close) builder,
  String? barrierLabel,
}) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => _GrowSheet(
        origin: origin,
        builder: builder,
        barrierLabel: barrierLabel,
      ),
    ),
  );
}

class _GrowSheet extends StatefulWidget {
  const _GrowSheet({
    required this.origin,
    required this.builder,
    this.barrierLabel,
  });

  final Rect? origin;
  final Widget Function(BuildContext context, CloseSheet close) builder;
  final String? barrierLabel;

  @override
  State<_GrowSheet> createState() => _GrowSheetState();
}

class _GrowSheetState extends State<_GrowSheet> with TickerProviderStateMixin {
  late final _open = AnimationController.unbounded(vsync: this);
  late final _drag = AnimationController.unbounded(vsync: this);

  /// Closing takes the content away at once; the outline follows on its
  /// spring, so nothing lingers in a shrinking shape.
  late final _hide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );
  late final Animation<double> _visible = ReverseAnimation(_hide);
  final _sheetKey = GlobalKey();
  late final Animation<double> _fade = _open.drive(
    Animatable.fromCallback((t) => ((t - 0.2) / 0.5).clamp(0.0, 1.0)),
  );
  late final Animation<Offset> _rise = _open.drive(
    Animatable.fromCallback((t) => Offset(0, (1 - t.clamp(0.0, 1.0)) * 0.04)),
  );
  var _closing = false;
  var _crossedThreshold = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _open.springTo(
          1,
          motion: HorizontMotion.spatialFor(
            context,
            HorizontMotion.spatialFast,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _drag.dispose();
    _hide.dispose();
    super.dispose();
  }

  Future<void> _close([Object? result, double velocity = 0]) async {
    if (_closing) return;
    _closing = true;
    unawaited(_hide.forward());
    // Back into the button, without bouncing past it.
    await Future.wait([
      _open.springTo(
        0,
        motion: HorizontMotion.effectsFast,
        velocity: -velocity / 600,
      ),
      if (_drag.value != 0) _drag.springTo(0, motion: HorizontMotion.effects),
    ]);
    if (mounted) Navigator.of(context).pop(result);
  }

  /// The sheet's height from the last layout; drags are measured against it.
  double _height = 600;

  void _measure() {
    final box = _sheetKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize) _height = box.size.height;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _measure();
    var next = _drag.value + d.delta.dy;
    // Pulled up past the top it stretches less and less (rubber band).
    if (next < 0) next = -math.sqrt(-next * 6);
    _drag.value = next;
    final past = next > _height * 0.25;
    if (past != _crossedThreshold) {
      _crossedThreshold = past;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (v > 900 || (_drag.value > _height * 0.25 && v > -300)) {
      HapticFeedback.lightImpact();
      unawaited(_close(null, v));
    } else {
      unawaited(_drag.springTo(0, motion: HorizontMotion.spatial, velocity: v));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scheme = Theme.of(context).colorScheme;
    final scrim = HorizontColors.of(context).scrim;
    final size = media.size;
    final content = RepaintBoundary(
      child: FadeTransition(
        opacity: _visible,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _rise,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: math.max(0, media.viewPadding.bottom - 8),
              ),
              child: widget.builder(context, ([r]) => _close(r)),
            ),
          ),
        ),
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: Listenable.merge([_open, _drag]),
          // The content is built once; only the outline moves per frame.
          child: content,
          builder: (context, child) {
            final t = _open.value;
            final shown = t.clamp(0.0, 1.0);
            // The pull also lets the scrim go.
            final pull = (_drag.value / _height).clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    label: widget.barrierLabel,
                    button: true,
                    child: GestureDetector(
                      onTap: () => unawaited(_close()),
                      child: ColoredBox(
                        color: scrim.withValues(
                          alpha: scrim.a * shown * (1 - pull),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: math.min(
                        820,
                        size.height - media.viewPadding.top - 16,
                      ),
                    ),
                    child: Transform.translate(
                      offset: Offset(0, _drag.value),
                      child: GestureDetector(
                        onVerticalDragUpdate: _onDragUpdate,
                        onVerticalDragEnd: _onDragEnd,
                        // No elevation: the shadow of an outline that changes
                        // every frame is blurred anew each frame, and over the
                        // scrim it is barely seen.
                        child: ClipPath(
                          key: _sheetKey,
                          clipper: _GrowClipper(
                            origin: widget.origin,
                            screen: size,
                            t: t,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ColoredBox(
                            color: scheme.surfaceContainer,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The outline of a growing sheet: from the button's circle at t = 0 to the
/// sheet's own rect with radius 32 at t = 1. The sheet sits 8 from the
/// sides and bottom of a [screen]-sized stack, which places it globally.
class _GrowClipper extends CustomClipper<Path> {
  _GrowClipper({required this.origin, required this.screen, required this.t});

  final Rect? origin;
  final Size screen;
  final double t;

  @override
  Path getClip(Size size) {
    final full = Offset.zero & size;
    final o = origin;
    if (o == null) {
      final s = t.clamp(0.0, 1.0);
      final rect = Rect.fromLTRB(
        0,
        size.height * (1 - s),
        size.width,
        size.height,
      );
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(32)));
    }
    // The button in the sheet's coordinates.
    final top = screen.height - 8 - size.height;
    final from = o.shift(Offset(-8, -top));
    final rect = Rect.lerp(from, full, t)!;
    // An overshooting spring may grow it a little past its rect; never
    // shrink it inside out.
    final safe = Rect.fromLTRB(
      rect.left,
      rect.top,
      math.max(rect.right, rect.left + 1),
      math.max(rect.bottom, rect.top + 1),
    );
    final radius = lerpDouble(from.shortestSide / 2, 32, t.clamp(0.0, 1.0))!;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(safe, Radius.circular(radius)));
  }

  @override
  bool shouldReclip(_GrowClipper old) =>
      old.t != t || old.origin != origin || old.screen != screen;
}

/// A screen route (PLAN N3): it comes and goes on springs, drawn by the
/// theme's `ExpressiveScreenTransitionsBuilder`; Android's predictive back
/// comes with it, and a back gesture let go mid-way carries on from there.
Route<T> screenRoute<T>(Widget page) =>
    _SpringScreenRoute<T>(builder: (context) => page);

class _SpringScreenRoute<T> extends MaterialPageRoute<T> {
  _SpringScreenRoute({required super.builder});

  bool get _reduced {
    final context = navigator?.context;
    return context != null && HorizontMotion.reduced(context);
  }

  @override
  TickerFuture didPush() {
    super.didPush();
    return controller!.springTo(
      1,
      motion: _reduced ? HorizontMotion.effects : HorizontMotion.spatial,
    );
  }

  @override
  bool didPop(T? result) {
    final popped = super.didPop(result);
    // Back without overshoot: it must come to rest at 0 to be removed.
    unawaited(controller!.springBackTo(0, motion: HorizontMotion.effects));
    return popped;
  }
}
