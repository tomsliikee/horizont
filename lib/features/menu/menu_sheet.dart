import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/page_actions.dart';
import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../browser/browser_providers.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../data/library_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extensions.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/tiles.dart';

/// Where the menu leads; the shell acts on it after the sheet has closed.
enum MenuDestination {
  find,
  tabs,
  library,
  downloads,
  privateTab,
  newTab,
  settings,
}

/// Opens the menu (`P:262`–`P:310`) out of the button at [origin].
Future<MenuDestination?> showMenuSheet(
  BuildContext context, {
  required Rect? origin,
  required PageActions actions,
}) {
  final l10n = AppLocalizations.of(context);
  return showGrowSheet<MenuDestination>(
    context,
    origin: origin,
    barrierLabel: l10n.closeMenu,
    builder: (context, close) => MenuSheet(actions: actions, close: close),
  );
}

class MenuSheet extends ConsumerWidget {
  const MenuSheet({super.key, required this.actions, required this.close});

  final PageActions actions;
  final CloseSheet close;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final page = ref.watch(pageStateProvider);
    final tabs = ref.watch(tabsProvider);
    final url = page.url;
    final onPage = url != null && page.error == null;
    final saved =
        url != null && (ref.watch(isBookmarkedProvider(url)).value ?? false);
    final reading =
        url != null && (ref.watch(isInReadingListProvider(url)).value ?? false);
    final zoom = ref.watch(
      settingsProvider.select((s) => s.textZoomFor(page.host)),
    );
    var i = 0;
    Widget stagger(Widget child) =>
        StaggeredEntrance(index: i++, offset: 12, child: child);

    void run(Future<void> Function() action) {
      unawaited(close());
      unawaited(action());
    }

    final title = url == null
        ? l10n.startPage
        : page.title.isEmpty
        ? page.displayHost
        : page.title;
    final rows = <ListRow>[
      ListRow(
        leading: SymbolIcon(
          HIcons.chromeReaderMode,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        title: l10n.readerView,
        minHeight: 60,
        trailing: HorizontSwitch(
          value: page.reader,
          semanticLabel: l10n.readerView,
          onChanged: onPage
              ? (on) => run(() => actions.setReader(context, on))
              : null,
        ),
      ),
      ListRow(
        leading: SymbolIcon(
          HIcons.formatSize,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        title: l10n.textSize,
        minHeight: 60,
        trailing: ValueStepper(
          value: zoom,
          lessLabel: l10n.smaller,
          moreLabel: l10n.bigger,
          onChanged: onPage ? (v) => unawaited(actions.setTextZoom(v)) : (_) {},
        ),
      ),
      ListRow(
        leading: SymbolIcon(
          HIcons.desktopWindows,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        title: page.desktop ? l10n.mobileSite : l10n.desktopSite,
        minHeight: 56,
        onTap: onPage ? () => run(actions.toggleDesktop) : null,
      ),
      ListRow(
        leading: SymbolIcon(
          HIcons.addToHomeScreen,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
        title: l10n.addToHomeScreen,
        minHeight: 56,
        onTap: onPage
            ? () => run(() => actions.addToHomeScreen(context))
            : null,
      ),
    ];

    final grid = [
      (
        HIcons.tab,
        l10n.tabsWithCount(tabs.visible.length),
        MenuDestination.tabs,
      ),
      (HIcons.bookmarks, l10n.library, MenuDestination.library),
      (HIcons.download, l10n.downloads, MenuDestination.downloads),
      (HIcons.visibilityOff, l10n.privateTab, MenuDestination.privateTab),
      (HIcons.add, l10n.newTab, MenuDestination.newTab),
      (HIcons.settings, l10n.settings, MenuDestination.settings),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DragHandle(),
          stagger(
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
              child: Row(
                spacing: 12,
                children: [
                  Monogram(
                    title.isEmpty ? '·' : title.characters.first.toUpperCase(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HorizontType.title.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        if (url != null)
                          Row(
                            spacing: 4,
                            children: [
                              SymbolIcon(
                                page.secure ? HIcons.lock : HIcons.gppMaybe,
                                size: 14,
                                color: page.secure
                                    ? HorizontColors.of(context).statusGood
                                    : scheme.error,
                              ),
                              Flexible(
                                child: Text(
                                  '${page.displayHost} · ${page.secure ? l10n.connectionSecure : l10n.connectionInsecure}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HorizontType.caption.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  RoundButton(
                    icon: HIcons.close,
                    semanticLabel: l10n.close,
                    size: 44,
                    iconSize: 22,
                    look: ButtonLook.highest,
                    onTap: () => unawaited(close()),
                  ),
                ],
              ),
            ),
          ),
          stagger(
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: ActionTile(
                    icon: HIcons.iosShare,
                    label: l10n.share,
                    loud: true,
                    onTap: onPage ? () => run(actions.share) : null,
                  ),
                ),
                Expanded(
                  child: ActionTile(
                    icon: HIcons.bookmarkAdd,
                    label: saved ? l10n.saved : l10n.saveBookmark,
                    active: saved,
                    onTap: onPage
                        ? () => run(() => actions.toggleBookmark(context))
                        : null,
                  ),
                ),
                Expanded(
                  child: ActionTile(
                    icon: HIcons.eyeglasses,
                    label: l10n.addToReadingList,
                    active: reading,
                    onTap: onPage && !reading
                        ? () => run(() => actions.addToReadingList(context))
                        : null,
                  ),
                ),
                Expanded(
                  child: ActionTile(
                    icon: HIcons.findInPage,
                    label: l10n.findInPage,
                    onTap: onPage
                        ? () => unawaited(close(MenuDestination.find))
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          stagger(ListGroup(rows: rows)),
          const SizedBox(height: 12),
          stagger(
            Column(
              spacing: 4,
              children: [
                for (var r = 0; r < 3; r++)
                  Row(
                    spacing: 4,
                    children: [
                      for (var c = 0; c < 2; c++)
                        Expanded(
                          child: GridButton(
                            icon: grid[r * 2 + c].$1,
                            label: grid[r * 2 + c].$2,
                            borderRadius: GridButton.cornersFor(r * 2 + c, 6),
                            onTap: () => unawaited(close(grid[r * 2 + c].$3)),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
