import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/browser_shell.dart';
import 'package:horizont/app/pull_refresh.dart';
import 'package:horizont/browser/bars/browser_bars.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/status_bar/page_message.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/features/start/start_page.dart';
import 'package:horizont/ui/buttons.dart';
import 'package:horizont/ui/morph_indicator.dart';
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

  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }
  }

  testWidgets('a pull past the threshold reloads, a short one does not', (
    tester,
  ) async {
    await pump(tester);
    engine.emit(PageState(url: Uri.parse('https://a.example'), progress: 1));
    await tester.pumpAndSettle();
    expect(find.byType(MorphIndicator), findsNothing);

    expect(find.byType(PullRefresh), findsOneWidget);
    engine.report(const PullMessage(60, end: false));
    await frames(tester);
    expect(find.byType(MorphIndicator), findsOneWidget);
    engine.report(const PullMessage(60, end: true));
    await tester.pumpAndSettle();
    expect(engine.reloads, 0);
    expect(find.byType(MorphIndicator), findsNothing);

    engine.report(const PullMessage(PullRefresh.threshold + 20, end: false));
    await tester.pump();
    engine.report(const PullMessage(PullRefresh.threshold + 20, end: true));
    await frames(tester);
    expect(engine.reloads, 1);
    expect(find.byType(MorphIndicator), findsOneWidget);

    // The page loads again and the indicator goes.
    engine.emit(PageState(url: Uri.parse('https://a.example'), loading: true));
    await tester.pump();
    engine.emit(PageState(url: Uri.parse('https://a.example'), progress: 1));
    await tester.pumpAndSettle();
    expect(find.byType(MorphIndicator), findsNothing);
  });

  testWidgets('tab bookkeeping and page noise do not rebuild the start page', (
    tester,
  ) async {
    await pump(tester);
    var builds = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is StartPage) builds++;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    final notifier = container.read(tabsProvider.notifier);
    final other = notifier.open(
      url: Uri.parse('https://a.example'),
      activate: false,
    );
    await tester.pumpAndSettle();
    builds = 0;
    for (var i = 0; i < 10; i++) {
      notifier.updatePage(other.id, title: 'Title $i', scrollY: i * 10.0);
      engine.emit(PageState(progress: i / 10));
      await tester.pump();
    }
    expect(builds, 0);
  });

  testWidgets('a restored tab shows its address, not the start page', (
    tester,
  ) async {
    final slow = _SlowEngine();
    addTearDown(slow.dispose);
    await pumpAppWith(tester, const BrowserShell(), engineFactory: (_) => slow);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    container
        .read(tabsProvider.notifier)
        .open(url: Uri.parse('https://bergzeit.example/herbst'));
    await tester.pumpAndSettle();
    expect(slow.state.value.url, isNull, reason: 'the page has not reported');
    expect(find.byType(StartPage), findsNothing);
    expect(find.text('bergzeit.example'), findsOneWidget);
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

  testWidgets('home shows the start page; system back leaves the app', (
    tester,
  ) async {
    final exits = _recordExits(tester);
    await pump(tester);
    await engine.load(Uri.parse('https://a.example'));
    await tester.pumpAndSettle();
    expect(find.text('a.example'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Home'));
    await tester.pumpAndSettle();
    expect(engine.state.value.url, isNull);
    expect(find.byType(StartPage), findsOneWidget);

    // about:blank sits in the history behind the start page; back must not
    // walk into the page again (that was a loop with no way out).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(exits.value, 1);
    expect(engine.state.value.url, isNull);
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

  testWidgets('a link from another app: back closes its tab and leaves', (
    tester,
  ) async {
    final exits = _recordExits(tester);
    await pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    final notifier = container.read(tabsProvider.notifier);
    notifier.open(url: Uri.parse('https://kept.example'));
    await tester.pumpAndSettle();
    final before = container.read(tabsProvider).tabs.length;

    notifier.openLink(Uri.parse('https://from-mail.example'));
    await tester.pumpAndSettle();
    final linkTab = container.read(tabsProvider).activeId;
    expect(notifier.isExternal(linkTab), isTrue);
    await engine.load(Uri.parse('https://from-mail.example'));
    await tester.pumpAndSettle();

    // The fake engine is shared by all tabs, so its history also holds the
    // page of the tab opened before; a real tab starts with its own. Back
    // goes through that history first, as it should.
    while (exits.value == 0 && engine.state.value.canGoBack) {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(exits.value, 1);
    expect(container.read(tabsProvider).byId(linkTab), isNull);
    expect(container.read(tabsProvider).tabs.length, before);
    expect(notifier.isExternal(linkTab), isFalse);
  });

  testWidgets('a link from another app: history comes first', (tester) async {
    final exits = _recordExits(tester);
    await pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    final notifier = container.read(tabsProvider.notifier);
    notifier.open(url: Uri.parse('https://kept.example'));
    notifier.openLink(Uri.parse('https://from-mail.example'));
    await tester.pumpAndSettle();
    await engine.load(Uri.parse('https://from-mail.example'));
    await engine.load(Uri.parse('https://second.example'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(engine.state.value.url, Uri.parse('https://from-mail.example'));
    expect(exits.value, 0);
  });

  DownloadRequestEvent file(String url, {Uri? referer}) => DownloadRequestEvent(
    url: Uri.parse(url),
    fileName: 'big.dat',
    mimeType: 'application/octet-stream',
    size: 1000,
    userAgent: 'test',
    cookies: null,
    referer: referer,
  );

  testWidgets('a file link from another app forgets the file and leaves', (
    tester,
  ) async {
    final exits = _recordExits(tester);
    // Only the file's tab gets the engine that raises the download.
    await pumpAppWith(
      tester,
      const BrowserShell(),
      engineFactory: (tab) =>
          tab.url?.host == 'files.example' ? engine : FakeWebEngine(),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    final notifier = container.read(tabsProvider.notifier);
    notifier.open(url: Uri.parse('https://kept.example'));
    notifier.openLink(Uri.parse('https://files.example/big.dat'));
    await tester.pumpAndSettle();
    final fileTab = container.read(tabsProvider).activeId;

    engine.raise(file('https://files.example/big.dat'));
    await tester.pumpAndSettle();
    // The address is gone before the answer, so a restart cannot ask again.
    expect(container.read(tabsProvider).byId(fileTab)?.url, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(container.read(tabsProvider).byId(fileTab), isNull);
    expect(exits.value, 1);
  });

  testWidgets('a download from a page keeps the page', (tester) async {
    final exits = _recordExits(tester);
    await pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BrowserShell)),
    );
    final page = Uri.parse('https://page.example');
    container.read(tabsProvider.notifier).open(url: page);
    await tester.pumpAndSettle();
    await engine.load(page);
    await tester.pumpAndSettle();

    engine.raise(file('https://files.example/big.dat', referer: page));
    await tester.pumpAndSettle();
    // The fake engine is shared by all tabs, so each one asks.
    while (find.text('Cancel').evaluate().isNotEmpty) {
      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();
    }

    expect(container.read(tabsProvider).active.url, page);
    expect(exits.value, 0);
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

  testWidgets('a long press on the address copies it', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pump(tester);
    await engine.load(Uri.parse('https://a.example/weg?x=1'));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('a.example'));
    await tester.pumpAndSettle();
    expect(copied, 'https://a.example/weg?x=1');
  });
}

/// A web view that has not reported its page yet, like one still starting.
class _SlowEngine extends FakeWebEngine {
  @override
  Future<void> load(Uri uri, {double scrollY = 0}) async =>
      loads.add((uri, scrollY));
}

class _Exits {
  var value = 0;
}

/// Counts `SystemNavigator.pop` calls, which is how the app hands control
/// back to the app that opened it.
_Exits _recordExits(WidgetTester tester) {
  final exits = _Exits();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemNavigator.pop') exits.value++;
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return exits;
}
