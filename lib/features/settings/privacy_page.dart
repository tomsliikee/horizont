import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/page_actions.dart';
import '../../app/providers.dart';
import '../../app/system_ui.dart';
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/horizont_webkit.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/count_up.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/shapes.dart';

/// The comparison sentence of the privacy report.
String trackerComparison(AppLocalizations l10n, TrackerReport report) {
  final change = report.change;
  if (change > 0) return l10n.moreThanLastWeek(change);
  if (change < 0) return l10n.fewerThanLastWeek(-change);
  return l10n.sameAsLastWeek;
}

/// The shape of the report changes with the count, so a new number is seen
/// as well as read (PLAN 6.2, Shapes).
ShapePreset reportShape(int count) => const [
  ShapePreset.sunny,
  ShapePreset.hero9,
  ShapePreset.flower,
  ShapePreset.hero6,
][count % 4];

/// Datenschutz (`P:668`–`P:696`): the report, four switches ("IP-Adresse
/// verbergen" is removed, D7), and deleting history and site data.
class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final report =
        ref.watch(trackerReportProvider).value ?? const TrackerReport();

    ListRow row(
      IconData icon,
      String title,
      String sub,
      bool value,
      Settings Function(Settings, bool) set,
    ) => ListRow(
      leading: IconWell(icon: icon),
      title: title,
      subtitle: sub,
      minHeight: 72,
      trailing: HorizontSwitch(
        value: value,
        semanticLabel: title,
        onChanged: (v) => notifier.update((s) => set(s, v)),
      ),
    );

    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: StatusBand(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
            ),
            children: [
              ScreenHeader(title: l10n.privacy, backLabel: l10n.back),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    StaggeredEntrance(
                      index: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          spacing: 20,
                          children: [
                            MorphingShapeBadge(
                              preset: reportShape(report.week),
                              size: 116,
                              color: scheme.tertiary,
                              child: CountUp(
                                value: report.week,
                                style: HorizontType.badgeNumber.copyWith(
                                  color: scheme.onTertiary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    l10n.thisWeekSites(report.sites),
                                    style: HorizontType.label.copyWith(
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                  Text(
                                    l10n.trackersBlocked,
                                    style: HorizontType.title.copyWith(
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                  Text(
                                    trackerComparison(l10n, report),
                                    style: HorizontType.bodyStrong.copyWith(
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                  Text(
                                    l10n.countedOnDevice,
                                    style: HorizontType.aside.copyWith(
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SectionHeader(l10n.protection),
                    StaggeredEntrance(
                      index: 1,
                      child: ListGroup(
                        rows: [
                          row(
                            HIcons.block,
                            l10n.blockTracking,
                            l10n.blockTrackingSub,
                            s.blockTracking,
                            (s, v) => s.copyWith(blockTracking: v),
                          ),
                          row(
                            HIcons.lock,
                            l10n.httpsOnly,
                            l10n.httpsOnlySub,
                            s.httpsOnly,
                            (s, v) => s.copyWith(httpsOnly: v),
                          ),
                          row(
                            HIcons.gppMaybe,
                            l10n.fraudWarning,
                            l10n.fraudWarningSub,
                            s.fraudWarning,
                            (s, v) => s.copyWith(fraudWarning: v),
                          ),
                          row(
                            HIcons.fingerprint,
                            l10n.lockPrivateTabs,
                            l10n.lockPrivateTabsSub,
                            s.lockPrivateTabs,
                            (s, v) => s.copyWith(lockPrivateTabs: v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggeredEntrance(
                      index: 2,
                      child: PillButton(
                        icon: HIcons.deleteForever,
                        label: l10n.clearData,
                        height: 56,
                        look: ButtonLook.error,
                        onTap: () async {
                          final ok = await confirm(
                            context,
                            title: l10n.clearDataTitle,
                            body: l10n.clearDataBody,
                            action: l10n.delete,
                          );
                          if (!ok) return;
                          final library = ref.read(libraryProvider);
                          await library.clearHistory();
                          await library.clearPermissions();
                          await HorizontWebKit.clearAllData(null);
                          unawaited(HapticFeedback.mediumImpact());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.cleared)),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
