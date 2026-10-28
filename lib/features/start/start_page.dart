import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/lists.dart';
import '../../ui/motion/count_up.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/shapes.dart';
import '../../ui/squish.dart';
import '../../ui/tiles.dart';
import '../settings/privacy_page.dart';
import '../settings/settings_page.dart';

/// The start page (`P:60`–`P:128`): the privacy report, favourites, the
/// most visited pages and the reading list, from the library.
class StartPage extends ConsumerWidget {
  const StartPage({
    super.key,
    required this.onOpen,
    this.onOpenInNewTab,
    this.onSearch,
    this.topPadding = 0,
  });

  final ValueChanged<Uri> onOpen;
  final ValueChanged<Uri>? onOpenInNewTab;

  /// Opens the search; the big search pill calls it.
  final VoidCallback? onSearch;

  /// Extra room for a bar at the top (layouts oben, expressiv).
  final double topPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top + 16 + topPadding;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMMEEEEd(locale).format(ref.read(clockProvider)());
    final sections = ref.watch(settingsProvider.select((s) => s.startSections));
    final favourites =
        ref.watch(favouritesProvider).value ?? const <Bookmark>[];
    final frequent = ref.watch(frequentProvider).value ?? const <HistoryPage>[];
    final reading =
        ref.watch(readingListProvider).value ?? const <ReadingItem>[];
    final report =
        ref.watch(trackerReportProvider).value ?? const TrackerReport();
    var i = 0;
    Widget stagger(Widget child) => StaggeredEntrance(index: i++, child: child);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, top, 16, 150),
        children: [
          stagger(
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting(l10n, ref.read(clockProvider)().hour)} · $date',
                          style: HorizontType.subtitle.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          l10n.appName,
                          style: HorizontType.brand.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoundButton(
                    icon: HIcons.settings,
                    semanticLabel: l10n.settings,
                    look: ButtonLook.bright,
                    onTap: () => unawaited(
                      Navigator.of(context)
                          .push(screenRoute<void>(const SettingsPage())),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          stagger(
            _SearchHero(label: l10n.searchOrEnterAddressLong, onTap: onSearch),
          ),
          if (sections.contains(StartSection.privacyReport)) ...[
            const SizedBox(height: 20),
            stagger(
              _ReportCard(
                report: report,
                onTap: () => unawaited(
                  Navigator.of(context)
                      .push(screenRoute<void>(const PrivacyPage())),
                ),
              ),
            ),
          ],
          if (sections.contains(StartSection.favourites) &&
              favourites.isNotEmpty) ...[
            SectionHeader(l10n.favourites),
            stagger(
              GridView.count(
                crossAxisCount: 4,
                // A GridView in a ListView would otherwise add the status bar
                // inset as padding.
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.92,
                children: [
                  for (var f = 0; f < favourites.length && f < 8; f++)
                    _Favourite(
                      bookmark: favourites[f],
                      index: f,
                      onTap: () => onOpen(favourites[f].url),
                      onLongPress: () =>
                          _favouriteActions(context, ref, favourites[f]),
                    ),
                ],
              ),
            ),
          ],
          if (sections.contains(StartSection.frequent) &&
              frequent.isNotEmpty) ...[
            SectionHeader(l10n.frequentlyVisited),
            stagger(
              ListGroup(
                rows: [
                  for (final p in frequent)
                    ListRow(
                      leading: Monogram(
                        _letter(p.title.isEmpty ? _host(p.url) : p.title),
                      ),
                      title: p.title.isEmpty ? _host(p.url) : p.title,
                      subtitle: _host(p.url),
                      trailing: SymbolIcon(
                        HIcons.northWest,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () => onOpen(p.url),
                    ),
                ],
              ),
            ),
          ],
          if (sections.contains(StartSection.readingList) &&
              reading.isNotEmpty) ...[
            SectionHeader(l10n.readingList),
            stagger(
              SizedBox(
                height: 196,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  itemCount: reading.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, r) => _ReadingCard(
                    band: [
                      scheme.secondaryContainer,
                      scheme.tertiaryContainer,
                      scheme.primaryContainer,
                    ][r % 3],
                    item: reading[r],
                    onTap: () => onOpen(reading[r].url),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _favouriteActions(
    BuildContext context,
    WidgetRef ref,
    Bookmark b,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DragHandle(),
              ListGroup(
                rows: [
                  if (onOpenInNewTab != null)
                    ListRow(
                      leading: const IconWell(icon: HIcons.add),
                      title: l10n.newTab,
                      minHeight: 56,
                      onTap: () => Navigator.of(context).pop('tab'),
                    ),
                  ListRow(
                    leading: const IconWell(icon: HIcons.deleteIcon),
                    title: l10n.remove,
                    minHeight: 56,
                    onTap: () => Navigator.of(context).pop('remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'tab') onOpenInNewTab?.call(b.url);
    if (action == 'remove') {
      await ref.read(libraryProvider).removeBookmark(b.id);
    }
  }

  static String _greeting(AppLocalizations l10n, int hour) => switch (hour) {
    >= 5 && < 11 => l10n.greetingMorning,
    >= 11 && < 18 => l10n.greetingAfternoon,
    >= 18 && < 23 => l10n.greetingEvening,
    _ => l10n.greetingNight,
  };

  static String _host(Uri url) =>
      url.host.startsWith('www.') ? url.host.substring(4) : url.host;

  static String _letter(String text) =>
      text.trim().isEmpty ? '·' : text.trim().characters.first.toUpperCase();
}

/// The privacy report hero (`P:70`): the count morphs its shape and counts
/// up when it changes.
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final TrackerReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ink = scheme.onPrimaryContainer;
    return Squish(
      onTap: onTap,
      pressedScale: 0.97,
      semanticLabel: '${l10n.trackersBlocked}, ${report.week}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          spacing: 20,
          children: [
            MorphingMaterialBadge(
              shape: report.week == 0
                  ? MaterialShapes.cookie9Sided
                  : reportShape(report.week),
              size: 116,
              color: scheme.primary,
              child: CountUp(
                value: report.week,
                style: HorizontType.badgeNumber.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    l10n.privacyReportLabel,
                    style: HorizontType.label.copyWith(color: ink),
                  ),
                  Text(
                    l10n.trackersBlocked,
                    style: HorizontType.title.copyWith(color: ink),
                  ),
                  Text(
                    trackerComparison(l10n, report),
                    style: HorizontType.bodyStrong.copyWith(color: ink),
                  ),
                  Text(
                    l10n.countedOnDevice,
                    style: HorizontType.aside.copyWith(color: ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A favourite: a letter on a shape; it squishes and turns a little on press
/// (PLAN 6.2, Shapes).
class _Favourite extends StatelessWidget {
  const _Favourite({
    required this.bookmark,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  final Bookmark bookmark;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = bookmark.title.isEmpty ? bookmark.url.host : bookmark.title;
    return Squish(
      semanticLabel: title,
      onTap: onTap,
      onLongPress: onLongPress,
      morph: (context, pressed) => Column(
        spacing: 6,
        children: [
          MaterialShapeBadge(
            shape: materialFavourite(index),
            pressedShape: MaterialShapes.circle,
            pressed: pressed,
            size: 68,
            color: [
              scheme.primaryContainer,
              scheme.tertiaryContainer,
              scheme.secondaryContainer,
              scheme.surfaceBright,
            ][index % 4],
            child: Text(
              title.characters.first.toUpperCase(),
              style: HorizontType.monogramLarge.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HorizontType.label.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.band,
    required this.item,
    required this.onTap,
  });

  final Color band;
  final ReadingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final meta = item.estimatedMinutes > 0
        ? '${item.host} · ${l10n.readMinutes(item.estimatedMinutes)}'
        : item.host;
    return Squish(
      semanticLabel: item.title,
      pressedScale: 0.97,
      onTap: onTap,
      child: Container(
        width: 240,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surfaceBright,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              color: band,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(12),
              child: item.readFraction > 0
                  ? SizedBox(
                      width: 80,
                      child: LinearBar(value: item.readFraction),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    item.title.isEmpty ? item.host : item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HorizontType.title.copyWith(color: scheme.onSurface),
                  ),
                  Text(
                    meta,
                    style: HorizontType.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The big search pill under the header: tapping it opens the search.
class _SearchHero extends StatelessWidget {
  const _SearchHero({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Squish(
      onTap: onTap,
      pressedScale: 0.97,
      semanticLabel: label,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: ShapeDecoration(
          color: scheme.surfaceBright,
          shape: const StadiumBorder(),
        ),
        child: Row(
          spacing: 14,
          children: [
            SymbolIcon(HIcons.search, size: 24, color: scheme.primary),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HorizontType.bodyStrong.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
