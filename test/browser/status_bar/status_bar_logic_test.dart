import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/status_bar/page_color.dart';
import 'package:horizont/browser/status_bar/page_color_tracker.dart';
import 'package:horizont/browser/status_bar/page_message.dart';
import 'package:horizont/browser/status_bar/status_bar_look.dart';

void main() {
  group('parseCssColor', () {
    test('hex forms', () {
      expect(parseCssColor('#1f3a2d'), const Color(0xFF1F3A2D));
      expect(parseCssColor('#FFF'), const Color(0xFFFFFFFF));
      expect(parseCssColor('#f00'), const Color(0xFFFF0000));
      expect(parseCssColor('#11223380'), const Color(0x80112233));
      expect(parseCssColor('#1238'), const Color(0x88112233));
    });

    test('rgb and rgba in both syntaxes', () {
      expect(parseCssColor('rgb(31, 58, 45)'), const Color(0xFF1F3A2D));
      expect(parseCssColor('rgb(31 58 45)'), const Color(0xFF1F3A2D));
      expect(parseCssColor('rgba(0, 0, 0, 0.5)'), const Color(0x80000000));
      expect(parseCssColor('rgb(0 0 0 / 50%)'), const Color(0x80000000));
      expect(parseCssColor('rgb(100%, 0%, 0%)'), const Color(0xFFFF0000));
      expect(parseCssColor('rgb(300, -4, 0)'), const Color(0xFFFF0000));
    });

    test('names, case and spaces', () {
      expect(parseCssColor(' Navy '), const Color(0xFF000080));
      expect(parseCssColor('white'), const Color(0xFFFFFFFF));
    });

    test('rejects what is not a colour', () {
      for (final bad in [
        null,
        '',
        '#12',
        '#12345',
        '#gggggg',
        'rgb(1, 2)',
        'rgb(a, b, c)',
        'rgb(1,2,3,4,5)',
        'hsl(0, 0%, 0%)',
        'nonsense',
        'x' * 100,
      ]) {
        expect(parseCssColor(bad), isNull, reason: '$bad');
      }
    });
  });

  group('ink', () {
    test('uses the prototype luminance with a 0.55 threshold', () {
      expect(surfaceBrightness(const Color(0xFFFFFFFF)), Brightness.light);
      expect(surfaceBrightness(const Color(0xFF1F3A2D)), Brightness.dark);
      expect(surfaceBrightness(const Color(0xFF000000)), Brightness.dark);
      // Gamma-encoded luminance of 0x8C8C8C is 0.549, of 0x8D8D8D 0.553.
      expect(surfaceBrightness(const Color(0xFF8C8C8C)), Brightness.dark);
      expect(surfaceBrightness(const Color(0xFF8D8D8D)), Brightness.light);
    });
  });

  group('PageMessage.parse', () {
    test('colour messages', () {
      final m = PageMessage.parse(
        '{"type":"color","source":"meta","rgba":"#1f3a2d"}',
      );
      expect(m, isA<ColorMessage>());
      expect((m as ColorMessage).color, const Color(0xFF1F3A2D));
      expect(m.source, ColorSource.meta);
      final unknown = PageMessage.parse(
        '{"type":"color","source":"unknown","rgba":""}',
      );
      expect((unknown as ColorMessage).color, isNull);
    });

    test('scroll messages', () {
      final m = PageMessage.parse('{"type":"scroll","y":120.5,"end":false}');
      expect((m as ScrollMessage).y, 120.5);
      expect(m.end, isFalse);
    });

    test('drops everything malformed or hostile', () {
      for (final bad in [
        'not json',
        '[]',
        '{}',
        '{"type":"other"}',
        '{"type":"color","source":"x","rgba":"#fff"}',
        '{"type":"color","source":"dom","rgba":"nonsense"}',
        '{"type":"color","source":"dom","rgba":"rgba(0,0,0,0.2)"}',
        '{"type":"color","source":"dom","rgba":5}',
        '{"type":"scroll","y":"1","end":false}',
        '{"type":"scroll","y":1,"end":"no"}',
        '{"type":"scroll","y":1e999,"end":false}',
        '{"type":"color","source":"dom","rgba":"${'a' * 600}"}',
      ]) {
        expect(PageMessage.parse(bad), isNull, reason: bad);
      }
    });
  });

  group('PageColorTracker', () {
    ColorMessage dom(int argb) => ColorMessage(Color(argb), ColorSource.dom);

    test('ignores changes below the distance, takes real ones', () {
      final t = PageColorTracker();
      expect(t.report(dom(0xFF1F3A2D)), isTrue);
      expect(t.report(dom(0xFF203A2D)), isFalse);
      expect(t.color, const Color(0xFF1F3A2D));
      expect(t.report(dom(0xFFFFFFFF)), isTrue);
      expect(t.color, const Color(0xFFFFFFFF));
    });

    test('an unknown report changes nothing', () {
      final t = PageColorTracker();
      expect(t.report(const ColorMessage(null, ColorSource.unknown)), isFalse);
      expect(t.color, isNull);
    });

    test('captures run at most once per second', () {
      var now = DateTime(2026);
      final t = PageColorTracker(now: () => now);
      expect(t.mayTakeSample(), isTrue);
      now = now.add(const Duration(milliseconds: 999));
      expect(t.mayTakeSample(), isFalse);
      now = now.add(const Duration(milliseconds: 1));
      expect(t.mayTakeSample(), isTrue);
    });
  });

  group('statusBarLook (PLAN 5.1)', () {
    const surface = Color(0xFFEEEEEE);
    const page = Color(0xFF1F3A2D);
    StatusBarLook look({
      bool onPage = true,
      bool tint = true,
      Color? pageColor = page,
      bool scrolled = false,
    }) => statusBarLook(
      onPage: onPage,
      tint: tint,
      pageColor: pageColor,
      scrolled: scrolled,
      surface: surface,
    );

    test('page at the top: solid page colour, no edge', () {
      expect(look(), const StatusBarLook(color: page, edge: false));
    });

    test('page scrolled: page colour at 85 %, with the edge', () {
      final l = look(scrolled: true);
      expect(l.color, page.withAlpha(0xD9));
      expect(l.edge, isTrue);
    });

    test('tint off: the surface, edge follows scrolling', () {
      expect(
        look(tint: false),
        const StatusBarLook(color: surface, edge: false),
      );
      expect(
        look(tint: false, scrolled: true),
        const StatusBarLook(color: surface, edge: true),
      );
    });

    test('start page: the surface, always with the edge', () {
      expect(
        look(onPage: false),
        const StatusBarLook(color: surface, edge: true),
      );
    });

    test('before the first report the surface shows', () {
      expect(look(pageColor: null).color, surface);
    });
  });
}
