import 'package:material_ui/material_ui.dart';

import 'tokens.g.dart';

/// Colours outside the Material roles: status, illustration, glass, private.
/// Fixed in every colourway except where noted.
@immutable
class HorizontColors extends ThemeExtension<HorizontColors> {
  const HorizontColors({
    required this.statusGood,
    required this.onStatusGood,
    required this.statusWarn,
    required this.onStatusWarn,
    required this.statusBad,
    required this.onStatusBad,
    required this.illustrationSun,
    required this.illustrationNight,
    required this.glass,
    required this.scrim,
    required this.privateSurface,
    required this.privateOnSurfaceVariant,
    this.privateBackground = const Color(0xFF101A38),
  });

  /// Built from the tokens; [glass] follows the scheme's highest container.
  factory HorizontColors.fromScheme(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    final tokens = dark ? TokenColors.dark : TokenColors.light;
    return HorizontColors(
      statusGood: Color(tokens['statusGood']!),
      onStatusGood: Color(tokens['onStatusGood']!),
      statusWarn: Color(tokens['statusWarn']!),
      onStatusWarn: Color(tokens['onStatusWarn']!),
      statusBad: Color(tokens['statusBad']!),
      onStatusBad: Color(tokens['onStatusBad']!),
      illustrationSun: Color(TokenColors.fixed['illustrationSun']!),
      illustrationNight: Color(TokenColors.fixed['illustrationNight']!),
      // 92 % opaque, prototype P:750.
      glass: scheme.surfaceContainerHighest.withAlpha(0xEB),
      scrim: const Color(0x5C000000),
      privateSurface: const Color(0xFF1B2650),
      privateOnSurfaceVariant: const Color(0xFFC9D1EE),
    );
  }

  final Color statusGood;
  final Color onStatusGood;
  final Color statusWarn;
  final Color onStatusWarn;
  final Color statusBad;
  final Color onStatusBad;
  final Color illustrationSun;
  final Color illustrationNight;
  final Color glass;
  final Color scrim;
  final Color privateSurface;
  final Color privateOnSurfaceVariant;

  /// The page behind private tabs (`P:133`).
  final Color privateBackground;

  static HorizontColors of(BuildContext context) =>
      Theme.of(context).extension<HorizontColors>()!;

  @override
  HorizontColors copyWith({
    Color? statusGood,
    Color? onStatusGood,
    Color? statusWarn,
    Color? onStatusWarn,
    Color? statusBad,
    Color? onStatusBad,
    Color? illustrationSun,
    Color? illustrationNight,
    Color? glass,
    Color? scrim,
    Color? privateSurface,
    Color? privateOnSurfaceVariant,
  }) => HorizontColors(
    statusGood: statusGood ?? this.statusGood,
    onStatusGood: onStatusGood ?? this.onStatusGood,
    statusWarn: statusWarn ?? this.statusWarn,
    onStatusWarn: onStatusWarn ?? this.onStatusWarn,
    statusBad: statusBad ?? this.statusBad,
    onStatusBad: onStatusBad ?? this.onStatusBad,
    illustrationSun: illustrationSun ?? this.illustrationSun,
    illustrationNight: illustrationNight ?? this.illustrationNight,
    glass: glass ?? this.glass,
    scrim: scrim ?? this.scrim,
    privateSurface: privateSurface ?? this.privateSurface,
    privateOnSurfaceVariant:
        privateOnSurfaceVariant ?? this.privateOnSurfaceVariant,
  );

  @override
  HorizontColors lerp(HorizontColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HorizontColors(
      statusGood: l(statusGood, other.statusGood),
      onStatusGood: l(onStatusGood, other.onStatusGood),
      statusWarn: l(statusWarn, other.statusWarn),
      onStatusWarn: l(onStatusWarn, other.onStatusWarn),
      statusBad: l(statusBad, other.statusBad),
      onStatusBad: l(onStatusBad, other.onStatusBad),
      illustrationSun: l(illustrationSun, other.illustrationSun),
      illustrationNight: l(illustrationNight, other.illustrationNight),
      glass: l(glass, other.glass),
      scrim: l(scrim, other.scrim),
      privateSurface: l(privateSurface, other.privateSurface),
      privateOnSurfaceVariant: l(
        privateOnSurfaceVariant,
        other.privateOnSurfaceVariant,
      ),
    );
  }
}

