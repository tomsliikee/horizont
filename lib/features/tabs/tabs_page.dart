import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/system_ui.dart';
import '../../browser/tabs/tab_session.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/floating_surface.dart';
import '../../ui/tab_card.dart';

/// Opens the tab overview above the browser. The picture of the page in front
/// is taken first, so its card is current (waits at most a moment).
Future<void> showTabsPage(BuildContext context, WidgetRef ref) async {
  await ref.read(tabSessionProvider).captureActive();
  if (!context.mounted) return;
  await Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (context) => const TabsPage()));
}

/// The tab overview (`P:352`–`P:385`).
class TabsPage extends ConsumerWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(tabsProvider);
    final notifier = ref.read(tabsProvider.notifier);
    final media = MediaQuery.of(context);
    final cardWidth = (media.size.width - 32 - 12) / 2;
    final group = state.active.groupName;

    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    media.viewPadding.top + 12,
                    20,
                    16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tabs,
                          style: HorizontType.display.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          group == null
                              ? l10n.tabsOpen(state.tabs.length)
                              : l10n.tabsOpenInGroup(state.tabs.length, group),
                          style: HorizontType.subtitle.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          // Preview 200, gap 4, title strip 52.
                          mainAxisExtent: 256,
                        ),
                    itemCount: state.tabs.length,
                    itemBuilder: (context, i) {
                      final tab = state.tabs[i];
                      final title = tab.displayTitle(l10n.startPage);
                      return TabCard(
                        key: ValueKey(tab.id),
                        title: title,
                        letter: _letter(title),
                        closeLabel: l10n.closeTab,
                        active: tab.id == state.activeId,
                        pageColor: tab.pageColor,
                        thumbnailPath: tab.thumbnailPath,
                        previewCacheWidth: (cardWidth * media.devicePixelRatio)
                            .round(),
                        onTap: () {
                          notifier.activate(tab.id);
                          Navigator.of(context).pop();
                        },
                        onClose: () => notifier.close(tab.id),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 28,
              child: Row(
                spacing: 8,
                children: [
                  RoundButton(
                    icon: HIcons.add,
                    semanticLabel: l10n.newTab,
                    size: 56,
                    iconSize: 26,
                    onTap: () {
                      notifier.open();
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: _ModePill(
                      privateLabel: l10n.privateMode,
                      tabsLabel: l10n.tabsCount(state.tabs.length),
                    ),
                  ),
                  PillButton(
                    label: l10n.done,
                    height: 56,
                    look: ButtonLook.glass,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The first letter of the title, for the monogram.
  static String _letter(String title) {
    final runes = title.trim().runes;
    return runes.isEmpty ? '·' : String.fromCharCode(runes.first).toUpperCase();
  }
}

/// The glass pill with "Privat" and "n Tabs"; the private mode comes with
/// milestone 7, so that side does nothing yet.
class _ModePill extends StatelessWidget {
  const _ModePill({required this.privateLabel, required this.tabsLabel});

  final String privateLabel;
  final String tabsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingSurface(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          spacing: 4,
          children: [
            Expanded(
              flex: 10,
              child: Opacity(
                opacity: 0.38,
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      privateLabel,
                      style: HorizontType.navLabel(0)
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 13,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  tabsLabel,
                  style: HorizontType.navLabel(1)
                      .copyWith(color: scheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
