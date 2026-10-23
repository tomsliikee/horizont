import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/dev/gallery_page.dart';
import 'package:horizont/features/start/start_page.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void main() {
  // Goldens are reviewed by looking at them next to referenz/screens/, not by
  // trusting a pixel diff against a browser rendering.
  for (final dark in [false, true]) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    final name = dark ? 'dark' : 'light';
    testWidgets('start page $name', (tester) async {
      await pumpApp(
        tester,
        const StartPage(),
        settings: Settings(themeMode: mode, colourway: Colourway.blue),
      );
      await expectLater(
        find.byType(StartPage),
        matchesGoldenFile('../goldens/start_$name.png'),
      );
    });
    testWidgets('gallery $name', (tester) async {
      await pumpApp(
        tester,
        const GalleryPage(),
        settings: Settings(themeMode: mode, colourway: Colourway.blue),
      );
      await expectLater(
        find.byType(GalleryPage),
        matchesGoldenFile('../goldens/gallery_$name.png'),
      );
    });
  }

  testWidgets('every colourway builds the start page', (tester) async {
    for (final way in Colourway.values.where((w) => w != Colourway.wallpaper)) {
      await pumpApp(
        tester,
        const StartPage(),
        settings: Settings(colourway: way),
      );
      expect(find.text('Horizont'), findsOneWidget, reason: way.name);
      expect(tester.takeException(), isNull);
    }
  });
}
