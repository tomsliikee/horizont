import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/extensions.dart';

/// The glass of every floating bar: the glass colour, a shadow and a shape.
/// The glass is opaque unless "Durchscheinend" is on; then it blurs what lies
/// beneath (PLAN N5, D31). Flutter's blur cannot see the web page in Hybrid
/// Composition, so over a page ([NoGlassBlur]) it is only translucent.
class FloatingSurface extends StatelessWidget {
  const FloatingSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(9999)),
    this.shadows,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Defaults to the floating shadow.
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final colors = HorizontColors.of(context);
    final translucent = colors.translucentGlass;
    final blur = translucent && !NoGlassBlur.of(context);
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.glass,
        borderRadius: borderRadius,
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // A shadow under translucent glass would darken it.
        boxShadow: translucent
            ? null
            : shadows ?? HorizontShadows.of(context).floating,
      ),
      child: blur
          ? ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: decorated,
              ),
            )
          : decorated,
    );
  }
}

/// Turns the blur of [FloatingSurface]s below it off where [off]: over the
/// web page the blur would see nothing and only cost frame time.
class NoGlassBlur extends InheritedWidget {
  const NoGlassBlur({super.key, required this.off, required super.child});

  final bool off;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NoGlassBlur>()?.off ?? false;

  @override
  bool updateShouldNotify(NoGlassBlur oldWidget) => off != oldWidget.off;
}
