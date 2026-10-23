import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/browser_shell.dart';
import 'app/frame_log.dart';
import 'app/horizont_app.dart';
import 'app/providers.dart';
import 'browser/browser_providers.dart';
import 'browser/tabs/tab_session.dart';
import 'browser/tabs/tabs_notifier.dart';
import 'browser/tabs/thumbnail_store.dart';
import 'data/db/app_database.dart';
import 'data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameLog().start();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Settings before the first frame, so the first frame has the right colours.
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsStoreProvider.overrideWithValue(SettingsStore(prefs)),
      tabsRepositoryProvider.overrideWithValue(
        DriftTabsRepository(AppDatabase.open()),
      ),
      engineFactoryProvider.overrideWithValue(makeWebViewEngine),
      thumbnailStoreProvider.overrideWithValue(ThumbnailStore()),
    ],
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HorizontApp(home: BrowserShell()),
    ),
  );
  // Tabs come back after the first frame; settings were ready before it.
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(container.read(tabsProvider.notifier).restore()),
  );
}
