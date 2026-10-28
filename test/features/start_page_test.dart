import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/features/start/start_page.dart';
import 'package:horizont/features/start/tabs_row.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void main() {
  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(StartPage)));

  testWidgets('the privacy line comes after the favourites', (tester) async {
    await pumpApp(tester, StartPage(onOpen: (_) {}));
    final favourites = tester.getTopLeft(find.text('Favourites')).dy;
    await tester.scrollUntilVisible(
      find.textContaining('blocked this week'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.getTopLeft(find.textContaining('blocked this week')).dy,
      greaterThan(tester.getTopLeft(find.text('Favourites')).dy),
    );
    expect(favourites, lessThan(500));
  });

  testWidgets('the row of tabs is missing without other or closed tabs', (
    tester,
  ) async {
    await pumpApp(tester, StartPage(onOpen: (_) {}));
    expect(find.byType(TabsRow), findsNothing);
  });

  testWidgets('a closed tab shows in the row and opens again', (tester) async {
    await pumpApp(tester, StartPage(onOpen: (_) {}));
    final notifier = containerOf(tester).read(tabsProvider.notifier);
    final page = notifier.open(
      url: Uri.parse('https://bergzeit.example/'),
      activate: false,
    );
    notifier
      ..updatePage(page.id, title: 'Bergzeit')
      ..close(page.id);
    await tester.pumpAndSettle();
    expect(find.text('Recently closed'), findsOneWidget);
    await tester.tap(find.text('Bergzeit'));
    await tester.pumpAndSettle();
    expect(containerOf(tester).read(tabsProvider).activeId, page.id);
  });

  testWidgets('the private chip switches to private mode', (tester) async {
    await pumpApp(tester, StartPage(onOpen: (_) {}));
    await tester.tap(find.text('Private'));
    await tester.pump();
    expect(containerOf(tester).read(tabsProvider).privateMode, isTrue);
  });

  testWidgets('a long press on a favourite starts arranging, done ends it', (
    tester,
  ) async {
    await pumpApp(tester, StartPage(onOpen: (_) {}));
    await tester.longPress(find.text(defaultFavourites.first.$1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Arrange favourites'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Arrange favourites'), findsNothing);
  });

  testWidgets('dragging a favourite onto another moves it there', (
    tester,
  ) async {
    final library = MemoryLibrary();
    await pumpApp(tester, StartPage(onOpen: (_) {}), library: library);
    final first = defaultFavourites[0].$1;
    final third = defaultFavourites[2].$1;
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(first)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(find.text(third).last));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));
    final order = (await library.favourites()).map((b) => b.title).toList();
    expect(order.indexOf(first), 2);
  });
}
