import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/extensions.dart';

/// The glass of every floating bar: the glass colour, the floating shadow and
/// a shape. [blur] is off by default: Pulse lost scrolling to backdrop filters
/// on the target phone, and the glass is 92 % opaque anyway (R2).
class FloatingSurface extends StatelessWidget {
  const FloatingSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(9999)),
    this.blur = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: HorizontColors.of(context).glass,
        borderRadius: borderRadius,
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: HorizontShadows.of(context).floating,
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
