import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/theme/color_schemes.dart';
import 'package:horizont/theme/tokens.g.dart';
import 'package:material_ui/material_ui.dart';

import '../../tool/gen_tokens.dart';

void main() {
  test('tokens.g.dart is up to date with tokens.json and the prototype', () {
    final onDisk = File(outputPath).readAsStringSync();
    expect(
      onDisk,
      generateTokens(),
      reason: 'Run: dart run tool/gen_tokens.dart',
    );
  });

  group('colourways match the prototype', () {
    final prototype = File(prototypePath).readAsStringSync();
    // Independent of the generator: read the strings with a second pattern.
    final byId = <String, List<List<String>>>{};
    for (final id in colourwayIds) {
      final start = prototype.indexOf('      $id: {');
      final block = prototype.substring(start, start + 900);
      final strings = RegExp(r"'([0-9a-f]{6}(?:,[0-9a-f]{6}){22})'")
          .allMatches(block)
          .take(2)
          .map((m) => m.group(1)!.split(','))
          .toList();
      byId[id] = strings;
    }

    for (final way in Colourway.values.where((w) => w.tableId != null)) {
      for (final brightness in Brightness.values) {
        test('${way.name} ${brightness.name}: all 23 listed roles', () {
          // The prototype lists light first.
          final light = brightness == Brightness.light;
          final row = byId[way.tableId]![light ? 0 : 1];
          final s = colorSchemeFor(way, brightness);
          final actual = <Color>[
            s.primary,
            s.onPrimary,
            s.primaryContainer,
            s.onPrimaryContainer,
            s.secondary,
            s.onSecondary,
            s.secondaryContainer,
            s.onSecondaryContainer,
            s.tertiary,
            s.onTertiary,
            s.tertiaryContainer,
            s.onTertiaryContainer,
            s.surfaceContainerLow,
            s.surfaceContainer,
            s.surfaceContainerHigh,
            s.surfaceContainerHighest,
            s.surfaceBright,
            s.onSurface,
            s.onSurfaceVariant,
            s.outline,
            s.outlineVariant,
            s.inverseSurface,
            s.onInverseSurface,
          ];
          final expected = [
            for (final h in row) Color(int.parse('ff$h', radix: 16)),
          ];
          expect(actual, expected);
          expect(row, hasLength(23));
        });
      }
    }
  });

  test('blue takes the surface roles of tokens.json', () {
    final light = colorSchemeFor(Colourway.blue, Brightness.light);
    expect(light.surface, const Color(0xfffbf8ff));
    final dark = colorSchemeFor(Colourway.blue, Brightness.dark);
    expect(dark.surface, const Color(0xff11131c));
    expect(dark.inversePrimary, const Color(0xff0045fc));
  });

  test('wallpaper falls back to blue without a system palette', () {
    expect(
      colorSchemeFor(Colourway.wallpaper, Brightness.light),
      colorSchemeFor(Colourway.blue, Brightness.light),
    );
  });

  test('tokens expose the design system numbers', () {
    expect(TokenSize.bar, 64);
    expect(TokenRadius.tile, 24);
    expect(TokenSpacing.s4, 16);
  });
}
