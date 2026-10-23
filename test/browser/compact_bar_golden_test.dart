import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/bars/bar_actions.dart';
import 'package:horizont/browser/bars/compact_bar.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void main() {
  void noop() {}
  final actions = BarActions(
    back: noop,
    forward: null,
    reload: noop,
    search: noop,
    menu: noop,
  );

  for (final dark in [false, true]) {
    final name = dark ? 'dark' : 'light';
    testWidgets('compact bar on a loading page, $name', (tester) async {
      await pumpApp(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: CompactBar(
              page: PageState(
                url: Uri.parse('https://www.bergzeit.example/herbst'),
                loading: true,
                progress: 0.6,
                canGoBack: true,
              ),
              actions: actions,
            ),
          ),
        ),
        settings: Settings(
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          colourway: Colourway.blue,
        ),
      );
      await expectLater(
        find.byType(CompactBar),
        matchesGoldenFile('../goldens/compact_bar_$name.png'),
      );
    });
  }
}
