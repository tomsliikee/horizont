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

/// The screen's surface behind the status bar, fading out below it, so
/// content scrolled up does not run into the clock and icons (the soft edge
/// of PLAN 5.1 for app screens).
class StatusBand extends StatelessWidget {
  const StatusBand({super.key, required this.child, this.color});

  final Widget child;

  /// Defaults to the scaffold background.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    final c = color ?? Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: top + 16,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, top / (top + 16), 1],
                  colors: [
                    c,
                    c.withValues(alpha: 0.94),
                    c.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
