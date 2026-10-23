import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../app/providers.dart';
import '../l10n/app_localizations.dart';
import '../theme/color_schemes.dart';
import '../ui/buttons.dart';
import '../ui/cards.dart';
import '../ui/controls.dart';
import '../ui/lists.dart';
import '../ui/shapes.dart';

/// Every shared widget in one scroll, with the theme controls. A development
/// page; the real settings screens arrive in milestone 8.
class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  bool _switchOn = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final ways = Colourway.values;
    final hasPalette = ref.watch(systemPaletteProvider).value != null;
    final visibleWays = [
      for (final w in ways)
        if (w != Colourway.wallpaper || hasPalette) w,
    ];
    String wayName(Colourway w) => switch (w) {
      Colourway.wallpaper => l10n.colourwayWallpaper,
      Colourway.blue => l10n.colourwayBlue,
      Colourway.violet => l10n.colourwayViolet,
      Colourway.green => l10n.colourwayGreen,
      Colourway.orange => l10n.colourwayOrange,
      Colourway.pink => l10n.colourwayPink,
    };

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
        children: [
          ScreenHeader(
            title: 'Gallery',
            subtitle: 'Every shared widget',
            backLabel: l10n.back,
          ),
          const SectionHeader('Mode'),
          SegmentRow(
            labels: [l10n.themeLight, l10n.themeDark, l10n.themeSystem],
            selected: modes.indexOf(settings.themeMode),
            height: 56,
            onSelected: (i) =>
                notifier.update((s) => s.copyWith(themeMode: modes[i])),
          ),
          const SectionHeader('Colourway'),
          SegmentRow(
            labels: [for (final w in visibleWays) wayName(w)],
            selected: visibleWays.indexOf(settings.colourway).clamp(0, 99),
            onSelected: (i) =>
                notifier.update((s) => s.copyWith(colourway: visibleWays[i])),
          ),
          const SectionHeader('Buttons'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RoundButton(
                icon: HIcons.search,
                semanticLabel: 'Search',
                look: ButtonLook.glass,
              ),
              RoundButton(
                icon: HIcons.menu,
                semanticLabel: 'Menu',
                look: ButtonLook.highest,
                onTap: () {},
              ),
              RoundButton(
                icon: HIcons.add,
                semanticLabel: 'Add',
                look: ButtonLook.primary,
                size: 56,
                onTap: () {},
              ),
              PillButton(
                icon: HIcons.download,
                label: 'Download',
                onTap: () {},
              ),
              PillButton(
                label: 'Primary',
                look: ButtonLook.primary,
                onTap: () {},
              ),
              PillButton(
                label: 'Delete',
                look: ButtonLook.errorContainer,
                onTap: () {},
              ),
            ],
          ),
          const SectionHeader('List group'),
          ListGroup(
            rows: [
              ListRow(
                leading: const IconWell(icon: HIcons.shield),
                title: 'Block trackers',
                subtitle: 'Across sites',
                trailing: HorizontSwitch(
                  value: _switchOn,
                  semanticLabel: 'Block trackers',
                  onChanged: (v) => setState(() => _switchOn = v),
                ),
              ),
              const ListRow(
                leading: IconWell(icon: HIcons.bookmark),
                title: 'Bookmarks',
                subtitle: 'Eight folders',
                trailing: SymbolIcon(HIcons.chevronRight, size: 20),
              ),
              const ListRow(leading: Monogram('W'), title: 'Wikipedia'),
            ],
          ),
          const SectionHeader('Shapes'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in ShapePreset.values)
                ShapeBadge(
                  preset: p,
                  size: 72,
                  color: scheme.primaryContainer,
                  child: Text(
                    p.lobes.toString(),
                    style: TextStyle(color: scheme.onPrimaryContainer),
                  ),
                ),
            ],
          ),
          const SectionHeader('Hero card'),
          HeroCard(
            number: '42',
            label: l10n.privacyReportLabel,
            title: l10n.trackersBlocked,
            strong: l10n.moreThanLastWeek(8),
            aside: l10n.countedOnDevice,
          ),
        ],
      ),
    );
  }
}
