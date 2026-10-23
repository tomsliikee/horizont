import 'dart:ui' show FontFeature, FontVariation, lerpDouble;

import 'package:material_ui/material_ui.dart';

/// The text roles of the design system (PLAN 2.4), set in Google Sans Flex.
///
/// Every role carries all of its axes itself: `TextStyle.merge` replaces the
/// whole `fontVariations` list, so a role that set only `wght` would lose the
/// `ROND` of the screen root. `opsz` equals the font size because Flutter,
/// unlike a browser, does not set it automatically. `fontWeight` is set next
/// to `wght` for semantics and fallback fonts.
abstract final class HorizontType {
  static const family = 'Google Sans Flex';

  static TextStyle _role(
    double size,
    double line, {
    required double wght,
    double wdth = 100,
    double? slnt,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      height: line / size,
      fontWeight: weightName(wght),
      fontVariations: [
        const FontVariation('ROND', 100),
        FontVariation('opsz', size.clamp(6, 144).toDouble()),
        FontVariation('wght', wght),
        FontVariation('wdth', wdth),
        if (slnt != null) FontVariation('slnt', slnt),
      ],
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  /// The nearest named weight, for where the axis is not honoured.
  static FontWeight weightName(double wght) =>
      FontWeight.values[((wght / 100).round() - 1).clamp(0, 8)];

  // Screen titles; deliberately light so the metric below leads.
  static final display = _role(36, 44, wght: 450);
  static final brand = _role(36, 44, wght: 800, wdth: 108);
  static final metricXl = _role(40, 48, wght: 800, wdth: 112, tabular: true);
  static final badgeNumber = _role(32, 36, wght: 800, wdth: 112, tabular: true);
  static final metricL = _role(34, 40, wght: 800, wdth: 112, tabular: true);
  static final metricM = _role(28, 32, wght: 800, wdth: 112, tabular: true);
  static final metricS = _role(22, 28, wght: 700, wdth: 106, tabular: true);
  static final headline = _role(24, 32, wght: 750, wdth: 108);
  static final title = _role(17, 24, wght: 750, wdth: 108);
  static final subtitle = _role(16, 24, wght: 450);
  static final body = _role(14, 20, wght: 400);

  /// List titles.
  static final bodyMedium = _role(14, 20, wght: 500);

  /// Subtitles under list titles.
  static final caption = _role(12, 16, wght: 400);
  static final bodyStrong = _role(14, 20, wght: 700);
  static final label = _role(12, 16, wght: 450, wdth: 88);

  /// A note beside the matter, oblique.
  static final aside = _role(12, 16, wght: 400, slnt: -10);
  static final address = _role(15, 20, wght: 600);
  static final addressSmall = _role(13, 18, wght: 600, wdth: 96);
  static final tileLabel = _role(12, 16, wght: 600, wdth: 92);

  /// A letter on a well or shape: 16 on wells, 22 on shapes.
  static final monogram = _role(16, 24, wght: 800);
  static final monogramLarge = _role(22, 28, wght: 800, wdth: 110);

  /// The label of a navigation item or segment: the nearer [selected] is to
  /// 1, the heavier and wider. Axes move on a grid so the engine does not
  /// shape a new font per frame (R14).
  static TextStyle navLabel(double selected) {
    final t = selected.clamp(0.0, 1.0);
    return _role(
      15,
      20,
      wght: _stepped(lerpDouble(500, 800, t)!, 20),
      wdth: _stepped(lerpDouble(96, 112, t)!, 2),
    );
  }

  static double _stepped(double value, double step) =>
      (value / step).round() * step;
}

/// The Material text theme, mapped onto the roles so stock widgets (dialogs,
/// text fields) speak the same type.
TextTheme horizontTextTheme(Color onSurface) {
  TextStyle c(TextStyle s) => s.copyWith(color: onSurface);
  return TextTheme(
    displayLarge: c(HorizontType.metricXl),
    displayMedium: c(HorizontType.display),
    displaySmall: c(HorizontType.display),
    headlineLarge: c(HorizontType.display),
    headlineMedium: c(HorizontType.headline),
    headlineSmall: c(HorizontType.headline),
    titleLarge: c(HorizontType.headline),
    titleMedium: c(HorizontType.title),
    titleSmall: c(HorizontType.bodyStrong),
    bodyLarge: c(HorizontType.subtitle),
    bodyMedium: c(HorizontType.body),
    bodySmall: c(HorizontType.label),
    labelLarge: c(HorizontType.bodyMedium),
    labelMedium: c(HorizontType.label),
    labelSmall: c(HorizontType.label),
  );
}

/// Changes the weight of a role: the `wght` axis and `fontWeight` together,
/// keeping the other axes (a plain `copyWith(fontWeight:)` would leave the
/// axis where it was).
extension TextStyleWeight on TextStyle {
  TextStyle withWeight(double wght) => copyWith(
    fontWeight: HorizontType.weightName(wght),
    fontVariations: [
      for (final v in fontVariations ?? const <FontVariation>[])
        if (v.axis != 'wght') v,
      FontVariation('wght', wght),
    ],
  );
}
