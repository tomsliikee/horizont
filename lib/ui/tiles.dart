import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../theme/motion.dart';
import '../theme/type.dart';
import 'buttons.dart';
import 'haptics.dart';
import 'squish.dart';

/// 84 high, radius 24, icon over a 12/600 label (`P:274`); the first tile of
/// a row is the loud one in `primaryContainer`.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.loud = false,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool loud;

  /// Done already (bookmarked, in the reading list): the icon fills.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = loud ? scheme.primaryContainer : scheme.surfaceBright;
    final ink = loud ? scheme.onPrimaryContainer : scheme.onSurface;
    return Squish(
      onTap: onTap,
      semanticLabel: label,
      // Pressed, the corners grow towards a pill (Material 3 Expressive).
      morph: (context, pressed) => Container(
        height: 84,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(
            lerpDouble(24, 42, pressed.clamp(0.0, 1.0))!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            SymbolIcon(icon, color: ink, filled: active),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HorizontType.tileLabel.copyWith(color: ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of a two-column group (`P:301`): icon and label, the corners given
/// by its place in the grid.
class GridButton extends StatelessWidget {
  const GridButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.borderRadius,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  /// Corners for cell [index] of a 2-column grid with [count] cells: 24 on
  /// the outer corners of the group only.
  static BorderRadius cornersFor(int index, int count) {
    const big = Radius.circular(24);
    const small = Radius.circular(8);
    final rows = (count / 2).ceil();
    final row = index ~/ 2;
    final left = index.isEven;
    return BorderRadius.only(
      topLeft: row == 0 && left ? big : small,
      topRight: row == 0 && !left ? big : small,
      bottomLeft: row == rows - 1 && left ? big : small,
      bottomRight: row == rows - 1 && !left ? big : small,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Squish(
      onTap: onTap,
      semanticLabel: label,
      pressedScale: 0.95,
      // Pressed, every corner rounds to the full pill, then springs back.
      morph: (context, pressed) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceBright,
          borderRadius: BorderRadius.lerp(
            borderRadius,
            BorderRadius.circular(30),
            pressed.clamp(0.0, 1.0),
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            SymbolIcon(icon, size: 22, color: scheme.onSurfaceVariant),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HorizontType.bodyMedium.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minus, the value, plus, on a `surfaceContainerHigh` pill (`P:290`).
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.lessLabel,
    required this.moreLabel,
    this.min = 50,
    this.max = 200,
    this.step = 10,
    this.unit = ' %',
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String lessLabel;
  final String moreLabel;
  final int min;
  final int max;
  final int step;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          RoundButton(
            icon: HIcons.remove,
            semanticLabel: lessLabel,
            size: 44,
            iconSize: 20,
            look: ButtonLook.plain,
            onTap: value <= min ? null : () => onChanged(value - step),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '$value$unit',
              textAlign: TextAlign.center,
              style: HorizontType.metricS.copyWith(
                fontSize: 15,
                color: scheme.onSurface,
              ),
            ),
          ),
          RoundButton(
            icon: HIcons.add,
            semanticLabel: moreLabel,
            size: 44,
            iconSize: 20,
            look: ButtonLook.plain,
            onTap: value >= max ? null : () => onChanged(value + step),
          ),
        ],
      ),
    );
  }
}

/// 36 high, radius 12, icon 18 and a 600 label; selected in
/// `secondaryContainer` (`P:333`).
class QuickChip extends StatelessWidget {
  const QuickChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = selected ? scheme.onSecondaryContainer : scheme.onSurface;
    return Squish(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? scheme.secondaryContainer : scheme.surfaceBright,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            SymbolIcon(icon, size: 18, color: ink),
            Text(
              label,
              style: HorizontType.bodyMedium
                  .withWeight(600)
                  .copyWith(color: ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// 124 high, radius 28: icon well top left, title and count bottom left
/// (`P:424`).
class FolderTile extends StatelessWidget {
  const FolderTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fill,
    required this.ink,
    required this.badge,
    required this.badgeInk,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color fill;
  final Color ink;
  final Color badge;
  final Color badgeInk;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Squish(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: '$title, $subtitle',
      pressedScale: 0.95,
      child: Container(
        height: 124,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badge,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: SymbolIcon(icon, size: 20, color: badgeInk),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HorizontType.title.copyWith(color: ink),
                ),
                Text(subtitle, style: HorizontType.label.copyWith(color: ink)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A number tile (`P:458`): a metric, what it is, then a sentence.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.metric,
    required this.label,
    this.strong,
    this.aside,
    this.loud = false,
  });

  final Widget metric;
  final String label;
  final String? strong;
  final String? aside;
  final bool loud;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = loud ? scheme.onPrimaryContainer : scheme.onSurface;
    final soft = loud ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: loud ? scheme.primaryContainer : scheme.surfaceBright,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          // Long values ("24,0 MB") shrink rather than wrap.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: DefaultTextStyle.merge(
              style: HorizontType.metricL.copyWith(color: ink),
              maxLines: 1,
              child: metric,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HorizontType.label.copyWith(color: soft),
          ),
          if (strong != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                strong!,
                style: HorizontType.bodyStrong.copyWith(color: ink),
              ),
            ),
          if (aside != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                aside!,
                style: HorizontType.aside.copyWith(color: soft),
              ),
            ),
        ],
      ),
    );
  }
}

