import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/system_ui.dart';
import '../../browser/web_engine.dart' show SitePermissionKind;
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extensions.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/shapes.dart';
import '../../ui/tiles.dart';
import 'labels.dart';

/// The version shown in "Über Horizont"; kept in step with `pubspec.yaml`.
const appVersion = '1.0.0';

/// A settings screen of the same parts as the rest (D18).
class _Screen extends StatelessWidget {
  const _Screen({required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: StatusBand(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
            ),
            children: [
              ScreenHeader(
                title: title,
                subtitle: subtitle,
                backLabel: l10n.back,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++)
                      StaggeredEntrance(index: i, child: children[i]),
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

/// Startseite: which sections the start page shows.
class StartSettingsPage extends ConsumerWidget {
  const StartSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    ListRow row(StartSection section, IconData icon, String title) => ListRow(
      leading: IconWell(icon: icon),
      title: title,
      minHeight: 64,
      trailing: HorizontSwitch(
        value: s.startSections.contains(section),
        semanticLabel: title,
        onChanged: (on) => notifier.update(
          (s) => s.copyWith(
            startSections: on
                ? {...s.startSections, section}
                : ({...s.startSections}..remove(section)),
          ),
        ),
      ),
    );
    return _Screen(
      title: l10n.startPage,
      subtitle: l10n.showOnStartPage,
      children: [
        ListGroup(
          rows: [
            row(
              StartSection.privacyReport,
              HIcons.shield,
              l10n.privacyReportLabel,
            ),
            row(StartSection.favourites, HIcons.star, l10n.favourites),
            row(StartSection.frequent, HIcons.history, l10n.frequentlyVisited),
            row(StartSection.readingList, HIcons.eyeglasses, l10n.readingList),
          ],
        ),
      ],
    );
  }
}

/// Tabs automatisch schließen: never, a day, a week, a month.
class AutoClosePage extends ConsumerWidget {
  const AutoClosePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final radii = HorizontRadii.of(context);
    final s = ref.watch(settingsProvider);
    const values = AutoCloseTabs.values;
    return _Screen(
      title: l10n.autoCloseTabs,
      subtitle: l10n.autoCloseSub,
      children: [
        Column(
          spacing: 4,
          children: [
            for (var i = 0; i < values.length; i++)
              RadioRow(
                letter: switch (values[i]) {
                  AutoCloseTabs.never => '∞',
                  AutoCloseTabs.day => '1',
                  AutoCloseTabs.week => '7',
                  AutoCloseTabs.month => '30',
                },
                title: autoCloseLabel(l10n, values[i]),
                subtitle: '',
                selected: s.autoCloseTabs == values[i],
                borderRadius: radii.groupItem(i, values.length),
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .update((s) => s.copyWith(autoCloseTabs: values[i])),
              ),
          ],
        ),
      ],
    );
  }
}

/// Website-Einstellungen: what each site may use (camera, microphone,
/// location; no notifications, D10).
class SiteSettingsPage extends ConsumerWidget {
  const SiteSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final permissions =
        ref.watch(sitePermissionsProvider).value ?? const <SitePermission>[];
    final library = ref.read(libraryProvider);
    final bySite = <String, List<SitePermission>>{};
    for (final p in permissions) {
      bySite.putIfAbsent(p.origin, () => []).add(p);
    }
    String kind(SitePermissionKind k) => switch (k) {
      SitePermissionKind.camera => l10n.camera,
      SitePermissionKind.microphone => l10n.microphone,
      SitePermissionKind.location => l10n.location,
    };
    IconData icon(SitePermissionKind k) => switch (k) {
      SitePermissionKind.camera => HIcons.videocam,
      SitePermissionKind.microphone => HIcons.mic,
      SitePermissionKind.location => HIcons.locationOn,
    };
    return _Screen(
      title: l10n.siteSettings,
      subtitle: l10n.siteSettingsSub,
      children: [
        if (bySite.isEmpty)
          EmptyState(
            icon: HIcons.tune,
            title: l10n.noSitePermissions,
            hint: l10n.noSitePermissionsHint,
          ),
        for (final entry in bySite.entries) ...[
          SectionHeader(Uri.tryParse(entry.key)?.host ?? entry.key),
          ListGroup(
            rows: [
              for (final p in entry.value)
                ListRow(
                  leading: IconWell(icon: icon(p.kind)),
                  title: kind(p.kind),
                  subtitle: p.allowed ? l10n.allowed : l10n.blocked,
                  minHeight: 64,
                  trailing: HorizontSwitch(
                    value: p.allowed,
                    semanticLabel: kind(p.kind),
                    onChanged: (v) =>
                        unawaited(library.setPermission(p.origin, p.kind, v)),
                  ),
                ),
            ],
          ),
        ],
        if (bySite.isNotEmpty) ...[
          const SizedBox(height: 20),
          PillButton(
            label: l10n.resetAll,
            height: 52,
            look: ButtonLook.errorContainer,
            onTap: () => unawaited(library.clearPermissions()),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.siteSettingsSub,
          style: HorizontType.aside.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Downloads: ask before saving or not.
class DownloadSettingsPage extends ConsumerWidget {
  const DownloadSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    return _Screen(
      title: l10n.downloads,
      subtitle: l10n.savedInDownload,
      children: [
        ListGroup(
          rows: [
            ListRow(
              leading: const IconWell(icon: HIcons.download),
              title: l10n.askBeforeDownload,
              subtitle: l10n.downloadAsk,
              minHeight: 72,
              trailing: HorizontSwitch(
                value: s.askBeforeDownload,
                semanticLabel: l10n.askBeforeDownload,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((s) => s.copyWith(askBeforeDownload: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Bedienungshilfen: force zoom, text sizes per site.
class AccessibilityPage extends ConsumerWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final hosts = s.textZoomByHost.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return _Screen(
      title: l10n.accessibility,
      children: [
        ListGroup(
          rows: [
            ListRow(
              leading: const IconWell(icon: HIcons.zoomIn),
              title: l10n.forceZoom,
              subtitle: l10n.forceZoomSub,
              minHeight: 72,
              trailing: HorizontSwitch(
                value: s.forceZoom,
                semanticLabel: l10n.forceZoom,
                onChanged: (v) =>
                    notifier.update((s) => s.copyWith(forceZoom: v)),
              ),
            ),
          ],
        ),
        SectionHeader(l10n.textSizePerSite),
        if (hosts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.textSizePerSiteHint,
              style: HorizontType.body.copyWith(color: scheme.onSurfaceVariant),
            ),
          )
        else
          ListGroup(
            rows: [
              for (final e in hosts)
                ListRow(
                  leading: Monogram(
                    e.key.isEmpty ? '·' : e.key[0].toUpperCase(),
                  ),
                  title: e.key,
                  minHeight: 64,
                  trailing: ValueStepper(
                    value: e.value,
                    lessLabel: l10n.smaller,
                    moreLabel: l10n.bigger,
                    onChanged: (v) =>
                        notifier.update((s) => s.withTextZoom(e.key, v)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Über Horizont: version, what it is built on, the licences.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return _Screen(
      title: l10n.about,
      subtitle: l10n.version(appVersion),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            spacing: 20,
            children: [
              MorphingShapeBadge(
                preset: ShapePreset.sunny,
                size: 96,
                color: scheme.primary,
                child: Text(
                  'H',
                  style: HorizontType.brand.copyWith(color: scheme.onPrimary),
                ),
              ),
              Expanded(
                child: Text(
                  l10n.aboutBody,
                  style: HorizontType.body.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        SectionHeader(l10n.bundledData),
        ListGroup(
          rows: [
            ListRow(
              leading: const IconWell(icon: HIcons.gavel),
              title: l10n.licences,
              subtitle: l10n.licencesSub,
              minHeight: 72,
              trailing: SymbolIcon(
                HIcons.chevronRight,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: appVersion,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
