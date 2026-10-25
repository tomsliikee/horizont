import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/ui/horizont_logo.dart';
import 'package:horizont/ui/logo_geometry.dart';
import 'package:material_ui/material_ui.dart';

import '../../tool/gen_icon.dart';

void main() {
  test('the launcher drawables are up to date with the geometry', () {
    for (final MapEntry(:key, :value) in generateIconFiles().entries) {
      expect(
        File(key).readAsStringSync(),
        value,
        reason: '$key is stale; run dart run tool/gen_icon.dart',
      );
    }
  });

  test('sun and reflections stay inside the guaranteed circle', () {
    const centre = LogoGeometry.size / 2;
    double distance((double, double) p) =>
        math.sqrt(math.pow(p.$1 - centre, 2) + math.pow(p.$2 - centre, 2));
    for (final p in LogoGeometry.sun(upperHalf: true)) {
      expect(distance(p), lessThan(33), reason: '$p');
    }
    for (final (y, half) in LogoGeometry.reflections) {
      final end = (
        centre + half + LogoGeometry.reflectionStroke / 2,
        y + LogoGeometry.reflectionStroke / 2,
      );
      expect(distance(end), lessThan(33));
    }
  });

  test('the horizon dips toward the sides', () {
    expect(LogoGeometry.horizonAt(54), LogoGeometry.horizonY);
    expect(LogoGeometry.horizonAt(18), greaterThan(LogoGeometry.horizonY + 3));
    expect(LogoGeometry.horizonAt(18), LogoGeometry.horizonAt(90));
  });

  testWidgets('logo in launcher shapes and themed', (tester) async {
    tester.view
      ..physicalSize = const Size(720, 400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const seed = Color(0xFF2E9E4F);
    final light = ColorScheme.fromSeed(seedColor: seed);
    final dark = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    Widget cell(Color background, Widget logo) => ColoredBox(
      color: background,
      child: Padding(padding: const EdgeInsets.all(20), child: logo),
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const Key('sheet'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    cell(light.surface, const HorizontLogo(size: 140)),
                    cell(
                      light.surface,
                      const HorizontLogo(
                        size: 140,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(84)),
                        ),
                      ),
                    ),
                    cell(
                      light.surface,
                      HorizontLogo(
                        size: 140,
                        colors: LogoColors.themed(light),
                      ),
                    ),
                    cell(
                      dark.surface,
                      HorizontLogo(size: 140, colors: LogoColors.themed(dark)),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final s in [96.0, 48.0, 32.0])
                      cell(dark.surface, HorizontLogo(size: s)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('sheet')),
      matchesGoldenFile('../goldens/logo.png'),
    );
  });
}
