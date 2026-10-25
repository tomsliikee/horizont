import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/bars/bar_actions.dart';
import 'package:horizont/browser/bars/browser_bars.dart';
import 'package:horizont/browser/browser_providers.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void main() {
  void noop() {}
  const actions = BarActions(
    forward: null,
    reload: _noop,
    search: _noop,
    menu: _noop,
    tabs: _noop,
    library: _noop,
    share: _noop,
    newTab: _noop,
    home: _noop,
    reader: _noop,
    tabCount: 4,
  );
  final page = PageState(
    url: Uri.parse('https://www.bergzeit.example/herbst'),
    title: 'Herbst am Schafberg',
    loading: true,
    progress: 0.6,
    canGoBack: true,
  );
  noop();

  Widget bars(BarLayout layout, {BarMode mode = BarMode.full}) => ColoredBox(
    color: const Color(0xFFEDE7DC),
    child: BrowserBars(
      layout: layout,
      page: page,
      actions: actions,
      mode: mode,
      keyboardUp: false,
      engineLabel: 'Google',
      onExpand: _noop,
    ),
  );

  for (final layout in BarLayout.values) {
    for (final dark in [false, true]) {
      final name = '${layout.name}_${dark ? 'dark' : 'light'}';
      testWidgets('bar $name', (tester) async {
        await pumpApp(
          tester,
          Scaffold(body: bars(layout)),
          settings: Settings(
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            colourway: Colourway.blue,
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('../goldens/bar_$name.png'),
        );
      });
    }
  }

  testWidgets('a shrunk bar shows the minimal pill and expands on tap', (
    tester,
  ) async {
    var expanded = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: BrowserBars(
          layout: BarLayout.kompakt,
          page: page,
          actions: actions,
          mode: BarMode.shrunk,
          keyboardUp: false,
          engineLabel: 'Google',
          onExpand: () => expanded++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Two addresses are built (the full bar faded out, the pill); the pill
    // is the one that takes taps.
    await tester.tap(find.text('bergzeit.example').last);
    expect(expanded, 1);
  });

  group('home in place of back', () {
    for (final layout in BarLayout.values.where(
      (l) => l != BarLayout.minimal,
    )) {
      testWidgets('${layout.name}: home on a page, dimmed on start', (
        tester,
      ) async {
        var homes = 0;
        var searches = 0;
        final counting = BarActions(
          forward: null,
          reload: _noop,
          search: () => searches++,
          menu: _noop,
          tabs: _noop,
          library: _noop,
          share: _noop,
          newTab: _noop,
          home: () => homes++,
          reader: _noop,
        );
        Future<void> show(PageState state) => pumpApp(
          tester,
          Scaffold(
            body: BrowserBars(
              layout: layout,
              page: state,
              actions: counting,
              mode: BarMode.full,
              keyboardUp: false,
              engineLabel: 'Google',
              onExpand: _noop,
            ),
          ),
        );
        // The top layout's home is the "Start" pill.
        final home = layout == BarLayout.oben
            ? find.text('Start')
            : find.bySemanticsLabel('Home');

        await show(page);
        expect(find.bySemanticsLabel('Back'), findsNothing);
        await tester.tap(home);
        expect(homes, 1);

        await show(const PageState());
        await tester.tap(home, warnIfMissed: false);
        expect(homes, 1);
        if (layout == BarLayout.oben) expect(searches, 1);
      });
    }
  });
}

void _noop() {}
