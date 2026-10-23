// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Horizont';

  @override
  String get settings => 'Settings';

  @override
  String get privacyReportLabel => 'Privacy report · 7 days';

  @override
  String get trackersBlocked => 'Trackers blocked';

  @override
  String moreThanLastWeek(int count) {
    return '$count more than last week';
  }

  @override
  String get countedOnDevice => 'Counted on this device.';

  @override
  String get favourites => 'Favourites';

  @override
  String get frequentlyVisited => 'Frequently visited';

  @override
  String get readingList => 'Reading list';

  @override
  String readMinutes(int count) {
    return '$count min.';
  }

  @override
  String get back => 'Back';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get colourwayWallpaper => 'Wallpaper';

  @override
  String get colourwayBlue => 'Blue';

  @override
  String get colourwayViolet => 'Violet';

  @override
  String get colourwayGreen => 'Green';

  @override
  String get colourwayOrange => 'Orange';

  @override
  String get colourwayPink => 'Pink';

  @override
  String get forward => 'Forward';

  @override
  String get reload => 'Reload';

  @override
  String get menu => 'Menu';

  @override
  String get searchOrEnterAddress => 'Search or address';

  @override
  String get cancel => 'Cancel';

  @override
  String get linkNeedsOtherApp =>
      'This link needs another app and was not opened.';

  @override
  String get tabs => 'Tabs';

  @override
  String tabsOpen(int count) {
    return '$count open';
  }

  @override
  String tabsOpenInGroup(int count, String group) {
    return '$count open · Group “$group”';
  }

  @override
  String get newTab => 'New tab';

  @override
  String get done => 'Done';

  @override
  String get closeTab => 'Close tab';

  @override
  String get privateMode => 'Private';

  @override
  String tabsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabs',
      one: '1 tab',
    );
    return '$_temp0';
  }

  @override
  String get startPage => 'Start page';
}
