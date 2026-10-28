import 'dart:convert';

import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../browser/search_engines.dart';
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

/// After how long away the app opens a new tab with the start page
/// (PLAN N2, D27).
enum HomeAfterAway {
  never(null),
  halfHour(Duration(minutes: 30)),
  hour(Duration(hours: 1)),
  fourHours(Duration(hours: 4)),
  day(Duration(days: 1));

  const HomeAfterAway(this.after);
  final Duration? after;
}

/// How soft the edge under the status bar is: how far the page colour fades
/// out below the bar.
enum StatusBarBlur {
  off(0),
  soft(16),
  strong(32);

  const StatusBarBlur(this.edgeHeight);

  /// The height of the fade below the status bar, in logical pixels.
  final double edgeHeight;
}

/// The six bar layouts of Design & Farbe (PLAN 3).
enum BarLayout { kompakt, zweireihig, expressiv, oben, karte, minimal }

/// How strongly the app vibrates on touch.
enum HapticLevel { off, normal, strong }

/// The sections of the start page that can be switched off.
enum StartSection { favourites, frequent, readingList, privacyReport }

/// All settings (PLAN 1.5). New keys are added with a default, so older stored
/// objects stay readable without a version bump.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.colourway = Colourway.wallpaper,
    this.barLayout = BarLayout.kompakt,
    this.tintFromPage = true,
    this.statusBarBlur = StatusBarBlur.soft,
    this.shrinkOnScroll = true,
    this.translucentBars = false,
    this.hideBarAtPageEnd = false,
    this.searchEngine = SearchEngine.google,
    this.searchSuggestions = true,
    this.groupTabs = true,
    this.autoCloseTabs = AutoCloseTabs.month,
    this.blockTracking = true,
    this.httpsOnly = true,
    this.fraudWarning = true,
    this.lockPrivateTabs = true,
    this.askBeforeDownload = true,
    this.forceZoom = false,
    this.textZoomByHost = const {},
    this.startSections = const {...StartSection.values},
    this.homeAfterAway = HomeAfterAway.hour,
    this.haptics = HapticLevel.normal,
    this.barRaise = 0,
    this.liftOverPageBars = true,
  });

  /// Bumped when a stored value changes meaning; [fromJson] migrates older
  /// objects and ignores newer ones.
  static const version = 1;

  final ThemeMode themeMode;
  final Colourway colourway;
  final BarLayout barLayout;

  /// "Websitefarbe übernehmen": the status bar takes the colour of the page.
  final bool tintFromPage;

  /// "Unschärfe": how far the status bar colour fades out below the bar.
  final StatusBarBlur statusBarBlur;

  /// "Beim Scrollen verkleinern": the bar shrinks to the minimal pill.
  final bool shrinkOnScroll;

  /// "Durchscheinend": the bars let the page show through, blurred (PLAN
  /// N5, D31). Off, they are opaque.
  final bool translucentBars;

  /// "Am Seitenende ausblenden" (D4).
  final bool hideBarAtPageEnd;
  final SearchEngine searchEngine;

  /// Typing is sent to the search engine for suggestions.
  final bool searchSuggestions;

  /// Tabs opened from another tab join its group (D13).
  final bool groupTabs;
  final AutoCloseTabs autoCloseTabs;

  /// "Websiteübergreifendes Tracking verhindern" (EasyPrivacy, D6).
  final bool blockTracking;
  final bool httpsOnly;

  /// Safe Browsing.
  final bool fraudWarning;
  final bool lockPrivateTabs;
  final bool askBeforeDownload;

  /// Bedienungshilfen: pages may be zoomed even where they forbid it.
  final bool forceZoom;

  /// Text size per host in percent (50–200); hosts at 100 are not stored.
  final Map<String, int> textZoomByHost;
  final Set<StartSection> startSections;

  /// "Startseite nach Abwesenheit".
  final HomeAfterAway homeAfterAway;

  /// "Haptik".
  final HapticLevel haptics;

  /// "Höhe der Leiste": how far the bottom bar sits above its usual place,
  /// in logical pixels (0 to [maxBarRaise]).
  final double barRaise;
  static const maxBarRaise = 48.0;

  /// "Über Seitenleisten ausweichen": the bar moves above a bar the page
  /// keeps at the bottom of the screen.
  final bool liftOverPageBars;

  int textZoomFor(String host) => textZoomByHost[host] ?? 100;

  /// [textZoomByHost] with [host] set to [percent].
  Settings withTextZoom(String host, int percent) {
    final next = {...textZoomByHost};
    if (percent == 100) {
      next.remove(host);
    } else {
      next[host] = percent.clamp(50, 200);
    }
    return copyWith(textZoomByHost: next);
  }

  Settings copyWith({
    ThemeMode? themeMode,
    Colourway? colourway,
    BarLayout? barLayout,
    bool? tintFromPage,
    StatusBarBlur? statusBarBlur,
    bool? shrinkOnScroll,
    bool? translucentBars,
    bool? hideBarAtPageEnd,
    SearchEngine? searchEngine,
    bool? searchSuggestions,
    bool? groupTabs,
    AutoCloseTabs? autoCloseTabs,
    bool? blockTracking,
    bool? httpsOnly,
    bool? fraudWarning,
    bool? lockPrivateTabs,
    bool? askBeforeDownload,
    bool? forceZoom,
    Map<String, int>? textZoomByHost,
    Set<StartSection>? startSections,
    HomeAfterAway? homeAfterAway,
    HapticLevel? haptics,
    double? barRaise,
    bool? liftOverPageBars,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    colourway: colourway ?? this.colourway,
    barLayout: barLayout ?? this.barLayout,
    tintFromPage: tintFromPage ?? this.tintFromPage,
    statusBarBlur: statusBarBlur ?? this.statusBarBlur,
    shrinkOnScroll: shrinkOnScroll ?? this.shrinkOnScroll,
    translucentBars: translucentBars ?? this.translucentBars,
    hideBarAtPageEnd: hideBarAtPageEnd ?? this.hideBarAtPageEnd,
    searchEngine: searchEngine ?? this.searchEngine,
    searchSuggestions: searchSuggestions ?? this.searchSuggestions,
    groupTabs: groupTabs ?? this.groupTabs,
    autoCloseTabs: autoCloseTabs ?? this.autoCloseTabs,
    blockTracking: blockTracking ?? this.blockTracking,
    httpsOnly: httpsOnly ?? this.httpsOnly,
    fraudWarning: fraudWarning ?? this.fraudWarning,
    lockPrivateTabs: lockPrivateTabs ?? this.lockPrivateTabs,
    askBeforeDownload: askBeforeDownload ?? this.askBeforeDownload,
    forceZoom: forceZoom ?? this.forceZoom,
    textZoomByHost: textZoomByHost ?? this.textZoomByHost,
    startSections: startSections ?? this.startSections,
    homeAfterAway: homeAfterAway ?? this.homeAfterAway,
    haptics: haptics ?? this.haptics,
    barRaise: barRaise ?? this.barRaise,
    liftOverPageBars: liftOverPageBars ?? this.liftOverPageBars,
  );

  String toJson() => jsonEncode({
    'version': version,
    'themeMode': themeMode.name,
    'colourway': colourway.name,
    'barLayout': barLayout.name,
    'tintFromPage': tintFromPage,
    'statusBarBlur': statusBarBlur.name,
    'shrinkOnScroll': shrinkOnScroll,
    'translucentBars': translucentBars,
    'hideBarAtPageEnd': hideBarAtPageEnd,
    'searchEngine': searchEngine.name,
    'searchSuggestions': searchSuggestions,
    'groupTabs': groupTabs,
    'autoCloseTabs': autoCloseTabs.name,
    'blockTracking': blockTracking,
    'httpsOnly': httpsOnly,
    'fraudWarning': fraudWarning,
    'lockPrivateTabs': lockPrivateTabs,
    'askBeforeDownload': askBeforeDownload,
    'forceZoom': forceZoom,
    'textZoomByHost': textZoomByHost,
    'startSections': [for (final s in startSections) s.name],
    'homeAfterAway': homeAfterAway.name,
    'haptics': haptics.name,
    'barRaise': barRaise,
    'liftOverPageBars': liftOverPageBars,
  });

  /// Reads [source]; anything unreadable, or from a newer version, gives the
  /// defaults rather than a half-understood object. Missing or malformed keys
  /// take their default one by one.
  static Settings fromJson(String? source) {
    if (source == null) return const Settings();
    try {
      final map = jsonDecode(source);
      if (map is! Map<String, dynamic>) return const Settings();
      final v = map['version'];
      if (v is! int || v > version) return const Settings();
      const d = Settings();
      bool flag(String key, bool fallback) =>
          map[key] is bool ? map[key] as bool : fallback;
      T pick<T extends Enum>(List<T> values, String key, T fallback) =>
          values.asNameMap()[map[key]] ?? fallback;
      final zoom = <String, int>{};
      final rawZoom = map['textZoomByHost'];
      if (rawZoom is Map) {
        rawZoom.forEach((key, value) {
          if (key is String && value is int && value >= 50 && value <= 200) {
            zoom[key] = value;
          }
        });
      }
      final rawSections = map['startSections'];
      final sections = rawSections is List
          ? {for (final s in rawSections) ?StartSection.values.asNameMap()[s]}
          : d.startSections;
      return Settings(
        themeMode: pick(ThemeMode.values, 'themeMode', d.themeMode),
        colourway: pick(Colourway.values, 'colourway', d.colourway),
        barLayout: pick(BarLayout.values, 'barLayout', d.barLayout),
        tintFromPage: flag('tintFromPage', d.tintFromPage),
        statusBarBlur: pick(
          StatusBarBlur.values,
          'statusBarBlur',
          d.statusBarBlur,
        ),
        shrinkOnScroll: flag('shrinkOnScroll', d.shrinkOnScroll),
        translucentBars: flag('translucentBars', d.translucentBars),
        hideBarAtPageEnd: flag('hideBarAtPageEnd', d.hideBarAtPageEnd),
        searchEngine: pick(SearchEngine.values, 'searchEngine', d.searchEngine),
        searchSuggestions: flag('searchSuggestions', d.searchSuggestions),
        groupTabs: flag('groupTabs', d.groupTabs),
        autoCloseTabs: pick(
          AutoCloseTabs.values,
          'autoCloseTabs',
          d.autoCloseTabs,
        ),
        blockTracking: flag('blockTracking', d.blockTracking),
        httpsOnly: flag('httpsOnly', d.httpsOnly),
        fraudWarning: flag('fraudWarning', d.fraudWarning),
        lockPrivateTabs: flag('lockPrivateTabs', d.lockPrivateTabs),
        askBeforeDownload: flag('askBeforeDownload', d.askBeforeDownload),
        forceZoom: flag('forceZoom', d.forceZoom),
        textZoomByHost: zoom,
        startSections: sections,
        homeAfterAway: pick(
          HomeAfterAway.values,
          'homeAfterAway',
          d.homeAfterAway,
        ),
        haptics: pick(HapticLevel.values, 'haptics', d.haptics),
        barRaise: map['barRaise'] is num
            ? (map['barRaise'] as num).toDouble().clamp(0, maxBarRaise)
            : d.barRaise,
        liftOverPageBars: flag('liftOverPageBars', d.liftOverPageBars),
      );
    } on FormatException {
      return const Settings();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Settings && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;
}
