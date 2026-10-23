import 'dart:convert';

import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../theme/color_schemes.dart';

/// After how long unused tabs close by themselves (PLAN 1.5).
enum AutoCloseTabs {
  never(null),
  day(Duration(days: 1)),
  week(Duration(days: 7)),
  month(Duration(days: 30));

  const AutoCloseTabs(this.after);
  final Duration? after;
}

/// All settings. Only the keys milestone 1 needs exist; later milestones add
/// theirs under the same version rules.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.colourway = Colourway.wallpaper,
    this.tintFromPage = true,
    this.groupTabs = true,
    this.autoCloseTabs = AutoCloseTabs.month,
  });

  /// Bumped when a stored value changes meaning; [fromJson] migrates older
  /// objects and ignores newer ones.
  static const version = 1;

  final ThemeMode themeMode;
  final Colourway colourway;

  /// "Websitefarbe übernehmen": the status bar takes the colour of the page.
  final bool tintFromPage;

  /// Tabs opened from another tab join its group (D13).
  final bool groupTabs;
  final AutoCloseTabs autoCloseTabs;

  Settings copyWith({
    ThemeMode? themeMode,
    Colourway? colourway,
    bool? tintFromPage,
    bool? groupTabs,
    AutoCloseTabs? autoCloseTabs,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    colourway: colourway ?? this.colourway,
    tintFromPage: tintFromPage ?? this.tintFromPage,
    groupTabs: groupTabs ?? this.groupTabs,
    autoCloseTabs: autoCloseTabs ?? this.autoCloseTabs,
  );

  String toJson() => jsonEncode({
    'version': version,
    'themeMode': themeMode.name,
    'colourway': colourway.name,
    'tintFromPage': tintFromPage,
    'groupTabs': groupTabs,
    'autoCloseTabs': autoCloseTabs.name,
  });

  /// Reads [source]; anything unreadable, or from a newer version, gives the
  /// defaults rather than a half-understood object.
  static Settings fromJson(String? source) {
    if (source == null) return const Settings();
    try {
      final map = jsonDecode(source);
      if (map is! Map<String, dynamic>) return const Settings();
      final v = map['version'];
      if (v is! int || v > version) return const Settings();
      return Settings(
        themeMode:
            ThemeMode.values.asNameMap()[map['themeMode']] ?? ThemeMode.system,
        colourway:
            Colourway.values.asNameMap()[map['colourway']] ??
            Colourway.wallpaper,
        tintFromPage: map['tintFromPage'] is bool
            ? map['tintFromPage'] as bool
            : true,
        groupTabs: map['groupTabs'] is bool ? map['groupTabs'] as bool : true,
        autoCloseTabs:
            AutoCloseTabs.values.asNameMap()[map['autoCloseTabs']] ??
            AutoCloseTabs.month,
      );
    } on FormatException {
      return const Settings();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.themeMode == themeMode &&
      other.colourway == colourway &&
      other.tintFromPage == tintFromPage &&
      other.groupTabs == groupTabs &&
      other.autoCloseTabs == autoCloseTabs;

  @override
  int get hashCode =>
      Object.hash(themeMode, colourway, tintFromPage, groupTabs, autoCloseTabs);
}
