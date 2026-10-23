import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings.dart';
import '../data/settings_store.dart';
import '../theme/system_palette.dart';

/// Overridden in `main` once preferences are loaded, before the first frame.
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider not overridden'),
);

/// The palette Material You derived from the wallpaper; null without one.
final systemPaletteProvider = FutureProvider<SystemPalette?>(
  (ref) => loadSystemPalette(),
);

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => ref.watch(settingsStoreProvider).load();

  void update(Settings Function(Settings) change) {
    state = change(state);
    ref.read(settingsStoreProvider).save(state);
  }
}
