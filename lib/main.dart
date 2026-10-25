import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/browser_shell.dart';
import 'app/frame_log.dart';
import 'app/horizont_app.dart';
import 'app/providers.dart';
import 'browser/browser_providers.dart';
import 'browser/tabs/away_watcher.dart';
import 'browser/tabs/tab_session.dart';
import 'browser/tabs/tabs_notifier.dart';
import 'browser/tabs/thumbnail_store.dart';
import 'data/db/app_database.dart';
import 'data/library_providers.dart';
import 'data/repositories/drift_library.dart';
import 'data/settings_store.dart';
import 'platform/downloads_service.dart';
import 'platform/horizont_webkit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameLog().start();
  LicenseRegistry.addLicense(_bundledLicences);
  // Settings before the first frame, so the first frame has the right
  // colours. The system calls run meanwhile instead of one after the other;
  // the manifest already asks for portrait (PLAN N4).
  final loading = SharedPreferences.getInstance();
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );
  final prefs = await loading;
  final db = AppDatabase.open();
  final container = ProviderContainer(
    overrides: [
      settingsStoreProvider.overrideWithValue(SettingsStore(prefs)),
      tabsRepositoryProvider.overrideWithValue(DriftTabsRepository(db)),
      libraryProvider.overrideWithValue(DriftLibrary(db)),
      engineFactoryProvider.overrideWith(
        (ref) =>
            (tab) => makeWebViewEngine(tab, ref),
      ),
      thumbnailStoreProvider.overrideWithValue(ThumbnailStore()),
      downloadsServiceProvider.overrideWith(BackgroundDownloadsService.new),
    ],
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HorizontApp(home: BrowserShell()),
    ),
  );
  // Tabs come back after the first frame; settings were ready before it.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initial = await HorizontWebKit.initialUrl();
    final uri = initial == null ? null : Uri.tryParse(initial);
    if (uri != null) {
      // A link from another app: restoring keeps the tab it opens in.
      container.read(tabsProvider.notifier).openLink(uri);
      container.invalidate(webEngineProvider);
    }
    await container.read(tabsProvider.notifier).restore();
    container.read(awayWatcherProvider).start();
    // Profiles of earlier private sessions (PLAN 4.4).
    unawaited(HorizontWebKit.deleteProfiles(TabSession.privatePrefix));
    unawaited(container.read(downloadsServiceProvider).start());
  });
}

/// The licences of what ships in `assets/` besides the packages.
Stream<LicenseEntry> _bundledLicences() async* {
  Future<String> read(String key) => rootBundle.loadString(key);
  yield LicenseEntryWithLineBreaks(const [
    'Readability.js',
  ], await read('assets/js/readability.LICENSE.md'));
  yield LicenseEntryWithLineBreaks(const [
    'EasyPrivacy',
  ], await read('assets/blocklist/LICENSE.txt'));
  yield LicenseEntryWithLineBreaks(const [
    'Google Sans Flex',
  ], await read('assets/fonts/OFL.txt'));
}
