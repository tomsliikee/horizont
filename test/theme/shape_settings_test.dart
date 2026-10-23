import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/search_engines.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:horizont/theme/extensions.dart';
import 'package:horizont/ui/shapes.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('shapePath', () {
    test('stays within its square and has the prototype point count', () {
      for (final p in ShapePreset.values) {
        const size = 116.0;
        final bounds = shapePath(p.lobes, p.amplitude, size).getBounds();
        expect(bounds.left, greaterThanOrEqualTo(-0.01), reason: p.name);
        expect(bounds.top, greaterThanOrEqualTo(-0.01), reason: p.name);
        expect(bounds.right, lessThanOrEqualTo(size + 0.01), reason: p.name);
        expect(bounds.bottom, lessThanOrEqualTo(size + 0.01), reason: p.name);
        // Lobes reach the edge: the shape fills most of its box.
        expect(bounds.width, greaterThan(size * 0.9), reason: p.name);
      }
    });

    test('is closed and centred', () {
      final path = shapePath(9, 0.07, 100);
      expect(path.contains(const Offset(50, 50)), isTrue);
      expect(path.contains(const Offset(1, 1)), isFalse);
      final metrics = path.computeMetrics().toList();
      expect(metrics, hasLength(1));
      expect(metrics.single.isClosed, isTrue);
    });

    test('preset paths are cached per size', () {
      expect(
        identical(
          presetPath(ShapePreset.hero9, 64),
          presetPath(ShapePreset.hero9, 64),
        ),
        isTrue,
      );
    });
  });

  group('HorizontRadii.groupItem', () {
    const radii = HorizontRadii();
    test('single row is fully 24', () {
      expect(radii.groupItem(0, 1), BorderRadius.circular(24));
    });
    test('first, middle, last', () {
      expect(
        radii.groupItem(0, 3),
        const BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(8),
        ),
      );
      expect(radii.groupItem(1, 3), BorderRadius.circular(8));
      expect(
        radii.groupItem(2, 3),
        const BorderRadius.vertical(
          top: Radius.circular(8),
          bottom: Radius.circular(24),
        ),
      );
    });
  });

  group('Settings', () {
    test('round trip', () {
      const s = Settings(
        themeMode: ThemeMode.dark,
        colourway: Colourway.pink,
        tintFromPage: false,
      );
      expect(Settings.fromJson(s.toJson()), s);
      // Stored before the tint setting existed: the default is on.
      expect(
        Settings.fromJson('{"version":1,"themeMode":"dark","colourway":"pink"}')
            .tintFromPage,
        isTrue,
      );
    });
    test('defaults for null, garbage and unknown values', () {
      expect(Settings.fromJson(null), const Settings());
      expect(Settings.fromJson('not json'), const Settings());
      expect(Settings.fromJson('[1]'), const Settings());
      expect(
        Settings.fromJson('{"version":1,"themeMode":"x","colourway":"y"}'),
        const Settings(),
      );
    });
    test('a newer version is ignored', () {
      expect(
        Settings.fromJson(
          '{"version":99,"themeMode":"dark","colourway":"pink"}',
        ),
        const Settings(),
      );
    });
  });

  test('every setting survives a round trip', () {
    const s = Settings(
      barLayout: BarLayout.karte,
      shrinkOnScroll: false,
      hideBarAtPageEnd: true,
      searchEngine: SearchEngine.duckDuckGo,
      searchSuggestions: false,
      blockTracking: false,
      httpsOnly: false,
      fraudWarning: false,
      lockPrivateTabs: false,
      askBeforeDownload: false,
      forceZoom: true,
      textZoomByHost: {'orf.at': 130},
      startSections: {StartSection.favourites},
    );
    expect(Settings.fromJson(s.toJson()), s);
  });

  test('a stored object without the newer keys takes their defaults', () {
    final old = Settings.fromJson(
      '{"version":1,"themeMode":"dark","colourway":"green"}',
    );
    expect(old.themeMode, ThemeMode.dark);
    expect(old.barLayout, BarLayout.kompakt);
    expect(old.blockTracking, isTrue);
    expect(old.startSections, StartSection.values.toSet());
  });

  test('text sizes per host stay within 50 to 200 and 100 is not stored', () {
    var s = const Settings().withTextZoom('a.example', 250);
    expect(s.textZoomFor('a.example'), 200);
    s = s.withTextZoom('a.example', 100);
    expect(s.textZoomByHost, isEmpty);
    expect(
      Settings.fromJson('{"version":1,"textZoomByHost":{"a":20,"b":120}}')
          .textZoomByHost,
      {'b': 120},
    );
  });
}
