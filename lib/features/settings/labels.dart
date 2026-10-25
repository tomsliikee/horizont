import 'package:material_ui/material_ui.dart';

import '../../browser/search_engines.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/color_schemes.dart';
import '../../ui/tiles.dart';

String themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
  ThemeMode.light => l10n.themeLight,
  ThemeMode.dark => l10n.themeDark,
  ThemeMode.system => l10n.themeSystem,
};

String colourwayLabel(AppLocalizations l10n, Colourway way) => switch (way) {
  Colourway.wallpaper => l10n.colourwayWallpaper,
  Colourway.blue => l10n.colourwayBlue,
  Colourway.violet => l10n.colourwayViolet,
  Colourway.green => l10n.colourwayGreen,
  Colourway.orange => l10n.colourwayOrange,
  Colourway.pink => l10n.colourwayPink,
};

String layoutLabel(AppLocalizations l10n, BarLayout layout) => switch (layout) {
  BarLayout.kompakt => l10n.layoutKompakt,
  BarLayout.zweireihig => l10n.layoutZweireihig,
  BarLayout.expressiv => l10n.layoutExpressiv,
  BarLayout.oben => l10n.layoutOben,
  BarLayout.karte => l10n.layoutKarte,
  BarLayout.minimal => l10n.layoutMinimal,
};

String engineSubtitle(AppLocalizations l10n, SearchEngine engine) =>
    switch (engine) {
      SearchEngine.google => l10n.engineGoogleSub,
      SearchEngine.ecosia => l10n.engineEcosiaSub,
      SearchEngine.duckDuckGo => l10n.engineDdgSub,
      SearchEngine.startpage => l10n.engineStartpageSub,
      SearchEngine.bing => l10n.engineBingSub,
    };

String autoCloseLabel(AppLocalizations l10n, AutoCloseTabs value) =>
    switch (value) {
      AutoCloseTabs.never => l10n.autoCloseNever,
      AutoCloseTabs.day => l10n.autoCloseDay,
      AutoCloseTabs.week => l10n.autoCloseWeek,
      AutoCloseTabs.month => l10n.autoCloseMonth,
    };

String homeAfterAwayLabel(AppLocalizations l10n, HomeAfterAway value) =>
    switch (value) {
      HomeAfterAway.never => l10n.autoCloseNever,
      HomeAfterAway.halfHour => l10n.homeAfterHalfHour,
      HomeAfterAway.hour => l10n.homeAfterHour,
      HomeAfterAway.fourHours => l10n.homeAfterFourHours,
      HomeAfterAway.day => l10n.autoCloseDay,
    };

/// The boxes of each layout's mini screen (`lyDefs`, `P:924`).
List<PreviewBox> layoutBoxes(BarLayout layout) {
  PreviewBox b(double x, double y, double w, double h, double r, bool a) =>
      (x: x, y: y, w: w, h: h, r: r, accent: a);
  return switch (layout) {
    BarLayout.kompakt => [
      b(6, 94, 10, 10, 5, false),
      b(19, 94, 34, 10, 5, true),
      b(56, 94, 10, 10, 5, false),
    ],
    BarLayout.zweireihig => [
      b(10, 80, 52, 8, 4, true),
      b(6, 92, 60, 13, 6, false),
    ],
    BarLayout.expressiv => [
      b(20, 6, 32, 7, 4, true),
      b(6, 92, 44, 13, 6, false),
      b(53, 92, 13, 13, 4, true),
    ],
    BarLayout.oben => [b(6, 6, 60, 10, 5, true), b(6, 94, 60, 12, 6, false)],
    BarLayout.karte => [b(6, 80, 60, 11, 5, true), b(6, 93, 60, 12, 5, false)],
    BarLayout.minimal => [b(18, 98, 30, 7, 4, true), b(51, 98, 7, 7, 4, false)],
  };
}
