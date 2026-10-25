import 'package:material_ui/material_ui.dart';

/// How screens come and go (PLAN N3, N5): the new screen arrives as a card
/// with rounded corners sliding in from the right; the screen below steps
/// aside and dims. The route drives it on springs (`screenRoute` in
/// `app/routes.dart`).
///
/// Nothing is scaled: Impeller rasterises text anew at every scale, which cost
/// a whole screen of glyphs per frame (N5, `docs/spikes.md`).
///
/// Android's predictive back gesture keeps its own transition: while the
/// finger is down, [PredictiveBackPageTransitionsBuilder] gets the real
/// animations; otherwise it gets settled ones, so its fallback does nothing
/// and only this transition moves. It stays in the tree either way, because
/// it is what listens for the gesture.
class ExpressiveScreenTransitionsBuilder extends PageTransitionsBuilder {
  const ExpressiveScreenTransitionsBuilder();

  static const _predictive = PredictiveBackPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 450);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final gesture = route.popGestureInProgress;
    // The browser below every screen holds the live web view, which must not
    // be moved (PLAN 7.2): it only dims.
    final secondary = route.isFirst
        ? _DimOnly(secondaryAnimation)
        : secondaryAnimation;
    // The same widgets either way, so the screen keeps its state when the
    // gesture starts or ends.
    return _predictive.buildTransitions(
      route,
      context,
      gesture ? animation : kAlwaysCompleteAnimation,
      gesture ? secondaryAnimation : kAlwaysDismissedAnimation,
      ExpressiveScreenTransition(
        animation: gesture ? kAlwaysCompleteAnimation : animation,
        secondaryAnimation: gesture ? kAlwaysDismissedAnimation : secondary,
        child: child,
      ),
    );
  }
}

/// Marks a secondary animation that dims the screen without moving it.
class _DimOnly extends ProxyAnimation {
  _DimOnly(Animation<double> super.parent);
}

class ExpressiveScreenTransition extends StatelessWidget {
  const ExpressiveScreenTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      child: child,
      builder: (context, child) {
        final t = animation.value;
        final s = secondaryAnimation.value.clamp(0.0, 1.0);
        final moves = secondaryAnimation is! _DimOnly ? s : 0.0;
        // Always the same widgets, settled to identity at rest, so the
        // screen is never rebuilt from scratch when a transition ends.
        return Transform.translate(
          offset: Offset((1 - t) * width * 0.24 - moves * width * 0.08, 0),
          child: Opacity(
            opacity: (t * 2.6).clamp(0.0, 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32 * (1 - t).clamp(0, 1)),
              clipBehavior: t < 1 ? Clip.antiAlias : Clip.none,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: s,
                        child: const ColoredBox(color: Color(0x2E000000)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
