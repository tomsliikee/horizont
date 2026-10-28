import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../app/page_actions.dart';
import '../../app/routes.dart';
import '../../app/system_ui.dart';
import '../../browser/tabs/closed_tabs.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/haptics.dart';
import '../../ui/lists.dart';
import '../../ui/motion/flip.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/squish.dart';
import '../../ui/tiles.dart';
import '../downloads/downloads_page.dart' show GroupRadius;

/// Which part of the library is shown.
enum LibrarySection { bookmarks, history, reading }

/// What the library asks the browser to open.
@immutable
class LibraryResult {
  const LibraryResult(this.url, {this.offlinePath});
  final Uri url;

  /// The saved copy of a reading list item, for reading offline.
  final String? offlinePath;
}

/// The library (`P:388`–`P:447`): bookmarks as folder tiles, history by day,
/// the reading list with what is left to read. Pops with a [LibraryResult].
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key, this.initial = LibrarySection.history});

  final LibrarySection initial;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  late var _section = widget.initial;
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _open(LibraryResult result) {
    Haptics.play(Haptic.tap);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top + 12;
    final placeholder = switch (_section) {
      LibrarySection.history => l10n.searchHistory,
      LibrarySection.bookmarks => l10n.searchBookmarks,
      LibrarySection.reading => l10n.searchReadingList,
    };
    final query = _query.text.trim();
    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: StatusBand(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, top, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                l10n.library,
                                style: HorizontType.display.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          PillButton(
                            label: l10n.done,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentRow(
                        labels: [
                          l10n.bookmarks,
                          l10n.history,
                          l10n.readingList,
                        ],
                        icons: const [
                          HIcons.bookmarks,
                          HIcons.history,
                          HIcons.eyeglasses,
                        ],
                        fill: scheme.surfaceContainerHighest,
                        selected: _section.index,
                        onSelected: (i) => setState(() {
                          _section = LibrarySection.values[i];
                          _query.clear();
                        }),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            SymbolIcon(
                              HIcons.search,
                              size: 22,
                              color: scheme.onSurfaceVariant,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _query,
                                cursorColor: scheme.primary,
                                style: HorizontType.body.copyWith(
                                  fontSize: 15,
                                  color: scheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: placeholder,
                                  hintStyle: HorizontType.body.copyWith(
                                    fontSize: 15,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            if (query.isNotEmpty)
                              Squish(
                                semanticLabel: l10n.clearInput,
                                onTap: _query.clear,
                                child: SymbolIcon(
                                  HIcons.cancel,
                                  size: 20,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...switch (_section) {
                LibrarySection.history => _history(query),
                LibrarySection.bookmarks => _bookmarks(query),
                LibrarySection.reading => _reading(query),
              },
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _history(String query) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final visits = ref.watch(historyProvider(query)).value;
    if (visits == null) return const [];
    if (visits.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: HIcons.history,
            title: query.isEmpty ? l10n.emptyHistory : l10n.nothingFound,
            hint: query.isEmpty ? l10n.emptyHistoryHint : '',
          ),
        ),
      ];
    }
    final now = ref.read(clockProvider)();
    final groups = <String, List<HistoryVisit>>{};
    for (final v in visits) {
      groups.putIfAbsent(_day(v.visitedAt, now, l10n, locale), () => []).add(v);
    }
    var index = 0;
    return [
      for (final entry in groups.entries) ...[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: SectionHeader(entry.key)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: entry.value.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final v = entry.value[i];
              final host = _host(v.url);
              return StaggeredEntrance(
                key: ValueKey(v.id),
                index: index++,
                child: _Removable(
                  key: ValueKey('d${v.id}'),
                  onRemove: () => ref.read(libraryProvider).deleteVisit(v.id),
                  child: FlipSlot(
                    child: ListRow(
                      leading: Monogram(
                        _letter(v.title.isEmpty ? host : v.title),
                      ),
                      title: v.title.isEmpty ? host : v.title,
                      subtitle: host,
                      borderRadius: GroupRadius.of(
                        context,
                        i,
                        entry.value.length,
                      ),
                      trailing: Text(
                        DateFormat.Hm(locale).format(v.visitedAt),
                        style: HorizontType.label.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _open(LibraryResult(v.url)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
      if (query.isEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: PillButton(
              label: l10n.clearHistory,
              height: 52,
              look: ButtonLook.errorContainer,
              onTap: () async {
                final ok = await confirm(
                  context,
                  title: l10n.clearHistoryTitle,
                  body: l10n.clearHistoryBody,
                  action: l10n.delete,
                );
                if (!ok) return;
                await ref.read(libraryProvider).clearHistory();
                ref.read(closedTabsProvider.notifier).clear();
              },
            ),
          ),
        ),
    ];
  }

  List<Widget> _bookmarks(String query) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (query.isNotEmpty) {
      return [
        SliverToBoxAdapter(
          child: FutureBuilder<List<Bookmark>>(
            future: ref.read(libraryProvider).searchBookmarks(query, limit: 50),
            builder: (context, snapshot) {
              final found = snapshot.data ?? const <Bookmark>[];
              if (snapshot.hasData && found.isEmpty) {
                return EmptyState(
                  icon: HIcons.bookmarks,
                  title: l10n.nothingFound,
                  hint: '',
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: ListGroup(
                  rows: [
                    for (final b in found)
                      ListRow(
                        leading: Monogram(_letter(b.title)),
                        title: b.title.isEmpty ? _host(b.url) : b.title,
                        subtitle: _host(b.url),
                        onTap: () => _open(LibraryResult(b.url)),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ];
    }
    final folders =
        ref.watch(foldersProvider).value ?? const <BookmarkFolder>[];
    (Color, Color, Color, Color) tones(FolderTone tone) => switch (tone) {
      FolderTone.primary => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        scheme.primary,
        scheme.onPrimary,
      ),
      FolderTone.secondary => (
        scheme.surfaceBright,
        scheme.onSurface,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      FolderTone.tertiary => (
        scheme.surfaceBright,
        scheme.onSurface,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      FolderTone.neutral => (
        scheme.surfaceBright,
        scheme.onSurface,
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
    };
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 124,
          ),
          delegate: SliverChildListDelegate([
            for (var i = 0; i < folders.length; i++)
              StaggeredEntrance(
                key: ValueKey(folders[i].id),
                index: i,
                child: FlipSlot(
                  child: () {
                    final f = folders[i];
                    final (fill, ink, badge, badgeInk) = tones(f.tone);
                    return FolderTile(
                      icon: folderIcon(f.icon),
                      title: f.name,
                      subtitle: l10n.bookmarkCount(f.count),
                      fill: fill,
                      ink: ink,
                      badge: badge,
                      badgeInk: badgeInk,
                      onTap: () async {
                        final result = await Navigator.of(context).push(
                          screenRoute<LibraryResult>(FolderPage(folder: f)),
                        );
                        if (result != null) _open(result);
                      },
                      onLongPress: f.isFavorites
                          ? null
                          : () => _folderActions(f),
                    );
                  }(),
                ),
              ),
            StaggeredEntrance(
              index: folders.length,
              child: Squish(
                semanticLabel: l10n.newFolder,
                onTap: () async {
                  final name = await askText(
                    context,
                    title: l10n.newFolder,
                    label: l10n.folderName,
                    action: l10n.create,
                  );
                  if (name != null && name.trim().isNotEmpty) {
                    await ref
                        .read(libraryProvider)
                        .createFolder(
                          name.trim(),
                          tone: FolderTone.values[1 + folders.length % 3],
                        );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: scheme.outlineVariant, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      SymbolIcon(HIcons.add, color: scheme.onSurfaceVariant),
                      Text(
                        l10n.newFolder,
                        style: HorizontType.tileLabel.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    ];
  }

  Future<void> _folderActions(BookmarkFolder f) async {
    final l10n = AppLocalizations.of(context);
    final library = ref.read(libraryProvider);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DragHandle(),
              ListGroup(
                rows: [
                  ListRow(
                    leading: const IconWell(icon: HIcons.edit),
                    title: l10n.rename,
                    minHeight: 56,
                    onTap: () => Navigator.of(context).pop('rename'),
                  ),
                  ListRow(
                    leading: const IconWell(icon: HIcons.deleteIcon),
                    title: l10n.deleteFolder,
                    minHeight: 56,
                    onTap: () => Navigator.of(context).pop('delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'rename') {
      final name = await askText(
        context,
        title: l10n.rename,
        label: l10n.folderName,
        action: l10n.rename,
        initial: f.name,
      );
      if (name != null && name.trim().isNotEmpty) {
        await library.renameFolder(f.id, name.trim());
      }
    } else if (action == 'delete') {
      final ok = await confirm(
        context,
        title: l10n.deleteFolderTitle(f.name),
        body: l10n.deleteFolderBody,
        action: l10n.delete,
      );
      if (ok) await library.deleteFolder(f.id);
    }
  }

  List<Widget> _reading(String query) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final all = ref.watch(readingListProvider).value;
    if (all == null) return const [];
    final q = query.toLowerCase();
    final items = all
        .where(
          (r) =>
              q.isEmpty ||
              r.title.toLowerCase().contains(q) ||
              r.host.contains(q),
        )
        .toList();
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: EmptyState(
            icon: HIcons.eyeglasses,
            title: query.isEmpty ? l10n.emptyReading : l10n.nothingFound,
            hint: query.isEmpty ? l10n.emptyReadingHint : '',
          ),
        ),
      ];
    }
    final bands = [
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.primaryContainer,
    ];
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final r = items[i];
            return StaggeredEntrance(
              key: ValueKey(r.id),
              index: i,
              child: _Removable(
                key: ValueKey('r${r.id}'),
                onRemove: () => ref.read(libraryProvider).removeReading(r.id),
                child: ReadingRow(
                  item: r,
                  band: bands[i % bands.length],
                  onTap: () =>
                      _open(LibraryResult(r.url, offlinePath: r.offlinePath)),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  static String _host(Uri url) =>
      url.host.startsWith('www.') ? url.host.substring(4) : url.host;

  static String _letter(String text) =>
      text.trim().isEmpty ? '·' : text.trim().characters.first.toUpperCase();

  static String _day(
    DateTime at,
    DateTime now,
    AppLocalizations l10n,
    String locale,
  ) {
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    if (same(at, now)) return l10n.today;
    if (same(at, now.subtract(const Duration(days: 1)))) return l10n.yesterday;
    return DateFormat.MMMMEEEEd(locale).format(at);
  }
}

/// A row that is flicked sideways to remove it; it flies off with the
/// finger's speed and a tick marks the moment it will go.
class _Removable extends StatefulWidget {
  const _Removable({super.key, required this.child, required this.onRemove});

  final Widget child;
  final Future<void> Function() onRemove;

  @override
  State<_Removable> createState() => _RemovableState();
}

class _RemovableState extends State<_Removable> {
  // A dismissed row leaves the tree at once; the list catches up when the
  // library has been written.
  var _gone = false;

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: widget.key!,
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.35,
        DismissDirection.endToStart: 0.35,
      },
      onUpdate: (details) {
        if (details.reached != details.previousReached) {
          Haptics.play(details.reached ? Haptic.threshold : Haptic.release);
        }
      },
      onDismissed: (_) {
        setState(() => _gone = true);
        unawaited(widget.onRemove());
      },
      background: _RemoveHint(
        alignment: Alignment.centerLeft,
        label: l10n.remove,
        scheme: scheme,
      ),
      secondaryBackground: _RemoveHint(
        alignment: Alignment.centerRight,
        label: l10n.remove,
        scheme: scheme,
      ),
      child: widget.child,
    );
  }
}

class _RemoveHint extends StatelessWidget {
  const _RemoveHint({
    required this.alignment,
    required this.label,
    required this.scheme,
  });

  final Alignment alignment;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: scheme.errorContainer,
      borderRadius: BorderRadius.circular(24),
    ),
    child: SymbolIcon(HIcons.deleteIcon, color: scheme.onErrorContainer),
  );
}

/// A reading list item (`P:435`): an 88 square in a container tone, title,
/// host and minutes, the state in `primary`.
class ReadingRow extends StatelessWidget {
  const ReadingRow({
    super.key,
    required this.item,
    required this.band,
    required this.onTap,
  });

  final ReadingItem item;
  final Color band;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = switch (item.state) {
      ReadingState.unread => l10n.readingUnread,
      ReadingState.started => l10n.readingStarted,
      ReadingState.half => l10n.readingHalf,
      ReadingState.almostDone => l10n.readingAlmost,
      ReadingState.offline => l10n.readingOffline,
    };
    return Squish(
      onTap: onTap,
      semanticLabel: item.title,
      pressedScale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceBright,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          spacing: 14,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: band,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(10),
              child: item.readFraction > 0
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.readFraction,
                        minHeight: 6,
                        color: scheme.primary,
                        backgroundColor: scheme.surfaceBright,
                      ),
                    )
                  : null,
            ),
            Expanded(
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
                    item.estimatedMinutes > 0
                        ? '${item.host} · ${l10n.readMinutes(item.estimatedMinutes)}'
                        : item.host,
                    style: HorizontType.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    state,
                    style: HorizontType.bodyStrong.copyWith(
                      color: scheme.primary,
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

/// The bookmarks of one folder (D18).
class FolderPage extends ConsumerWidget {
  const FolderPage({super.key, required this.folder});

  final BookmarkFolder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bookmarks = ref.watch(bookmarksInProvider(folder.id)).value;
    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: StatusBand(
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
            ),
            children: [
              ScreenHeader(
                title: folder.name,
                subtitle: l10n.bookmarkCount(bookmarks?.length ?? folder.count),
                backLabel: l10n.back,
              ),
              if (bookmarks != null && bookmarks.isEmpty)
                EmptyState(
                  icon: HIcons.bookmarkAdd,
                  title: l10n.emptyFolder,
                  hint: l10n.emptyFolderHint,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  spacing: 4,
                  children: [
                    for (var i = 0; i < (bookmarks?.length ?? 0); i++)
                      StaggeredEntrance(
                        key: ValueKey(bookmarks![i].id),
                        index: i,
                        child: _Removable(
                          key: ValueKey('b${bookmarks[i].id}'),
                          onRemove: () => ref
                              .read(libraryProvider)
                              .removeBookmark(bookmarks[i].id),
                          child: ListRow(
                            leading: Monogram(
                              _LibraryPageState._letter(bookmarks[i].title),
                            ),
                            title: bookmarks[i].title.isEmpty
                                ? _LibraryPageState._host(bookmarks[i].url)
                                : bookmarks[i].title,
                            subtitle: _LibraryPageState._host(bookmarks[i].url),
                            borderRadius: GroupRadius.of(
                              context,
                              i,
                              bookmarks.length,
                            ),
                            trailing: SymbolIcon(
                              HIcons.chevronRight,
                              size: 22,
                              color: scheme.onSurfaceVariant,
                            ),
                            onTap: () =>
                                Navigator.of(context)
                                    .pop(LibraryResult(bookmarks[i].url)),
                          ),
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
