import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/platform/downloads_service.dart';

void main() {
  const en = LiveStrings.forLocale;

  test('text shows percent and time left', () {
    final s = en('en');
    expect(
      s.text(42, const Duration(seconds: 90), paused: false),
      '42 % · 1 min left',
    );
    expect(
      s.text(5, const Duration(seconds: 20), paused: false),
      '5 % · 20 s left',
    );
  });

  test('paused hides the time and says so', () {
    expect(
      LiveStrings.forLocale('de')
          .text(10, const Duration(minutes: 5), paused: true),
      '10 % · Pausiert',
    );
  });

  test('unknown size shows no percent', () {
    expect(en('en').text(-1, null, paused: false), '');
  });

  test('notification id is positive and stable', () {
    expect(liveNotificationId('abc'), liveNotificationId('abc'));
    expect(liveNotificationId('x' * 50), greaterThanOrEqualTo(0));
  });
}
