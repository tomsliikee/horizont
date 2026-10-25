import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';

/// Persists [Settings] as one versioned JSON object.
class SettingsStore {
  SettingsStore(this._prefs);

  static const _key = 'settings';

  final SharedPreferences _prefs;

  Settings load() => Settings.fromJson(_prefs.getString(_key));

  Future<void> save(Settings settings) =>
      _prefs.setString(_key, settings.toJson());

  static const _activeTabKey = 'activeTab';

  /// The tab that was in front when the app last ran; read before the first
  /// frame so it can be the one that loads.
  String? get activeTabId => _prefs.getString(_activeTabKey);

  Future<void> saveActiveTabId(String id) =>
      _prefs.setString(_activeTabKey, id);

  static const _awayKey = 'awaySince';

  /// When the app last went to the background, kept until it comes back, so
  /// the time away is known even after Android ended the process.
  DateTime? get awaySince {
    final ms = _prefs.getInt(_awayKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> saveAwaySince(DateTime? at) => at == null
      ? _prefs.remove(_awayKey)
      : _prefs.setInt(_awayKey, at.millisecondsSinceEpoch);

  static const _snapshotKey = 'activeTabSnapshot';

  /// The normal tab in front when the app last went away, small enough to
  /// read before the first frame: that frame then shows the right tab and
  /// its page starts loading at once, before the database is read
  /// (PLAN N4). Null when unknown or unreadable.
  ({String id, Uri? url, String title, double scrollY, String? thumbnailPath})?
  get activeSnapshot {
    final raw = _prefs.getString(_snapshotKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      final id = map['id'];
      if (id is! String) return null;
      final url = map['url'];
      final title = map['title'];
      final scrollY = map['scrollY'];
      final thumbnail = map['thumbnailPath'];
      return (
        id: id,
        url: url is String ? Uri.tryParse(url) : null,
        title: title is String ? title : '',
        scrollY: scrollY is num ? scrollY.toDouble() : 0,
        thumbnailPath: thumbnail is String ? thumbnail : null,
      );
    } on FormatException {
      return null;
    }
  }

  /// Written with every save of the tabs; unchanged ones are skipped.
  Future<void> saveActiveSnapshot({
    required String id,
    Uri? url,
    String title = '',
    double scrollY = 0,
    String? thumbnailPath,
  }) async {
    final json = jsonEncode({
      'id': id,
      'url': url?.toString(),
      'title': title,
      'scrollY': scrollY,
      'thumbnailPath': thumbnailPath,
    });
    if (json == _prefs.getString(_snapshotKey)) return;
    await _prefs.setString(_snapshotKey, json);
  }
}
