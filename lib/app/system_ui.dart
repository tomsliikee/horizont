import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The one place that decides the system bar style. Bars are transparent and
/// the app paints under them; icon brightness follows what is painted there.
///
/// [contentBrightness] is the brightness of the surface under the status bar,
/// so icons are dark on a light surface.
SystemUiOverlayStyle systemUiStyle({
  required Brightness contentBrightness,
  required Brightness navigationBrightness,
}) {
  Brightness icons(Brightness surface) =>
      surface == Brightness.light ? Brightness.dark : Brightness.light;
  return SystemUiOverlayStyle(
    statusBarColor: const Color(0x00000000),
    statusBarIconBrightness: icons(contentBrightness),
    statusBarBrightness: contentBrightness,
    systemNavigationBarColor: const Color(0x00000000),
    systemNavigationBarIconBrightness: icons(navigationBrightness),
    // No scrim behind the gesture bar: the app paints there itself.
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  );
}

/// Wraps a screen so its status and navigation bar icons match [brightness].
/// Every route sets its own: the last region painted under the bar wins.
class SystemUiRegion extends StatelessWidget {
  const SystemUiRegion({super.key, required this.child, this.brightness});

  final Widget child;

  /// Defaults to the theme's brightness.
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness ?? Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle(contentBrightness: b, navigationBrightness: b),
      child: child,
    );
  }
}
