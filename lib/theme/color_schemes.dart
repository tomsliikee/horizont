import 'package:material_ui/material_ui.dart';

import 'system_palette.dart';
import 'tokens.g.dart';

/// The colourways of Design & Farbe. [wallpaper] is Material You.
enum Colourway {
  wallpaper(null),
  blue('blau'),
  violet('violett'),
  green('gruen'),
  orange('orange'),
  pink('pink');

  const Colourway(this.tableId);

  /// The id of the prototype's table, null for [wallpaper].
  final String? tableId;

  /// The colourway used where none was chosen and the system has no palette.
  static const Colourway standard = blue;

  /// The seed `fromSeed` fills the roles the prototype does not list from.
  Color get seed => Color(switch (this) {
    Colourway.violet => TokenColors.fixed['seedViolet']!,
    Colourway.green => TokenColors.fixed['seedGreen']!,
    Colourway.orange => TokenColors.fixed['seedOrange']!,
    Colourway.pink => TokenColors.fixed['seedPink']!,
    _ => TokenColors.fixed['seedBlue']!,
  });
}

/// Index of each prototype role in a table row; see `TokenColourways.keys`.
int _i(String key) => TokenColourways.keys.indexOf(key);

/// The scheme of [colourway] in [brightness].
///
/// A fixed colourway takes the 23 roles of the prototype as they are (D2) and
/// `fromSeed(vibrant)` only fills the roles the prototype does not list. Blue
/// additionally takes every role of `tokens.json`. [wallpaper] uses the
/// system palette and falls back to blue where there is none.
ColorScheme colorSchemeFor(
  Colourway colourway,
  Brightness brightness, {
  SystemPalette? palette,
}) {
  if (colourway == Colourway.wallpaper && palette != null) {
    return brightness == Brightness.dark ? palette.dark : palette.light;
  }
  final way = colourway == Colourway.wallpaper ? Colourway.standard : colourway;
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: way.seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
  );
  final row = (dark
      ? TokenColourways.dark
      : TokenColourways.light)[way.tableId]!;
  Color c(String key) => Color(row[_i(key)]);
  final tokens = dark ? TokenColors.dark : TokenColors.light;
  Color t(String name) => Color(tokens[name]!);

  var scheme = base.copyWith(
    primary: c('primary'),
    onPrimary: c('onPrimary'),
    primaryContainer: c('pCont'),
    onPrimaryContainer: c('onPCont'),
    secondary: c('sec'),
    onSecondary: c('onSec'),
    secondaryContainer: c('sCont'),
    onSecondaryContainer: c('onSCont'),
    tertiary: c('ter'),
    onTertiary: c('onTer'),
    tertiaryContainer: c('tCont'),
    onTertiaryContainer: c('onTCont'),
    surfaceContainerLow: c('low'),
    surfaceContainer: c('sc'),
    surfaceContainerHigh: c('high'),
    surfaceContainerHighest: c('highest'),
    surfaceBright: c('bright'),
    onSurface: c('on'),
    onSurfaceVariant: c('onVar'),
    outline: c('outline'),
    outlineVariant: c('outVar'),
    inverseSurface: c('inv'),
    onInverseSurface: c('invOn'),
    error: t('error'),
    onError: t('onError'),
    errorContainer: t('errorContainer'),
    onErrorContainer: t('onErrorContainer'),
  );
  if (way == Colourway.blue) {
    scheme = scheme.copyWith(
      surface: t('surface'),
      surfaceContainerLowest: t('surfaceContainerLowest'),
      inversePrimary: t('inversePrimary'),
    );
  }
  return scheme;
}
