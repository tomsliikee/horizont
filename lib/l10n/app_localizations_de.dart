// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Horizont';

  @override
  String get settings => 'Einstellungen';

  @override
  String get privacyReportLabel => 'Datenschutzbericht · 7 Tage';

  @override
  String get trackersBlocked => 'Tracker blockiert';

  @override
  String moreThanLastWeek(int count) {
    return '$count mehr als letzte Woche';
  }

  @override
  String get countedOnDevice => 'Gezählt auf diesem Gerät.';

  @override
  String get favourites => 'Favoriten';

  @override
  String get frequentlyVisited => 'Häufig besucht';

  @override
  String get readingList => 'Leseliste';

  @override
  String readMinutes(int count) {
    return '$count Min.';
  }

  @override
  String get back => 'Zurück';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystem => 'System';

  @override
  String get colourwayWallpaper => 'Hintergrund';

  @override
  String get colourwayBlue => 'Blau';

  @override
  String get colourwayViolet => 'Violett';

  @override
  String get colourwayGreen => 'Grün';

  @override
  String get colourwayOrange => 'Orange';

  @override
  String get colourwayPink => 'Pink';

  @override
  String get forward => 'Vorwärts';

  @override
  String get reload => 'Neu laden';

  @override
  String get menu => 'Menü';

  @override
  String get searchOrEnterAddress => 'Suchen oder Adresse';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get linkNeedsOtherApp =>
      'Dieser Link braucht eine andere App und wurde nicht geöffnet.';

  @override
  String get tabs => 'Tabs';

  @override
  String tabsOpen(int count) {
    return '$count offen';
  }

  @override
  String tabsOpenInGroup(int count, String group) {
    return '$count offen · Gruppe „$group“';
  }

  @override
  String get newTab => 'Neuer Tab';

  @override
  String get done => 'Fertig';

  @override
  String get closeTab => 'Tab schließen';

  @override
  String get privateMode => 'Privat';

  @override
  String tabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tabs',
      one: '1 Tab',
    );
    return '$_temp0';
  }

  @override
  String get startPage => 'Startseite';
}
