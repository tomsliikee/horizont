import 'dart:math' as math;
import 'dart:ui';

/// The colours CSS pages most often name in a `theme-color` meta tag. The
/// page script reports computed styles, which are always `rgb()`, so this is
/// only for the meta tag.
const _named = <String, int>{
  'black': 0xFF000000,
  'white': 0xFFFFFFFF,
  'red': 0xFFFF0000,
  'green': 0xFF008000,
  'blue': 0xFF0000FF,
  'yellow': 0xFFFFFF00,
  'orange': 0xFFFFA500,
  'purple': 0xFF800080,
  'gray': 0xFF808080,
  'grey': 0xFF808080,
  'silver': 0xFFC0C0C0,
  'navy': 0xFF000080,
  'teal': 0xFF008080,
  'maroon': 0xFF800000,
  'lime': 0xFF00FF00,
  'aqua': 0xFF00FFFF,
  'cyan': 0xFF00FFFF,
  'fuchsia': 0xFFFF00FF,
  'magenta': 0xFFFF00FF,
  'olive': 0xFF808000,
  'pink': 0xFFFFC0CB,
  'brown': 0xFFA52A2A,
  'gold': 0xFFFFD700,
  'indigo': 0xFF4B0082,
  'violet': 0xFFEE82EE,
  'crimson': 0xFFDC143C,
  'tomato': 0xFFFF6347,
  'whitesmoke': 0xFFF5F5F5,
  'lightgray': 0xFFD3D3D3,
  'lightgrey': 0xFFD3D3D3,
  'darkgray': 0xFFA9A9A9,
  'darkgrey': 0xFFA9A9A9,
  'dimgray': 0xFF696969,
  'dimgrey': 0xFF696969,
  'darkblue': 0xFF00008B,
  'darkgreen': 0xFF006400,
  'darkred': 0xFF8B0000,
  'royalblue': 0xFF4169E1,
  'steelblue': 0xFF4682B4,
  'skyblue': 0xFF87CEEB,
  'midnightblue': 0xFF191970,
  'transparent': 0x00000000,
};

/// Parses a CSS colour: `#rgb`, `#rgba`, `#rrggbb`, `#rrggbbaa`, `rgb()`,
/// `rgba()` (comma or space syntax, optional `/ alpha`) or a name. Null for
/// anything else; pages are untrusted, so no guessing.
Color? parseCssColor(String? source) {
  if (source == null) return null;
  final s = source.trim().toLowerCase();
  if (s.isEmpty || s.length > 64) return null;
  if (s.startsWith('#')) return _hex(s.substring(1));
  if (s.startsWith('rgb')) return _rgb(s);
  final named = _named[s];
  return named == null ? null : Color(named);
}

Color? _hex(String h) {
  if (!RegExp(r'^[0-9a-f]+$').hasMatch(h)) return null;
  int c(int i) => int.parse(h[i] + h[i], radix: 16);
  switch (h.length) {
    case 3:
      return Color.fromARGB(255, c(0), c(1), c(2));
    case 4:
      return Color.fromARGB(c(3), c(0), c(1), c(2));
    case 6:
      return Color(0xFF000000 | int.parse(h, radix: 16));
    case 8:
      final v = int.parse(h, radix: 16);
      return Color((v & 0xFF) << 24 | v >> 8);
    default:
      return null;
  }
}

Color? _rgb(String s) {
  final m = RegExp(r'^rgba?\(([^)]*)\)$').firstMatch(s);
  if (m == null) return null;
  final parts = m
      .group(1)!
      .split(RegExp(r'[\s,/]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.length != 3 && parts.length != 4) return null;
  int? channel(String p) {
    final percent = p.endsWith('%');
    final v = double.tryParse(percent ? p.substring(0, p.length - 1) : p);
    if (v == null || v.isNaN) return null;
    return (percent ? v * 2.55 : v).round().clamp(0, 255);
  }

  final r = channel(parts[0]);
  final g = channel(parts[1]);
  final b = channel(parts[2]);
  if (r == null || g == null || b == null) return null;
  var a = 255;
  if (parts.length == 4) {
    final p = parts[3];
    final percent = p.endsWith('%');
    final v = double.tryParse(percent ? p.substring(0, p.length - 1) : p);
    if (v == null || v.isNaN) return null;
    a = ((percent ? v / 100 : v).clamp(0.0, 1.0) * 255).round();
  }
  return Color.fromARGB(a, r, g, b);
}

/// The prototype's luminance on gamma-encoded values (`P:961`), kept as is so
/// the icon choice matches the prototype rather than WCAG.
double prototypeLuminance(Color c) {
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
}

/// Whether the surface [c] counts as light, so icons on it are dark.
Brightness surfaceBrightness(Color c) =>
    prototypeLuminance(c) > 0.55 ? Brightness.light : Brightness.dark;

/// Euclidean distance of the RGB channels, 0 to 441. Reports closer than
/// [minColorDistance] are ignored so the bar does not flicker.
double colorDistance(Color a, Color b) {
  final dr = (a.r - b.r) * 255;
  final dg = (a.g - b.g) * 255;
  final db = (a.b - b.b) * 255;
  return math.sqrt(dr * dr + dg * dg + db * db);
}

const minColorDistance = 6.0;
