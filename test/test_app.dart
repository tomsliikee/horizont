import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/horizont_app.dart';
import 'package:horizont/app/providers.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';
import 'package:horizont/browser/tabs/tab_session.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/browser/tabs/thumbnail_store.dart';
import 'package:horizont/data/repositories/tabs_repository.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/data/library_providers.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/data/settings_store.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The time of every test: goldens must not change with the day.
final testNow = DateTime(2026, 10, 23, 10, 30);

/// The prototype's screen size.
const prototypeSize = Size(412, 915);

/// Loads the real fonts: without them Flutter draws with Ahem and every
/// measure is meaningless.
Future<void> loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = File(path).readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  await load('Google Sans Flex', 'assets/fonts/GoogleSansFlex.ttf');
  await load(
    'packages/material_symbols_icons/MaterialSymbolsRounded',
    _symbolsFontPath(),
  );
}

String _symbolsFontPath() {
  final config = File('.dart_tool/package_config.json').readAsStringSync();
  final match = RegExp(
    r'"name": "material_symbols_icons",\s*"rootUri": "([^"]+)"',
  ).firstMatch(config)!;
  final root = Uri.parse(match.group(1)!);
  final dir = root.isAbsolute
      ? root.toFilePath()
      : Directory('.dart_tool').uri.resolveUri(root).toFilePath();
  return '${dir.endsWith('/') ? dir : '$dir/'}lib/fonts/MaterialSymbolsRounded.ttf';
}

/// Pumps [home] in the app with [settings] at the prototype size.
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  Settings settings = const Settings(colourway: Colourway.blue),
  Library? library,
  WebEngine Function(BrowserTab tab)? engineFactory,
}) => pumpAppWith(
  tester,
  home,
  settings: settings,
  library: library,
  engineFactory: engineFactory,
);

/// [pumpApp] with extra provider [overrides].
Future<void> pumpAppWith(
  WidgetTester tester,
  Widget home, {
  Settings settings = const Settings(colourway: Colourway.blue),
  List<Override> overrides = const [],

  /// How tabs get their web view; fakes by default.
  WebEngine Function(BrowserTab tab)? engineFactory,
  Library? library,
}) async {
  await loadFonts();
  SharedPreferences.setMockInitialValues({'settings': settings.toJson()});
  final prefs = await SharedPreferences.getInstance();
  tester.view
    ..physicalSize = prototypeSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(SettingsStore(prefs)),
        systemPaletteProvider.overrideWith((ref) async => null),
        tabsRepositoryProvider.overrideWithValue(InMemoryTabsRepository()),
        engineFactoryProvider.overrideWithValue(
          engineFactory ?? (_) => FakeWebEngine(),
        ),
        thumbnailStoreProvider.overrideWithValue(
          ThumbnailStore(() async => Directory.systemTemp),
        ),
        libraryProvider.overrideWithValue(library ?? MemoryLibrary()),
        clockProvider.overrideWithValue(() => testNow),
        ...overrides,
      ],
      child: HorizontApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}
