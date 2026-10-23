import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/browser_shell.dart';
import 'package:horizont/browser/bars/browser_bars.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/features/start/start_page.dart';
import 'package:horizont/ui/buttons.dart';
import 'package:horizont/ui/progress_line.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void main() {
  late FakeWebEngine engine;

  setUp(() => engine = FakeWebEngine());
  tearDown(() => engine.dispose());

  // The tab in front gets the one fake engine, so its page requests reach
  // the shell as in the app.
  Future<void> pump(WidgetTester tester) =>
      pumpAppWith(tester, const BrowserShell(), engineFactory: (_) => engine);

  testWidgets('an empty tab shows the start page and no domain', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byType(StartPage), findsOneWidget);
    expect(find.text('Search or address'), findsOneWidget);
  });

  testWidgets('the bar slides away while the keyboard is up', (tester) async {
    await pump(tester);
    bool keyboardUp() =>
        tester.widget<BrowserBars>(find.byType(BrowserBars)).keyboardUp;
    expect(keyboardUp(), isFalse);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(keyboardUp(), isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    expect(engine.reveals, 1);

    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(keyboardUp(), isFalse);
  });

  testWidgets('typing an address loads it and shows the domain', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Search or address'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'example.com/a');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(engine.state.value.url, Uri.parse('https://example.com/a'));
    expect(find.byType(StartPage), findsNothing);
    expect(find.text('example.com'), findsOneWidget);
  });

  testWidgets('a search term goes to the search engine', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Search or address'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'wetter wien');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();

    expect(engine.state.value.url?.host, 'www.google.com');
    expect(engine.state.value.url?.queryParameters['q'], 'wetter wien');
  });

  testWidgets('back button follows the page history', (tester) async {
    await pump(tester);
    await engine.load(Uri.parse('https://a.example'));
    await engine.load(Uri.parse('https://b.example'));
    await tester.pumpAndSettle();
    expect(find.text('b.example'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(engine.state.value.url, Uri.parse('https://a.example'));
  });

  testWidgets('system back: history, then start page, then the app', (
    tester,
  ) async {
    await pump(tester);
    await engine.load(Uri.parse('https://a.example'));
    await engine.load(Uri.parse('https://b.example'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(engine.state.value.url, Uri.parse('https://a.example'));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(engine.state.value.url, isNull);
    expect(find.byType(StartPage), findsOneWidget);
  });

  testWidgets('the progress line shows only while loading', (tester) async {
    await pump(tester);
    engine.emit(
      PageState(
        url: Uri.parse('https://a.example'),
        loading: true,
        progress: 0.4,
      ),
    );
    await tester.pump();
    double? progress() =>
        tester.widget<ProgressLine>(find.byType(ProgressLine).first).progress;
    expect(progress(), 0.4);
    engine.emit(PageState(url: Uri.parse('https://a.example'), progress: 1));
    await tester.pump();
    expect(progress(), isNull);
    // The closing wave plays and the line goes.
    await tester.pumpAndSettle();
  });

  testWidgets('a link to another app asks first and is not followed', (
    tester,
  ) async {
    await pump(tester);
    engine.blockLink(Uri.parse('mailto:a@b.at'));
    await tester.pumpAndSettle();
    expect(find.text('Open in another app?'), findsOneWidget);
    expect(find.textContaining('a@b.at'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(engine.state.value.url, isNull);
  });

  testWidgets('the lock shows for https only', (tester) async {
    await pump(tester);
    await engine.load(Uri.parse('http://a.example'));
    await tester.pumpAndSettle();
    expect(find.text('a.example'), findsOneWidget);
    expect(find.byIcon(HIcons.lock), findsNothing);
    await engine.load(Uri.parse('https://a.example'));
    await tester.pumpAndSettle();
    expect(find.byIcon(HIcons.lock), findsOneWidget);
  });
}