/// The radius scale (tokens) and the grouped-list rule of the prototype.
@immutable
class HorizontRadii extends ThemeExtension<HorizontRadii> {
  const HorizontRadii();

  double get small => TokenRadius.small;
  double get medium => TokenRadius.medium;
  double get large => TokenRadius.large;
  double get largeIncreased => TokenRadius.largeIncreased;
  double get tile => TokenRadius.tile;
  double get extraLarge => TokenRadius.extraLarge;
  double get extraLargeIncreased => TokenRadius.extraLargeIncreased;
  double get extraExtraLarge => TokenRadius.extraExtraLarge;
  double get full => TokenRadius.full;

  /// Corners of row [index] of [count] in a list group: outer corners 24,
  /// inner 8 (`radius()` in the prototype, P:777).
  BorderRadius groupItem(int index, int count) {
    Radius r(double v) => Radius.circular(v);
    if (count == 1) return BorderRadius.all(r(tile));
    if (index == 0) {
      return BorderRadius.vertical(top: r(tile), bottom: r(small));
    }
    if (index == count - 1) {
      return BorderRadius.vertical(top: r(small), bottom: r(tile));
    }
    return BorderRadius.all(r(small));
  }

  @override
  HorizontRadii copyWith() => this;

  @override
  HorizontRadii lerp(HorizontRadii? other, double t) => this;

  static HorizontRadii of(BuildContext context) =>
      Theme.of(context).extension<HorizontRadii>()!;
}

/// Spacing scale, 4 to 32.
@immutable
class HorizontSpacing extends ThemeExtension<HorizontSpacing> {
  const HorizontSpacing();

  double get space1 => TokenSpacing.s1;
  double get space2 => TokenSpacing.s2;
  double get space3 => TokenSpacing.s3;
  double get space4 => TokenSpacing.s4;
  double get space5 => TokenSpacing.s5;
  double get space6 => TokenSpacing.s6;
  double get space7 => TokenSpacing.s7;
  double get space8 => TokenSpacing.s8;

  @override
  HorizontSpacing copyWith() => this;

  @override
  HorizontSpacing lerp(HorizontSpacing? other, double t) => this;

  static HorizontSpacing of(BuildContext context) =>
      Theme.of(context).extension<HorizontSpacing>()!;
}

/// The two shadows of the design system.
@immutable
class HorizontShadows extends ThemeExtension<HorizontShadows> {
  const HorizontShadows({required this.floating, required this.button});

  /// Floating bars and the floating action square.
  final List<BoxShadow> floating;

  /// Round floating buttons over content.
  final List<BoxShadow> button;

  static const standard = HorizontShadows(
    floating: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 3), blurRadius: 8),
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 3),
    ],
    button: [
      BoxShadow(color: Color(0x2E000000), offset: Offset(0, 2), blurRadius: 6),
    ],
  );

  @override
  HorizontShadows copyWith({
    List<BoxShadow>? floating,
    List<BoxShadow>? button,
  }) => HorizontShadows(
    floating: floating ?? this.floating,
    button: button ?? this.button,
  );

  @override
  HorizontShadows lerp(HorizontShadows? other, double t) {
    if (other == null) return this;
    return HorizontShadows(
      floating: BoxShadow.lerpList(floating, other.floating, t)!,
      button: BoxShadow.lerpList(button, other.button, t)!,
    );
  }

  static HorizontShadows of(BuildContext context) =>
      Theme.of(context).extension<HorizontShadows>()!;
}

/// Fixed sizes from the tokens.
@immutable
class HorizontSizes extends ThemeExtension<HorizontSizes> {
  const HorizontSizes();

  double get bar => TokenSize.bar;
  double get touch => TokenSize.touch;
  double get fab => TokenSize.fab;
  double get heroBadge => TokenSize.heroBadge;
  double get metricCircle => TokenSize.metricCircle;
  double get badge => TokenSize.badge;

  @override
  HorizontSizes copyWith() => this;

  @override
  HorizontSizes lerp(HorizontSizes? other, double t) => this;

  static HorizontSizes of(BuildContext context) =>
      Theme.of(context).extension<HorizontSizes>()!;
}
