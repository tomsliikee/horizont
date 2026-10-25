import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/bars/bar_actions.dart';
import 'package:horizont/browser/bars/browser_bars.dart';
import 'package:horizont/browser/browser_providers.dart';
import 'package:horizont/browser/web_engine.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/ui/address_pill.dart';
import 'package:horizont/ui/buttons.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

void _noop() {}

const _actions = BarActions(
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
);

void main() {
  final page = PageState(
    url: Uri.parse('https://www.bergzeit.example/herbst'),
    title: 'Herbst',
  );

  Widget bars(BarLayout layout, ValueNotifier<BarMode> mode) => Scaffold(
    body: ValueListenableBuilder(
      valueListenable: mode,
      builder: (context, mode, _) => BrowserBars(
        layout: layout,
        page: page,
        actions: _actions,
        mode: mode,
        keyboardUp: false,
        engineLabel: 'Google',
        onExpand: _noop,
      ),
    ),
  );

  // The pill's address surface: the box around its small address.
  Rect pillSurface(WidgetTester tester) => tester.getRect(
    find
        .ancestor(
          of: find.byWidgetPredicate((w) => w is AddressPill && w.small),
          matching: find.byType(ConstrainedBox),
        )
        .first,
  );

  for (final layout in BarLayout.values.where((l) => l != BarLayout.minimal)) {
    testWidgets('${layout.name}: one surface goes from the bar to the pill', (
      tester,
    ) async {
      final mode = ValueNotifier(BarMode.full);
      addTearDown(mode.dispose);
      await pumpApp(tester, bars(layout, mode));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(barSurfaceKey), findsNothing);

      mode.value = BarMode.shrunk;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final mid = tester.getRect(find.byKey(barSurfaceKey));
      await tester.pumpAndSettle();
      final end = tester.getRect(find.byKey(barSurfaceKey));
      final pill = pillSurface(tester);
      expect(end.left, closeTo(pill.left, 0.5), reason: '$end vs $pill');
      expect(end.top, closeTo(pill.top, 0.5), reason: '$end vs $pill');
      expect(end.size.width, closeTo(pill.width, 0.5));
      expect(end.size.height, closeTo(pill.height, 0.5));
      expect(mid.width, greaterThan(end.width), reason: 'still wider mid-way');
      expect(find.byKey(barSurfaceKey), findsOneWidget);
      // Shrunk: only the address, thin and centred over the gesture bar.
      expect(pill.center.dx, closeTo(prototypeSize.width / 2, 0.5));
      expect(pill.height, 34);
      expect(
        find.byWidgetPredicate(
          (w) => w is RoundButton && w.icon == HIcons.menu,
        ),
        findsNothing,
      );
    });
  }
}
