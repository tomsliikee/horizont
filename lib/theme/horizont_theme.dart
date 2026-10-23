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
