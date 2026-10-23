import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/browser_providers.dart';
import 'package:horizont/browser/status_bar/page_message.dart';

void main() {
  BarMode mode(
    double y, {
    bool end = false,
    bool down = true,
    bool shrink = true,
    bool hide = false,
  }) => barModeFor(
    ScrollMessage(y, end, down: down),
    shrink: shrink,
    hideAtEnd: hide,
  );

  test('reading down shrinks the bar, scrolling up brings it back', () {
    expect(mode(400), BarMode.shrunk);
    expect(mode(400, down: false), BarMode.full);
  });

  test('near the top the bar stays full', () {
    expect(mode(10), BarMode.full);
  });

  test('the setting off keeps it full', () {
    expect(mode(400, shrink: false), BarMode.full);
  });

  test('at the end it hides only where the setting asks (D4)', () {
    expect(mode(900, end: true), BarMode.shrunk);
    expect(mode(900, end: true, hide: true), BarMode.hidden);
    // A page too short to scroll is at its end at the top.
    expect(mode(0, end: true, hide: true), BarMode.full);
  });

  test('the page script reports the direction', () {
    final m = PageMessage.parse(
      '{"type":"scroll","y":120,"end":false,"dir":"down"}',
    );
    expect(m, isA<ScrollMessage>().having((s) => s.down, 'down', isTrue));
    final up = PageMessage.parse(
      '{"type":"scroll","y":120,"end":false,"dir":"up"}',
    );
    expect((up! as ScrollMessage).down, isFalse);
  });
}