/// 6 high, radius 3, `primary` on `primaryContainer` (`P:475`); the value
/// moves on an effect spring. Null [value] runs indeterminate.
class LinearBar extends StatelessWidget {
  const LinearBar({super.key, required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = value;
    if (v == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          minHeight: 6,
          color: scheme.primary,
          backgroundColor: scheme.primaryContainer,
        ),
      );
    }
    return SingleMotionBuilder(
      value: v.clamp(0, 1).toDouble(),
      motion: HorizontMotion.effects,
      builder: (context, shown, _) => Container(
        height: 6,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: shown.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 52 circle split into primary (top half), tertiary container (bottom
/// right) and primary container; a check and a ring when selected
/// (`P:597`).
class ColorwaySwatch extends StatelessWidget {
  const ColorwaySwatch({
    super.key,
    required this.primary,
    required this.container,
    required this.tertiary,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color primary;
  final Color container;
  final Color tertiary;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Squish(
        onTap: onTap,
        semanticLabel: label,
        child: Column(
          spacing: 8,
          children: [
            SingleMotionBuilder(
              value: selected ? 1 : 0,
              motion: HorizontMotion.spatialFor(
                context,
                HorizontMotion.spatialFast,
              ),
              builder: (context, t, _) => Container(
                width: 52 + 12 * t.clamp(0, 1.2),
                height: 52 + 12 * t.clamp(0, 1.2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.onSurface.withValues(
                      alpha: t.clamp(0.0, 1.0),
                    ),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: SizedBox.square(
                    dimension: 52,
                    child: Stack(
                      children: [
                        Positioned.fill(child: ColoredBox(color: container)),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: 26,
                          child: ColoredBox(color: primary),
                        ),
                        Positioned(
                          left: 26,
                          top: 26,
                          right: 0,
                          bottom: 0,
                          child: ColoredBox(color: tertiary),
                        ),
                        Center(
                          child: Transform.scale(
                            scale: t.clamp(0.0, 1.3),
                            child: const SymbolIcon(
                              HIcons.checkCircle,
                              size: 22,
                              filled: true,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HorizontType.tileLabel
                  .withWeight(selected ? 800 : 450)
                  .copyWith(color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// A box of a [LayoutPreview]: position, size, radius and whether it is the
/// accent.
typedef PreviewBox = ({
  double x,
  double y,
  double w,
  double h,
  double r,
  bool accent,
});

/// A 72x112 mini screen with up to three boxes (`P:611`, `lyDefs`).
class LayoutPreview extends StatelessWidget {
  const LayoutPreview({
    super.key,
    required this.boxes,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final List<PreviewBox> boxes;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Squish(
        onTap: onTap,
        semanticLabel: label,
        child: SingleMotionBuilder(
          value: selected ? 1 : 0,
          motion: HorizontMotion.effects,
          builder: (context, t, _) => Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            decoration: BoxDecoration(
              color: Color.lerp(
                scheme.surfaceBright,
                scheme.primaryContainer,
                t,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              spacing: 8,
              children: [
                Container(
                  width: 72,
                  height: 112,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      scheme.surfaceContainer,
                      scheme.surfaceBright,
                      t,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    children: [
                      for (final b in boxes)
                        Positioned(
                          left: b.x,
                          top: b.y,
                          width: b.w,
                          height: b.h,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: b.accent ? scheme.primary : scheme.outline,
                              borderRadius: BorderRadius.circular(b.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  label,
                  style: HorizontType.navLabel(t).copyWith(
                    fontSize: 13,
                    color: Color.lerp(
                      scheme.onSurface,
                      scheme.onPrimaryContainer,
                      t,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A radio row (`P:646`): the selected one in `primaryContainer` with a
/// `primary` badge.
class RadioRow extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.borderRadius,
  });

  final String letter;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Squish(
        onTap: () {
          if (!selected) Haptics.play(Haptic.tick);
          onTap();
        },
        haptic: false,
        semanticLabel: title,
        pressedScale: 0.97,
        child: SingleMotionBuilder(
          value: selected ? 1 : 0,
          motion: HorizontMotion.effects,
          builder: (context, t, _) {
            final ink = Color.lerp(
              scheme.onSurface,
              scheme.onPrimaryContainer,
              t,
            )!;
            return Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color.lerp(
                  scheme.surfaceBright,
                  scheme.primaryContainer,
                  t,
                ),
                borderRadius: borderRadius,
              ),
              child: Row(
                spacing: 16,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        scheme.surfaceContainerHigh,
                        scheme.primary,
                        t,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      letter,
                      style: HorizontType.monogram.copyWith(
                        color: Color.lerp(
                          scheme.onSurfaceVariant,
                          scheme.onPrimary,
                          t,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: HorizontType.bodyMedium.copyWith(color: ink),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: HorizontType.caption.copyWith(
                              color: ink.withValues(alpha: 0.85),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: Color.lerp(
                          scheme.onSurfaceVariant,
                          scheme.primary,
                          t,
                        )!,
                      ),
                    ),
                    child: Container(
                      width: lerpDouble(0, 10, t.clamp(0, 1.2)),
                      height: lerpDouble(0, 10, t.clamp(0, 1.2)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 36x4 in `outline` (`P:265`).
class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
    child: Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );
}

/// A rounded 24x24 square with a 2 px border and the tab count (`P:186`).
class TabCountGlyph extends StatelessWidget {
  const TabCountGlyph({super.key, required this.count, this.color});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? Theme.of(context).colorScheme.onSurface;
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: ink, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? ':)' : '$count',
        style: HorizontType.tileLabel
            .withWeight(800)
            .copyWith(color: ink, height: 1),
      ),
    );
  }
}
