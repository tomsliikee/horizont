import 'package:material_ui/material_ui.dart';

import 'color_schemes.dart';
import 'extensions.dart';
import 'system_palette.dart';
import 'type.dart';

/// The [ThemeData] of [colourway] in [brightness].
ThemeData buildHorizontTheme(
  Colourway colourway,
  Brightness brightness, {
  SystemPalette? palette,
}) {
  final scheme = colorSchemeFor(colourway, brightness, palette: palette);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    fontFamily: HorizontType.family,
    textTheme: horizontTextTheme(scheme.onSurface),
    scaffoldBackgroundColor: scheme.surfaceContainer,
    // Press feedback is the squish of the shared controls, not a ripple.
    splashFactory: NoSplash.splashFactory,
    // Predictive back on Android 14+ for every screen route (PLAN 1.4).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: HorizontType.bodyMedium.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: HorizontType.headline.copyWith(color: scheme.onSurface),
      contentTextStyle: HorizontType.body.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 44),
        textStyle: HorizontType.bodyStrong,
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 44),
        textStyle: HorizontType.bodyStrong,
        shape: const StadiumBorder(),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: scheme.primary,
    ),
    extensions: [
      HorizontColors.fromScheme(scheme),
      const HorizontRadii(),
      const HorizontSpacing(),
      HorizontShadows.standard,
      const HorizontSizes(),
    ],
  );
}

/// Builds each theme once per (colourway, brightness, palette).
class ThemeCache {
  final _cache = <(Colourway, Brightness, SystemPalette?), ThemeData>{};

  ThemeData get(
    Colourway colourway,
    Brightness brightness, {
    SystemPalette? palette,
  }) => _cache.putIfAbsent((
    colourway,
    brightness,
    palette,
  ), () => buildHorizontTheme(colourway, brightness, palette: palette));
}
