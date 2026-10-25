import 'dart:ui' show ImageFilter;

import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/theme/extensions.dart';
import 'package:horizont/ui/floating_surface.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0045FC));

  Widget surface({required bool translucent, bool overPage = false}) =>
      MaterialApp(
        theme: ThemeData(
          colorScheme: scheme,
          extensions: [
            HorizontColors.fromScheme(scheme, translucent: translucent),
            HorizontShadows.standard,
          ],
        ),
        home: NoGlassBlur(
          off: overPage,
          child: const Center(
            child: FloatingSurface(child: SizedBox(width: 200, height: 56)),
          ),
        ),
      );

  Color glassOf(WidgetTester tester) {
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(FloatingSurface),
        matching: find.byType(DecoratedBox),
      ),
    );
    return boxes
        .map((b) => (b.decoration as BoxDecoration).color)
        .whereType<Color>()
        .single;
  }

  bool hasShadow(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(FloatingSurface),
          matching: find.byType(DecoratedBox),
        ),
      )
      .any((b) => (b.decoration as BoxDecoration).boxShadow != null);

  testWidgets('opaque glass by default, with a shadow and no blur', (
    tester,
  ) async {
    await tester.pumpWidget(surface(translucent: false));
    expect(glassOf(tester).a, 1);
    expect(hasShadow(tester), isTrue);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('translucent glass blurs, without a shadow', (tester) async {
    await tester.pumpWidget(surface(translucent: true));
    expect(glassOf(tester).a, lessThan(1));
    final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    expect(filter.filter, isA<ImageFilter>());
    expect(hasShadow(tester), isFalse);
  });

  testWidgets('over the page translucent glass does not blur', (tester) async {
    await tester.pumpWidget(surface(translucent: true, overPage: true));
    expect(glassOf(tester).a, lessThan(1));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
