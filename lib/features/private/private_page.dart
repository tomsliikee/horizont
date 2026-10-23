import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/biometric_lock.dart';
import '../../theme/extensions.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/shapes.dart';
import '../../ui/squish.dart';

/// The start page of a private tab (`P:131`–`P:153`), always dark, on the
/// private surfaces.
class PrivatePage extends ConsumerWidget {
  const PrivatePage({super.key, this.topPadding = 0});

  /// Extra room for a bar at the top (layouts oben, expressiv).
  final double topPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = HorizontColors.of(context);
    final settings = ref.watch(settingsProvider);
    final top = MediaQuery.viewPaddingOf(context).top + topPadding;
    const ink = Color(0xFFFFFFFF);

    Widget row(
      IconData icon,
      String title,
      String subtitle,
      BorderRadius radius,
    ) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.privateSurface,
        borderRadius: radius,
      ),
      child: Row(
        spacing: 16,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SymbolIcon(
              icon,
              size: 20,
              color: scheme.onTertiaryContainer,
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
                Text(
                  subtitle,
                  style: HorizontType.caption.copyWith(
                    color: colors.privateOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Material(
      color: colors.privateBackground,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, top + 52, 16, 150),
        children: [
          StaggeredEntrance(
            index: 0,
            child: Column(
              spacing: 16,
              children: [
                const SizedBox(height: 44),
                MorphingShapeBadge(
                  preset: ShapePreset.hero6,
                  size: 116,
                  color: scheme.tertiaryContainer,
                  child: SymbolIcon(
                    HIcons.visibilityOff,
                    size: 48,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                Text(
                  l10n.privateTitle,
                  textAlign: TextAlign.center,
                  style: HorizontType.display.copyWith(color: ink),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    l10n.privateBody,
                    textAlign: TextAlign.center,
                    style: HorizontType.subtitle.copyWith(
                      color: colors.privateOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          StaggeredEntrance(
            index: 1,
            child: Column(
              spacing: 4,
              children: [
                row(
                  HIcons.fingerprint,
                  settings.lockPrivateTabs
                      ? l10n.lockedWithFingerprint
                      : l10n.lockOff,
                  settings.lockPrivateTabs
                      ? l10n.whenLeavingApp
                      : l10n.lockOffSub,
                  const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(8),
                  ),
                ),
                row(
                  HIcons.shield,
                  l10n.strictTracking,
                  l10n.strictTrackingSub,
                  const BorderRadius.vertical(
                    top: Radius.circular(8),
                    bottom: Radius.circular(24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StaggeredEntrance(
            index: 2,
            child: Center(
              child: Squish(
                semanticLabel: l10n.leavePrivate,
                onTap: () => ref.read(tabsProvider.notifier).leavePrivate(),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.privateSurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      const SymbolIcon(HIcons.close, size: 20, color: ink),
                      Text(
                        l10n.leavePrivate,
                        style: HorizontType.bodyStrong.copyWith(color: ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Covers the private tabs while they are locked; the fingerprint opens
/// them again.
class PrivateLockCover extends ConsumerWidget {
  const PrivateLockCover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = HorizontColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    const ink = Color(0xFFFFFFFF);
    return Material(
      color: colors.privateBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              ShapeBadge(
                preset: ShapePreset.hero6,
                size: 116,
                color: scheme.tertiaryContainer,
                child: SymbolIcon(
                  HIcons.fingerprint,
                  size: 48,
                  color: scheme.onTertiaryContainer,
                ),
              ),
              Text(
                l10n.privateLocked,
                style: HorizontType.headline.copyWith(color: ink),
              ),
              PillButton(
                icon: HIcons.fingerprint,
                label: l10n.unlock,
                height: 56,
                look: ButtonLook.primary,
                onTap: () => ref
                    .read(privateLockProvider.notifier)
                    .unlock(l10n.unlockReason),
              ),
              Squish(
                semanticLabel: l10n.tabs,
                onTap: () =>
                    ref.read(privateLockProvider.notifier).showNormalTabs(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.tabs,
                    style: HorizontType.bodyStrong.copyWith(
                      color: colors.privateOnSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
