import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/data/settings.dart';

void main() {
  test('haptics level survives a round trip and defaults to normal', () {
    expect(const Settings().haptics, HapticLevel.normal);
    final s = const Settings().copyWith(haptics: HapticLevel.strong);
    expect(Settings.fromJson(s.toJson()).haptics, HapticLevel.strong);
    expect(Settings.fromJson('{"version":1}').haptics, HapticLevel.normal);
  });

  test('bar raise and lifting survive a round trip, raise is clamped', () {
    const d = Settings();
    expect(d.barRaise, 0);
    expect(d.liftOverPageBars, isTrue);
    final s = d.copyWith(barRaise: 24, liftOverPageBars: false);
    final back = Settings.fromJson(s.toJson());
    expect(back.barRaise, 24);
    expect(back.liftOverPageBars, isFalse);
    expect(
      Settings.fromJson('{"version":1,"barRaise":500}').barRaise,
      Settings.maxBarRaise,
    );
  });
}
