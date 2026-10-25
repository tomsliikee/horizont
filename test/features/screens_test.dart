import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/browser_shell.dart';
import 'package:horizont/app/providers.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/features/downloads/downloads_page.dart';
import 'package:horizont/features/library/library_page.dart';
import 'package:horizont/features/menu/menu_sheet.dart';
import 'package:horizont/features/private/private_page.dart';
import 'package:horizont/features/search/search_page.dart';
import 'package:horizont/features/settings/appearance_page.dart';
import 'package:horizont/features/settings/engine_page.dart';
import 'package:horizont/features/settings/more_settings.dart';
import 'package:horizont/features/settings/privacy_page.dart';
import 'package:horizont/features/settings/settings_page.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:horizont/ui/controls.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

/// A library with something in every list, as on a phone in use.
Future<MemoryLibrary> filledLibrary() async {
  final l = MemoryLibrary();
  final t = testNow;
  await l.recordVisit(
    Uri.parse('https://bergzeit.example/herbst'),
    'Herbst am Schafberg',
    t,
  );
  await l.recordVisit(
    Uri.parse('https://schafbergbahn.example/'),
    'Schafbergbahn – Fahrplan',
    t.subtract(const Duration(minutes: 11)),
  );
  await l.recordVisit(
    Uri.parse('https://geosphere.example/wetter'),
    'Wetter Salzburg – 7 Tage',
    t.subtract(const Duration(hours: 1)),
  );
  await l.recordVisit(
    Uri.parse('https://chefkoch.example/kuerbis'),
    'Kürbissuppe mit Ingwer',
    t.subtract(const Duration(hours: 13)),
  );
  await l.recordVisit(
    Uri.parse('https://de.wikipedia.org/wiki/Wolfgangsee'),
    'Wolfgangsee – Wikipedia',
    t.subtract(const Duration(hours: 16)),
  );
  await l.createFolder(
    'Studium',
    icon: FolderIcon.school,
    tone: FolderTone.secondary,
  );
  await l.createFolder(
    'Reisen',
    icon: FolderIcon.hiking,
    tone: FolderTone.tertiary,
  );
  await l.addReading(
    Uri.parse('https://bergzeit.example/herbst'),
    'Herbst am Schafberg',
    t,
    minutes: 8,
  );
  await l.updateReading(
    Uri.parse('https://bergzeit.example/herbst'),
    readFraction: 0.5,
  );
  await l.addReading(
    Uri.parse('https://m3.example/expressive'),
    'Was Material 3 Expressive anders macht',
    t,
    minutes: 12,
  );
  await l.putDownload(
    DownloadItem(
      taskId: 'a',
      url: Uri.parse('https://uni.example/ADS_Folien_Kapitel3.pdf'),
      fileName: 'ADS_Folien_Kapitel3.pdf',
      mimeType: 'application/pdf',
      totalBytes: 18000000,
      receivedBytes: 12400000,
      status: DownloadStatus.running,
      startedAt: t,
    ),
  );
  await l.putDownload(
    DownloadItem(
      taskId: 'b',
      url: Uri.parse('https://bergzeit.example/karte.pdf'),
      fileName: 'Schafberg_Tourenkarte.pdf',
      mimeType: 'application/pdf',
      totalBytes: 4800000,
      receivedBytes: 4800000,
      status: DownloadStatus.done,
      startedAt: t.subtract(const Duration(minutes: 30)),
      finishedAt: t.subtract(const Duration(minutes: 29)),
    ),
  );
  await l.putDownload(
    DownloadItem(
      taskId: 'c',
      url: Uri.parse('https://chefkoch.example/k.jpg'),
      fileName: 'Kuerbissuppe.jpg',
      mimeType: 'image/jpeg',
      totalBytes: 1200000,
      receivedBytes: 1200000,
      status: DownloadStatus.done,
      startedAt: t.subtract(const Duration(hours: 2)),
      finishedAt: t.subtract(const Duration(hours: 2)),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await l.addBlocked('site$i.example', 7 + i, t.subtract(Duration(days: i)));
  }
  await l.addBlocked('old.example', 20, t.subtract(const Duration(days: 9)));
  return l;
}

void main() {
  final screens = <String, Widget Function()>{
    'settings': () => const SettingsPage(),
    'appearance': () => const AppearancePage(),
    'engine': () => const EnginePage(),
    'privacy': () => const PrivacyPage(),
    'library': () => const LibraryPage(),
    'library_bookmarks': () =>
        const LibraryPage(initial: LibrarySection.bookmarks),
    'library_reading': () => const LibraryPage(initial: LibrarySection.reading),
    'downloads': () => const DownloadsPage(),
    'start_settings': () => const StartSettingsPage(),
    'about': () => const AboutPage(),
  };

  for (final MapEntry(key: name, value: build) in screens.entries) {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      testWidgets('$name $mode', (tester) async {
        await pumpApp(
          tester,
          build(),
          library: await filledLibrary(),
          settings: Settings(
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            colourway: Colourway.blue,
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/${name}_$mode.png'),
        );
      });
    }
  }

  testWidgets('private page', (tester) async {
    await pumpApp(
      tester,
      const PrivatePage(),
      settings: const Settings(
        themeMode: ThemeMode.dark,
        colourway: Colourway.blue,
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/private_dark.png'),
    );
  });

  Future<(FakeWebEngine, MemoryLibrary)> shellOnPage(
    WidgetTester tester, {
    Settings settings = const Settings(colourway: Colourway.blue),
  }) async {
    final engine = FakeWebEngine()..titleFor = (_) => 'Herbst am Schafberg';
    final library = await filledLibrary();
    // The first tab gets [engine]; tabs opened later get their own.
    var made = 0;
    await pumpApp(
      tester,
      const BrowserShell(),
      library: library,
      engineFactory: (_) => made++ == 0 ? engine : FakeWebEngine(),
      settings: settings,
    );
    await engine.load(Uri.parse('https://bergzeit.example/herbst'));
    await tester.pumpAndSettle();
    return (engine, library);
  }

  testWidgets('the menu grows open and saves the page in the favourites', (
    tester,
  ) async {
    final (_, library) = await shellOnPage(tester);
    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuSheet), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/menu_light.png'),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuSheet), findsNothing);
    expect(
      await library.bookmarksOf(Uri.parse('https://bergzeit.example/herbst')),
      hasLength(1),
    );
    expect(find.textContaining('Saved to'), findsOneWidget);
  });

  testWidgets(
    'the menu reader switch, text size and desktop site reach the page',
    (tester) async {
      final (engine, _) = await shellOnPage(tester);
      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Bigger'));
      await tester.pumpAndSettle();
      expect(engine.textZoom, 110);
      await tester.tap(find.text('Request desktop site'));
      await tester.pumpAndSettle();
      expect(engine.state.value.desktop, isTrue);
      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(HorizontSwitch));
      await tester.pumpAndSettle();
      expect(engine.state.value.reader, isTrue);
    },
  );

  testWidgets('find in page: the bar becomes the find pill', (tester) async {
    final (engine, _) = await shellOnPage(tester);
    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Schaf');
    await tester.pump(const Duration(milliseconds: 200));
    expect(engine.finds.last, 'Schaf');
    await tester.tap(find.bySemanticsLabel('Close find'));
    await tester.pumpAndSettle();
    expect(engine.findClears, greaterThan(0));
  });

  testWidgets('search: typing shows the top hit, a tap opens it', (
    tester,
  ) async {
    final (engine, _) = await shellOnPage(tester);
    await tester.tap(find.text('bergzeit.example').first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'schaf');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/search_light.png'),
    );
    await tester.tap(find.text('Top hit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Herbst am Schafberg').first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsNothing);
    expect(
      engine.state.value.url,
      Uri.parse('https://bergzeit.example/herbst'),
    );
  });

  testWidgets('a layout picked in Design & colour applies at once', (
    tester,
  ) async {
    await pumpApp(tester, const AppearancePage());
    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AppearancePage)),
    );
    expect(container.read(settingsProvider).barLayout, BarLayout.karte);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
  });

  testWidgets('the menu opens a private tab with the private page', (
    tester,
  ) async {
    await shellOnPage(tester);
    await tester.tap(find.bySemanticsLabel('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Private tab'));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    expect(container.read(tabsProvider).privateMode, isTrue);
    expect(find.byType(PrivatePage), findsOneWidget);
    await tester.tap(find.text('Leave private mode'));
    await tester.pumpAndSettle();
    expect(container.read(tabsProvider).privateTabs, isEmpty);
  });

  testWidgets('a history row opens its page from the library', (tester) async {
    LibraryResult? result;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              result = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const LibraryPage())),
          child: const Text('open'),
        ),
      ),
      library: await filledLibrary(),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kürbissuppe mit Ingwer'));
    await tester.pumpAndSettle();
    expect(result?.url, Uri.parse('https://chefkoch.example/kuerbis'));
  });
}
