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
}
