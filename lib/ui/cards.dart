import 'package:material_ui/material_ui.dart';

import '../theme/type.dart';
import 'buttons.dart';
import 'shapes.dart';
import 'squish.dart';

/// A container-tone card, radius 32: a shape badge beside label, title, a
/// comparison sentence and an aside (the privacy report, P:70).
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.number,
    required this.label,
    required this.title,
    required this.strong,
    required this.aside,
    this.preset = ShapePreset.hero9,
    this.onTap,
  });

  final String number;
  final String label;
  final String title;
  final String strong;
  final String aside;
  final ShapePreset preset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = scheme.onPrimaryContainer;
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          ShapeBadge(
            preset: preset,
            size: 116,
            color: scheme.primary,
            child: Text(
              number,
              style: HorizontType.badgeNumber.copyWith(color: scheme.onPrimary),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(label, style: HorizontType.label.copyWith(color: ink)),
                Text(title, style: HorizontType.title.copyWith(color: ink)),
                Text(
                  strong,
                  style: HorizontType.bodyStrong.copyWith(color: ink),
                ),
                Text(aside, style: HorizontType.aside.copyWith(color: ink)),
              ],
            ),
          ),
        ],
      ),
    );
    return onTap == null
        ? card
        : Squish(
            onTap: onTap,
            pressedScale: 0.97,
            semanticLabel: '$title, $number',
            child: card,
          );
  }
}

/// `headline`, 28 above, 12 below, 4 inset.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 28, 4, 12),
      child: Text(
        text,
        style: HorizontType.headline.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Back button, then the `display` title and an optional subtitle. Top
/// padding is the status bar height plus 12.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backLabel = 'Back',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top + 12;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, top, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundButton(
            icon: HIcons.arrowBack,
            semanticLabel: backLabel,
            look: ButtonLook.highest,
            onTap: onBack ?? () => Navigator.maybePop(context),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: HorizontType.display.copyWith(color: scheme.onSurface),
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                subtitle!,
                style: HorizontType.subtitle.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// What a list says when it has nothing yet: a shape with an icon, a title
/// and how to fill it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.hint,
  });

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        spacing: 12,
        children: [
          ShapeBadge(
            preset: ShapePreset.flower,
            size: 96,
            color: scheme.secondaryContainer,
            child: SymbolIcon(
              icon,
              size: 36,
              color: scheme.onSecondaryContainer,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: HorizontType.title.copyWith(color: scheme.onSurface),
          ),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: HorizontType.body.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
