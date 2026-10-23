import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/browser_shell.dart';
import 'package:horizont/browser/browser_providers.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/status_bar/page_message.dart';
import 'package:horizont/browser/status_bar/status_bar_tint.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:material_ui/material_ui.dart';

import '../../test_app.dart';

void main() {
  late FakeWebEngine engine;

  setUp(() => engine = FakeWebEngine());
  tearDown(() => engine.dispose());

  Future<void> pump(WidgetTester tester, {bool tint = true}) => pumpAppWith(
    tester,
    const BrowserShell(),
    settings: Settings(colourway: Colourway.blue, tintFromPage: tint),
    overrides: [webEngineProvider.overrideWithValue(engine)],
  );

  Color bandColor(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(StatusBarTint),
        matching: find.byType(CustomPaint),
      ),
    );
    // The painter is private to the widget; its colour is what is drawn.
    return (paint.painter! as dynamic).color as Color;
  }

  /// The spring converts through floats, so allow one step per channel.
  void expectColor(Color actual, Color expected) {
    expect(actual.a * 255, closeTo(expected.a * 255, 1));
    expect(actual.r * 255, closeTo(expected.r * 255, 1));
    expect(actual.g * 255, closeTo(expected.g * 255, 1));
    expect(actual.b * 255, closeTo(expected.b * 255, 1));
  }

  Future<void> open(WidgetTester tester) async {
    await engine.load(Uri.parse('https://example.org'));
    await tester.pumpAndSettle();
  }

  Future<void> report(WidgetTester tester, PageMessage m) async {
    engine.report(m);
    await tester.pumpAndSettle();
  }

  const green = Color(0xFF1F3A2D);

  testWidgets('a page colour tints the band and picks light icons', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    await report(tester, const ColorMessage(green, ColorSource.meta));
    expectColor(bandColor(tester), green);
  });

  testWidgets('scrolling fades the band to 85 % and back', (tester) async {
    await pump(tester);
    await open(tester);
    await report(tester, const ColorMessage(green, ColorSource.meta));
    await report(tester, const ScrollMessage(120, false));
    expectColor(bandColor(tester), green.withAlpha(0xD9));
    await report(tester, const ScrollMessage(0, false));
    expectColor(bandColor(tester), green);
  });

  testWidgets('tint off keeps the surface colour', (tester) async {
    await pump(tester, tint: false);
    await open(tester);
    await report(tester, const ColorMessage(green, ColorSource.meta));
    final surface = Theme.of(tester.element(find.byType(StatusBarTint)))
        .colorScheme
        .surfaceContainer;
    expectColor(bandColor(tester), surface);
  });

  testWidgets('the old colour stays while the next page loads', (tester) async {
    await pump(tester);
    await open(tester);
    await report(tester, const ColorMessage(green, ColorSource.meta));
    await engine.load(Uri.parse('https://example.org/two'));
    await tester.pumpAndSettle();
    expectColor(bandColor(tester), green);
  });

  testWidgets('a photo header is sampled from a capture', (tester) async {
    engine.sample = const Color(0xFF445566);
    await pump(tester);
    await open(tester);
    await report(tester, const ColorMessage(null, ColorSource.unknown));
    expect(engine.samples, 1);
    expectColor(bandColor(tester), const Color(0xFF445566));
  });

  testWidgets('a tap on the edge scrolls to the top, only while scrolled', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(top: 40);
    tester.view.viewPadding = const FakeViewPadding(top: 40);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await pump(tester);
    await open(tester);
    await report(tester, const ColorMessage(green, ColorSource.meta));

    await tester.tapAt(const Offset(200, 50));
    expect(engine.scrollsToTop, 0);

    await report(tester, const ScrollMessage(300, false));
    await tester.tapAt(const Offset(200, 50));
    expect(engine.scrollsToTop, 1);
  });
}
