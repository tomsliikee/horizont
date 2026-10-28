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
import 'favourites_grid.dart';
import 'living_backdrop.dart';
import 'quick_chips.dart';
import 'start_header.dart';
import 'tabs_row.dart';

/// Opens the search, growing from [origin] when given, with [initial] text.
typedef StartSearch = void Function({Rect? origin, String? initial});

/// The start page (`P:60`–`P:128`): a head that shrinks into a bar, the
/// search, quick actions, the other open and recently closed tabs,
/// favourites, the most visited pages, the reading list and a small privacy
/// line at the end, over slowly drifting shapes.
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
  final StartSearch? onSearch;

  /// Extra room for a bar at the top (layouts oben, expressiv).
  final double topPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top + topPadding;
    final locale = Localizations.localeOf(context).toString();
    final now = ref.read(clockProvider)();
    final date = DateFormat.MMMMEEEEd(locale).format(now);
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
      body: Stack(
        children: [
          const Positioned.fill(child: LivingBackdrop()),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: StartHeaderDelegate(
                  top: top,
                  greeting: '${_greeting(l10n, now.hour)} · $date',
                  title: l10n.appName,
                  settingsLabel: l10n.settings,
                  onSettings: () => unawaited(
                    Navigator.of(context)
                        .push(screenRoute<void>(const SettingsPage())),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                sliver: SliverList.list(
                  children: [
                    stagger(
                      _SearchHero(
                        label: l10n.searchOrEnterAddressLong,
                        onTap: onSearch == null
                            ? null
                            : (origin) => onSearch!(origin: origin),
                      ),
                    ),
                    const SizedBox(height: 14),
                    stagger(
                      QuickChips(
                        onPrivate: () =>
                            ref.read(tabsProvider.notifier).enterPrivate(),
                        onOpen: onOpen,
                        onSearch: (text) => onSearch?.call(initial: text),
                      ),
                    ),
                    if (sections.contains(StartSection.tabs))
                      stagger(const TabsSection()),
                    if (sections.contains(StartSection.favourites) &&
                        favourites.isNotEmpty)
                      stagger(
                        FavouritesGrid(
                          favourites: favourites,
                          onOpen: onOpen,
                          onOpenInNewTab: onOpenInNewTab,
                        ),
                      ),
                    if (sections.contains(StartSection.frequent) &&
                        frequent.isNotEmpty) ...[
                      SectionHeader(l10n.frequentlyVisited),
                      stagger(
                        ListGroup(
                          rows: [
                            for (final p in frequent)
                              ListRow(
                                leading: Monogram(
                                  _letter(
                                    p.title.isEmpty ? _host(p.url) : p.title,
                                  ),
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
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
                    if (sections.contains(StartSection.privacyReport)) ...[
                      const SizedBox(height: 28),
                      stagger(
                        _ReportRow(
                          report: report,
                          onTap: () => unawaited(
                            Navigator.of(context)
                                .push(screenRoute<void>(const PrivacyPage())),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

/// The privacy report as one quiet line at the end: the count on a small
/// shape that morphs and counts up when it changes.
class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.report, required this.onTap});

  final TrackerReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Squish(
      onTap: onTap,
      pressedScale: 0.97,
      semanticLabel: l10n.trackersThisWeek(report.week),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: ShapeDecoration(
          color: scheme.surfaceBright.withValues(alpha: 0.85),
          shape: const StadiumBorder(),
        ),
        child: Row(
          spacing: 12,
          children: [
            MorphingMaterialBadge(
              shape: report.week == 0
                  ? MaterialShapes.cookie9Sided
                  : reportShape(report.week),
              size: 40,
              color: scheme.primaryContainer,
              child: SymbolIcon(
                HIcons.shield,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            Expanded(
              child: CountUp(
                value: report.week,
                format: l10n.trackersThisWeek,
                style: HorizontType.bodyStrong.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            SymbolIcon(
              HIcons.chevronRight,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
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

/// The big search pill under the head: tapping it opens the search, which
/// grows out of the pill.
class _SearchHero extends StatefulWidget {
  const _SearchHero({required this.label, required this.onTap});

  final String label;
  final ValueChanged<Rect?>? onTap;

  @override
  State<_SearchHero> createState() => _SearchHeroState();
}

class _SearchHeroState extends State<_SearchHero> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onTap = widget.onTap;
    return Squish(
      onTap: onTap == null ? null : () => onTap(rectOf(_key)),
      pressedScale: 0.97,
      semanticLabel: widget.label,
      child: Container(
        key: _key,
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
                widget.label,
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
