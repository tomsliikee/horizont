import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/system_ui.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/color_schemes.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/tiles.dart';
import 'labels.dart';

/// Design & Farbe (`P:579`–`P:634`): mode, colourways with Material You
/// first (D3), the six bar layouts, and the bar switches (D4). Changes apply
/// at once and the theme change animates.
class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final palette = ref.watch(systemPaletteProvider).value;
    final brightness = Theme.of(context).brightness;
    final ways = [
      if (palette != null) Colourway.wallpaper,
      ...Colourway.values.where((w) => w != Colourway.wallpaper),
    ];
    // Without a system palette "Hintergrund" means blue.
    final selectedWay = palette == null && s.colourway == Colourway.wallpaper
        ? Colourway.blue
        : s.colourway;
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
              ScreenHeader(
                title: l10n.designAndColour,
                subtitle: l10n.changesApplyNow,
                backLabel: l10n.back,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(l10n.mode),
                    stagger(
                      SegmentRow(
                        height: 56,
                        labels: [
                          l10n.themeLight,
                          l10n.themeDark,
                          l10n.themeSystem,
                        ],
                        icons: const [
                          HIcons.lightMode,
                          HIcons.darkMode,
                          HIcons.brightnessAuto,
                        ],
                        fill: scheme.surfaceBright,
                        selected: switch (s.themeMode) {
                          ThemeMode.light => 0,
                          ThemeMode.dark => 1,
                          ThemeMode.system => 2,
                        },
                        onSelected: (i) => notifier.update(
                          (s) => s.copyWith(
                            themeMode: [
                              ThemeMode.light,
                              ThemeMode.dark,
                              ThemeMode.system,
                            ][i],
                          ),
                        ),
                      ),
                    ),
                    SectionHeader(l10n.colourway),
                    stagger(
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 20, 4, 16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceBright,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = ways.length;
                            return Row(
                              children: [
                                for (final way in ways)
                                  SizedBox(
                                    width: constraints.maxWidth / columns,
                                    child: () {
                                      final c = colorSchemeFor(
                                        way,
                                        brightness,
                                        palette: palette,
                                      );
                                      return ColorwaySwatch(
                                        primary: c.primary,
                                        container: c.primaryContainer,
                                        tertiary: c.tertiaryContainer,
                                        label: colourwayLabel(l10n, way),
                                        selected: way == selectedWay,
                                        onTap: () => notifier.update(
                                          (s) => s.copyWith(colourway: way),
                                        ),
                                      );
                                    }(),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SectionHeader(l10n.barLayout),
                    stagger(
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.72,
                        children: [
                          for (final layout in BarLayout.values)
                            LayoutPreview(
                              boxes: layoutBoxes(layout),
                              label: layoutLabel(l10n, layout),
                              selected: s.barLayout == layout,
                              onTap: () => notifier.update(
                                (s) => s.copyWith(barLayout: layout),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SectionHeader(l10n.bar),
                    stagger(
                      ListGroup(
                        rows: [
                          ListRow(
                            title: l10n.tintFromPage,
                            subtitle: l10n.tintFromPageSub,
                            minHeight: 72,
                            trailing: HorizontSwitch(
                              value: s.tintFromPage,
                              semanticLabel: l10n.tintFromPage,
                              onChanged: (v) => notifier.update(
                                (s) => s.copyWith(tintFromPage: v),
                              ),
                            ),
                          ),
                          ListRow(
                            title: l10n.shrinkOnScroll,
                            subtitle: l10n.shrinkOnScrollSub,
                            minHeight: 72,
                            trailing: HorizontSwitch(
                              value: s.shrinkOnScroll,
                              semanticLabel: l10n.shrinkOnScroll,
                              onChanged: (v) => notifier.update(
                                (s) => s.copyWith(shrinkOnScroll: v),
                              ),
                            ),
                          ),
                          ListRow(
                            title: l10n.hideAtEnd,
                            subtitle: l10n.hideAtEndSub,
                            minHeight: 72,
                            trailing: HorizontSwitch(
                              value: s.hideBarAtPageEnd,
                              semanticLabel: l10n.hideAtEnd,
                              onChanged: (v) => notifier.update(
                                (s) => s.copyWith(hideBarAtPageEnd: v),
                              ),
                            ),
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
