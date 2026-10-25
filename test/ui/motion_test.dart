import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/routes.dart';
import 'package:horizont/ui/buttons.dart';
import 'package:horizont/ui/motion/presence.dart';
import 'package:material_ui/material_ui.dart';

import '../test_app.dart';

/// A screen that counts how often its state is made, to see that a
/// transition never rebuilds it from scratch.
class _Counted extends StatefulWidget {
  const _Counted();
  static var created = 0;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    _Counted.created++;
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('second')));
}

void main() {
  BorderRadius radiusOf(WidgetTester tester) {
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(RoundButton),
        matching: find.byType(Container),
      ),
    );
    return (box.decoration! as BoxDecoration).borderRadius! as BorderRadius;
  }

  testWidgets('a pressed round button morphs toward a rounded square', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Center(
          child: RoundButton(
            icon: HIcons.home,
            semanticLabel: 'Home',
            size: 56,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(radiusOf(tester).topLeft.x, 28);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(RoundButton)),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(radiusOf(tester).topLeft.x, lessThan(20));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(radiusOf(tester).topLeft.x, closeTo(28, 0.01));
  });

  testWidgets('a screen route springs in and out and keeps its state', (
    tester,
  ) async {
    _Counted.created = 0;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context)
                      .push(screenRoute<void>(const _Counted())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    final openAtRest = tester.getRect(find.text('open'));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    // The first screen, the browser with its live web view, stays put while
    // the new one comes; it only dims (PLAN 7.2).
    expect(tester.getRect(find.text('open')), openAtRest);
    // Mid-way: the new screen is still to the right.
    final mid = tester.getRect(find.text('second'));
    await tester.pumpAndSettle();
    final rest = tester.getRect(find.text('second'));
    expect(mid.center.dx, greaterThan(rest.center.dx));
    expect(rest.center.dx, closeTo(prototypeSize.width / 2, 0.5));
    expect(_Counted.created, 1);

    // Back: still there mid-way, gone at rest.
    Navigator.of(tester.element(find.text('second'))).pop();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('second'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('spring presence leaves, comes back mid-way, and goes', (
    tester,
  ) async {
    Widget at({required bool visible}) => Directionality(
      textDirection: TextDirection.ltr,
      child: SpringPresence(visible: visible, child: const Text('start')),
    );
    await tester.pumpWidget(at(visible: true));
    expect(find.text('start'), findsOneWidget);

    await tester.pumpWidget(at(visible: false));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.text('start'), findsOneWidget, reason: 'still fading out');

    // Back before it is gone: it returns to full presence.
    await tester.pumpWidget(at(visible: true));
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);

    await tester.pumpWidget(at(visible: false));
    await tester.pumpAndSettle();
    expect(find.text('start'), findsNothing);
  });
}
