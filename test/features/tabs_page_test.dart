import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/bars/browser_bars.dart';
import 'package:horizont/app/browser_shell.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/status_bar/page_message.dart';
import 'package:horizont/browser/status_bar/status_bar_provider.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/features/tabs/tabs_page.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:horizont/ui/buttons.dart';
import 'package:horizont/ui/tab_card.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

/// [text] in the bar, not on the start page (which lists visited pages).
Finder inBar(String text) =>
    find.descendant(of: find.byType(BrowserBars), matching: find.text(text));

void main() {
  late Map<String, FakeWebEngine> engines;
  late int created;

  setUp(() {
    engines = {};
    created = 0;
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Widget home = const BrowserShell(),
    Settings settings = const Settings(colourway: Colourway.blue),
  }) async {
    await pumpAppWith(
      tester,
      home,
      settings: settings,
      engineFactory: (tab) {
        created++;
        return engines[tab.id] = FakeWebEngine();
      },
    );
    return ProviderScope.containerOf(
      tester.element(find.byType(home.runtimeType)),
    );
  }

  /// Six tabs like the prototype's overview; the first is in front.
  void seed(ProviderContainer c) {
    final n = c.read(tabsProvider.notifier);
    final first = c.read(tabsProvider).active;
    n.updatePage(
      first.id,
      url: Uri.parse('https://bergzeit.at/herbst'),
      title: 'Herbst am Schafberg',
      pageColor: const Color(0xFF1F3A2D),
    );
    const pages = [
      ('Schafbergbahn – Fahrplan', 'https://schafbergbahn.at/', 0xFF8B3A2B),
      ('Wetter Salzburg – 7 Tage', 'https://geosphere.at/', 0xFF2B5C8B),
      ('Wikipedia: Schafberg', 'https://de.wikipedia.org/', 0xFFFFFFFF),
      ('Chefkoch – Kaiserschmarrn', 'https://chefkoch.de/', 0xFFD9822B),
    ];
    for (final (title, url, color) in pages) {
      final tab = n.open(url: Uri.parse(url), activate: false);
      n.updatePage(tab.id, title: title, pageColor: Color(color));
    }
    n.activate(first.id);
  }

  Finder closeButtons() => find.byWidgetPredicate(
    (w) => w is RoundButton && w.semanticLabel == 'Close tab',
  );

  testWidgets('lists the tabs with the count and marks the one in front', (
    tester,
  ) async {
    final c = await pump(tester, home: const TabsPage());
    seed(c);
    await tester.pump();
    expect(find.text('5 open'), findsOneWidget);
    expect(find.text('5 tabs'), findsOneWidget);
    expect(find.byType(TabCard), findsNWidgets(5));
    expect(find.text('Herbst am Schafberg'), findsOneWidget);
    final cards = tester.widgetList<TabCard>(find.byType(TabCard)).toList();
    expect(cards.where((card) => card.active), hasLength(1));
    expect(cards.first.active, isTrue);
  });

  testWidgets('the subtitle names the group of the tab in front', (
    tester,
  ) async {
    final c = await pump(tester, home: const TabsPage());
    final n = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    n.updatePage(a.id, title: 'Schafberg');
    n.open(openerId: a.id);
    n.activate(a.id);
    await tester.pump();
    expect(find.text('2 open · Group “Schafberg”'), findsOneWidget);
  });

  testWidgets('closing a card removes it; the last close leaves a new tab', (
    tester,
  ) async {
    final c = await pump(tester, home: const TabsPage());
    seed(c);
    await tester.pump();
    // The card shrinks away first, then it is gone.
    await tester.tap(closeButtons().at(1));
    await tester.pump();
    expect(find.byType(TabCard), findsNWidgets(5));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(TabCard), findsNWidgets(4));
    for (var i = 0; i < 4; i++) {
      await tester.tap(closeButtons().first);
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(TabCard), findsOneWidget);
    expect(find.text('Start page'), findsOneWidget);
    expect(c.read(tabsProvider).tabs, hasLength(1));
  });

  testWidgets('a long press on the menu button opens the overview; a card '
      'brings its tab forward and closes the overview', (tester) async {
    final c = await pump(tester);
    seed(c);
    await tester.pump();
    final menu = find.byWidgetPredicate(
      (w) => w is RoundButton && w.semanticLabel == 'Menu',
    );
    await tester.longPress(menu);
    await tester.pumpAndSettle();
    expect(find.byType(TabsPage), findsOneWidget);

    final target = c.read(tabsProvider).tabs[2];
    await tester.tap(find.text(target.title));
    await tester.pumpAndSettle();
    expect(find.byType(TabsPage), findsNothing);
    expect(c.read(tabsProvider).activeId, target.id);
  });

  testWidgets('the plus button opens an empty tab and returns to the browser', (
    tester,
  ) async {
    final c = await pump(tester);
    seed(c);
    await tester.longPress(
      find.byWidgetPredicate(
        (w) => w is RoundButton && w.semanticLabel == 'Menu',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is RoundButton && w.semanticLabel == 'New tab',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TabsPage), findsNothing);
    expect(c.read(tabsProvider).tabs, hasLength(6));
    expect(c.read(tabsProvider).active.url, isNull);
  });

  group('the browser follows the tab in front', () {
    testWidgets('each tab has its own view and page', (tester) async {
      final c = await pump(tester);
      final n = c.read(tabsProvider.notifier);
      final first = c.read(tabsProvider).active;
      await engines[first.id]!.load(Uri.parse('https://a.example/'));
      await tester.pump();
      expect(inBar('a.example'), findsOneWidget);

      n.open();
      await tester.pump();
      expect(created, 2);
      expect(inBar('a.example'), findsNothing);
      expect(inBar('Search or address'), findsOneWidget);

      n.activate(first.id);
      await tester.pump();
      expect(inBar('a.example'), findsOneWidget);
      expect(created, 2);
    });

    testWidgets('a tab keeps its status bar colour when it comes back', (
      tester,
    ) async {
      final c = await pump(tester);
      final n = c.read(tabsProvider.notifier);
      final first = c.read(tabsProvider).active;
      await engines[first.id]!.load(Uri.parse('https://a.example/'));
      engines[first.id]!.report(
        const ColorMessage(Color(0xFF1F3A2D), ColorSource.dom),
      );
      await tester.pump();
      expect(c.read(tabsProvider).active.pageColor, const Color(0xFF1F3A2D));

      n.open();
      await tester.pump();
      n.activate(first.id);
      await tester.pump();
      expect(c.read(statusBarProvider).pageColor, const Color(0xFF1F3A2D));
    });

    testWidgets('a fourth tab pushes out the least recently used view', (
      tester,
    ) async {
      final c = await pump(tester);
      final n = c.read(tabsProvider.notifier);
      final first = c.read(tabsProvider).active;
      await engines[first.id]!.load(Uri.parse('https://a.example/'));
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        n.open();
        await tester.pump();
        await tester.pump();
      }
      expect(created, 4);
      expect(engines[first.id]!.disposed, isTrue);
      expect(engines.values.where((e) => !e.disposed), hasLength(3));
      // The stored tab keeps its address, so it loads again when opened.
      expect(c.read(tabsProvider).byId(first.id)!.url, isNotNull);
      n.activate(first.id);
      await tester.pump();
      expect(created, 5);
    });

    testWidgets('leaving a tab saves how far its page is scrolled, and a '
        'reopened tab loads there', (tester) async {
      final c = await pump(tester);
      final n = c.read(tabsProvider.notifier);
      final first = c.read(tabsProvider).active;
      await engines[first.id]!.load(Uri.parse('https://a.example/'));
      engines[first.id]!.scrollY = 1840;
      await tester.pump();
      n.open();
      await tester.pump();
      await tester.pump();
      expect(c.read(tabsProvider).byId(first.id)!.scrollY, 1840);

      // Push the first view out, then open it again.
      for (var i = 0; i < 3; i++) {
        n.open();
        await tester.pump();
        await tester.pump();
      }
      expect(engines[first.id]!.disposed, isTrue);
      n.activate(first.id);
      await tester.pump();
      await tester.pump();
      expect(engines[first.id]!.loads.single.$2, 1840);
    });

    testWidgets('back on a tab opened from another closes it', (tester) async {
      final c = await pump(tester);
      final n = c.read(tabsProvider.notifier);
      final opener = c.read(tabsProvider).active;
      final child = n.open(openerId: opener.id);
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pump();
      final state = c.read(tabsProvider);
      expect(state.activeId, opener.id);
      expect(state.byId(child.id), isNull);
    });
  });

  for (final dark in [false, true]) {
    final name = dark ? 'dark' : 'light';
    testWidgets('tab overview $name', (tester) async {
      final c = await pump(
        tester,
        home: const TabsPage(),
        settings: Settings(
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          colourway: Colourway.blue,
        ),
      );
      seed(c);
      await tester.pump();
      await expectLater(
        find.byType(TabsPage),
        matchesGoldenFile('../goldens/tabs_$name.png'),
      );
    });
  }
}
