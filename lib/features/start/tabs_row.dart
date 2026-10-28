import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../browser/tabs/browser_tab.dart';
import '../../browser/tabs/closed_tabs.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../browser/tabs/thumbnail_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/squish.dart';

/// The row of tabs with its heading, or nothing when there are no other
/// open tabs and none closed. It watches the tabs itself, so the rest of the
/// start page is not built again when a tab changes (PLAN N4).
class TabsSection extends ConsumerWidget {
  const TabsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (open, closed) = TabsRow.entries(ref);
    if (open.isEmpty && closed.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(open.isEmpty ? l10n.recentlyClosed : l10n.tabs),
        const TabsRow(),
      ],
    );
  }
}

/// The other open tabs, last used first, then the recently closed ones with
/// an undo mark.
class TabsRow extends ConsumerWidget {
  const TabsRow({super.key});

  static const height = 148.0;

  /// The open tabs and closed tabs the row shows.
  static (List<BrowserTab>, List<ClosedTab>) entries(WidgetRef ref) {
    final tabs = ref.watch(tabsProvider);
    final open =
        tabs.normalTabs
            .where((t) => t.id != tabs.activeId && t.url != null)
            .toList()
          ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
    return (open, ref.watch(closedTabsProvider));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (open, closed) = entries(ref);
    final notifier = ref.read(tabsProvider.notifier);
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: [
          for (final t in open)
            _TabTile(
              key: ValueKey(t.id),
              title: t.displayTitle(t.host),
              host: t.host,
              thumbnail: t.thumbnailPath,
              pageColor: t.pageColor,
              semanticLabel: t.displayTitle(t.host),
              onTap: () => notifier.activate(t.id),
            ),
          for (final c in closed)
            _TabTile(
              key: ValueKey('closed-${c.id}'),
              title: c.title.isEmpty ? c.host : c.title,
              host: c.host,
              thumbnail: c.thumbnailPath,
              pageColor: c.pageColor,
              closed: true,
              semanticLabel: l10n.reopenTab(c.title.isEmpty ? c.host : c.title),
              onTap: () => notifier.reopenClosed(c.id),
            ),
        ],
      ),
    );
  }
}

class _TabTile extends StatelessWidget {
  const _TabTile({
    super.key,
    required this.title,
    required this.host,
    required this.thumbnail,
    required this.pageColor,
    required this.semanticLabel,
    required this.onTap,
    this.closed = false,
  });

  final String title;
  final String host;
  final String? thumbnail;
  final Color? pageColor;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter = host.isEmpty
        ? '·'
        : (host.startsWith('www.') ? host.substring(4) : host).characters.first
              .toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Squish(
        semanticLabel: semanticLabel,
        pressedScale: 0.95,
        onTap: onTap,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Container(
                height: 104,
                width: 120,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: pageColor ?? scheme.surfaceBright,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbnail != null)
                      Opacity(
                        // A closed tab is a little faded, like a memory.
                        opacity: closed ? 0.55 : 1,
                        child: Image(
                          image: thumbnailImage(thumbnail!, cacheWidth: 360),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          letter,
                          style: HorizontType.monogramLarge.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (closed)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: ShapeDecoration(
                            color: scheme.secondaryContainer,
                            shape: const CircleBorder(),
                          ),
                          child: SymbolIcon(
                            HIcons.undo,
                            size: 18,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HorizontType.label.copyWith(
                  color: closed ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
