import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/system_ui.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/horizont_webkit.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/shapes.dart';
import '../../ui/squish.dart';
import '../downloads/downloads_page.dart';
import 'appearance_page.dart';
import 'engine_page.dart';
import 'labels.dart';
import 'more_settings.dart';
import 'privacy_page.dart';

/// Einstellungen (`P:496`–`P:576`): the Design & Farbe hero with its live
/// summary, then General, Privacy and Advanced.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    void push(Widget page) =>
        unawaited(Navigator.of(context).push(screenRoute<void>(page)));
    Widget chevron() => SymbolIcon(
      HIcons.chevronRight,
      size: 22,
      color: scheme.onSurfaceVariant,
    );
    Widget well(IconData icon, Color fill, Color ink) =>
        IconWell(icon: icon, fill: fill, ink: ink);
    final secondary = (scheme.secondaryContainer, scheme.onSecondaryContainer);
    final tertiary = (scheme.tertiaryContainer, scheme.onTertiaryContainer);
    final neutral = (scheme.surfaceContainerHigh, scheme.onSurfaceVariant);

    final startSummary = s.startSections.isEmpty
        ? l10n.startPageNothing
        : l10n.startPageSections;
    var i = 0;
    Widget stagger(Widget child) => StaggeredEntrance(index: i++, child: child);

    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: StatusBand(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
            ),
            children: [
              ScreenHeader(title: l10n.settings, backLabel: l10n.back),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    stagger(
                      Squish(
                        semanticLabel: l10n.designAndColour,
                        pressedScale: 0.97,
                        onTap: () => push(const AppearancePage()),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            spacing: 16,
                            children: [
                              MorphingShapeBadge(
                                preset: ShapePreset.flower,
                                size: 72,
                                color: scheme.primary,
                                child: SymbolIcon(
                                  HIcons.palette,
                                  size: 32,
                                  color: scheme.onPrimary,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2,
                                  children: [
                                    Text(
                                      l10n.designAndColour,
                                      style: HorizontType.title.copyWith(
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                    Text(
                                      l10n.designSummary(
                                        themeLabel(l10n, s.themeMode),
                                        colourwayLabel(l10n, s.colourway),
                                        layoutLabel(l10n, s.barLayout),
                                      ),
                                      style: HorizontType.bodyStrong.copyWith(
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                    Text(
                                      l10n.designHint,
                                      style: HorizontType.label.copyWith(
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SymbolIcon(
                                HIcons.chevronRight,
                                color: scheme.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SectionHeader(l10n.general),
                    stagger(
                      ListGroup(
                        rows: [
                          ListRow(
                            leading: well(
                              HIcons.search,
                              secondary.$1,
                              secondary.$2,
                            ),
                            title: l10n.searchEngine,
                            subtitle: s.searchEngine.label,
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const EnginePage()),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.home,
                              secondary.$1,
                              secondary.$2,
                            ),
                            title: l10n.startPage,
                            subtitle: startSummary,
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const StartSettingsPage()),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.tab,
                              secondary.$1,
                              secondary.$2,
                            ),
                            title: l10n.groupTabs,
                            subtitle: l10n.groupTabsSub,
                            minHeight: 72,
                            trailing: HorizontSwitch(
                              value: s.groupTabs,
                              semanticLabel: l10n.groupTabs,
                              onChanged: (v) => notifier.update(
                                (s) => s.copyWith(groupTabs: v),
                              ),
                            ),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.autoDelete,
                              secondary.$1,
                              secondary.$2,
                            ),
                            title: l10n.autoCloseTabs,
                            subtitle: autoCloseLabel(l10n, s.autoCloseTabs),
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const AutoClosePage()),
                          ),
                        ],
                      ),
                    ),
                    SectionHeader(l10n.privacy),
                    stagger(
                      ListGroup(
                        rows: [
                          ListRow(
                            leading: well(
                              HIcons.shield,
                              tertiary.$1,
                              tertiary.$2,
                            ),
                            title: l10n.privacySecurity,
                            subtitle: [
                              s.blockTracking
                                  ? l10n.trackingOn
                                  : l10n.trackingOff,
                              if (s.httpsOnly) l10n.httpsOnlyShort,
                            ].join(' · '),
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const PrivacyPage()),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.password,
                              tertiary.$1,
                              tertiary.$2,
                            ),
                            title: l10n.passwords,
                            subtitle: l10n.passwordsSub,
                            minHeight: 72,
                            trailing: SymbolIcon(
                              HIcons.openInNew,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                            onTap: () => unawaited(
                              HorizontWebKit.openPasswordSettings(),
                            ),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.tune,
                              tertiary.$1,
                              tertiary.$2,
                            ),
                            title: l10n.siteSettings,
                            subtitle: l10n.siteSettingsSub,
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const SiteSettingsPage()),
                          ),
                        ],
                      ),
                    ),
                    SectionHeader(l10n.advanced),
                    stagger(
                      ListGroup(
                        rows: [
                          ListRow(
                            leading: well(
                              HIcons.download,
                              neutral.$1,
                              neutral.$2,
                            ),
                            title: l10n.downloads,
                            subtitle: s.askBeforeDownload
                                ? l10n.askBeforeDownload
                                : l10n.saveWithoutAsking,
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const DownloadSettingsPage()),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.openInBrowser,
                              neutral.$1,
                              neutral.$2,
                            ),
                            title: l10n.defaultBrowser,
                            subtitle: l10n.defaultBrowserSub,
                            minHeight: 72,
                            trailing: SymbolIcon(
                              HIcons.openInNew,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                            onTap: () => unawaited(
                              HorizontWebKit.openDefaultBrowserSettings(),
                            ),
                          ),
                          ListRow(
                            leading: well(
                              HIcons.accessibilityNew,
                              neutral.$1,
                              neutral.$2,
                            ),
                            title: l10n.accessibility,
                            subtitle: l10n.accessibilitySub,
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const AccessibilityPage()),
                          ),
                          ListRow(
                            leading: well(HIcons.info, neutral.$1, neutral.$2),
                            title: l10n.about,
                            subtitle: l10n.version(appVersion),
                            minHeight: 72,
                            trailing: chevron(),
                            onTap: () => push(const AboutPage()),
                          ),
                        ],
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

/// Opens the downloads screen; also reachable from Advanced.
void openDownloads(BuildContext context) => unawaited(
  Navigator.of(context).push(screenRoute<void>(const DownloadsPage())),
);
