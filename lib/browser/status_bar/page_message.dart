import 'dart:convert';
import 'dart:ui';

import 'page_color.dart';

/// Where the page script found the colour.
enum ColorSource { meta, dom, unknown }

/// A message from the page script. Pages can call the channel too, so every
/// field is checked and anything unexpected is dropped (PLAN 4.5).
sealed class PageMessage {
  const PageMessage();

  /// Null for anything that is not a well-formed message.
  static PageMessage? parse(String raw) {
    if (raw.length > 512) return null;
    final Object? map;
    try {
      map = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (map is! Map<String, dynamic>) return null;
    switch (map['type']) {
      case 'color':
        final source = ColorSource.values.asNameMap()[map['source']];
        if (source == null) return null;
        if (source == ColorSource.unknown) {
          return const ColorMessage(null, ColorSource.unknown);
        }
        final rgba = map['rgba'];
        final color = rgba is String ? parseCssColor(rgba) : null;
        // A half transparent colour is not the colour of the page.
        if (color == null || color.a < 0.99) return null;
        return ColorMessage(color, source);
      case 'rest':
        return const RestMessage();
      case 'scroll':
        final y = map['y'];
        final end = map['end'];
        if (y is! num || !y.isFinite || end is! bool) return null;
        final dir = map['dir'];
        return ScrollMessage(
          y.toDouble().clamp(0, 1e9),
          end,
          down: dir == 'down',
        );
    }
    return null;
  }
}

/// The colour at the top of the page; null when the script cannot tell (a
/// gradient or photo), and Dart samples a capture instead.
class ColorMessage extends PageMessage {
  const ColorMessage(this.color, this.source);
  final Color? color;
  final ColorSource source;
}

/// The page scrolled; [end] when the end of the page is reached, [down]
/// while the reader moves down the page (the bar shrinks then).
class ScrollMessage extends PageMessage {
  const ScrollMessage(this.y, this.end, {this.down = false});
  final double y;
  final bool end;
  final bool down;
}

/// The page came to rest (loaded, or stopped scrolling); the app captures the
/// top of it again to see what colours are there now.
class RestMessage extends PageMessage {
  const RestMessage();
}
