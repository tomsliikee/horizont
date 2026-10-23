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
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Settings before the first frame, so the first frame has the right colours.
  final prefs = await SharedPreferences.getInstance();
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
      // A link from another app: it opens in the tab of the first frame,
      // which restoring keeps.
      container
          .read(tabsProvider.notifier)
          .updatePage(container.read(tabsProvider).activeId, url: uri);
      container.invalidate(webEngineProvider);
    }
    await container.read(tabsProvider.notifier).restore();
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
