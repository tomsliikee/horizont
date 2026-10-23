import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/lists.dart';
import '../../ui/shapes.dart';
import '../../ui/squish.dart';
import '../../dev/gallery_page.dart';

/// Fixture data until the library exists (milestone 6): `P:853`–`P:859`.
const _favourites = [
  ('W', 'Wikipedia'),
  ('O', 'ORF'),
  ('Y', 'YouTube'),
  ('G', 'GitHub'),
  ('M', 'Moodle'),
  ('K', 'Karten'),
  ('B', 'Bergzeit'),
  ('C', 'Chefkoch'),
];

const _frequent = [
  ('B', 'Herbst am Schafberg', 'bergzeit.at'),
  ('S', 'Schafbergbahn – Fahrplan', 'schafbergbahn.at'),
  ('W', 'Wetter Salzburg – 7 Tage', 'geosphere.at'),
];

/// The static start page (`P:60`–`P:128`).
class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.viewPaddingOf(context).top + 16;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMMEEEEd(locale).format(DateTime.now());

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, top, 16, 150),
        children: [
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
                        date,
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
                Squish(
                  semanticLabel: l10n.settings,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GalleryPage(),
                    ),
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.surfaceBright,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SymbolIcon(
                      HIcons.settings,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          HeroCard(
            number: '42',
            label: l10n.privacyReportLabel,
            title: l10n.trackersBlocked,
            strong: l10n.moreThanLastWeek(8),
            aside: l10n.countedOnDevice,
          ),
          SectionHeader(l10n.favourites),
          GridView.count(
            crossAxisCount: 4,
            // A GridView in a ListView would otherwise add the status bar
            // inset as padding.
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 1.03,
            children: [
              for (var i = 0; i < _favourites.length; i++)
                _Favourite(
                  letter: _favourites[i].$1,
                  title: _favourites[i].$2,
                  preset: ShapePreset.favourites[i % 4],
                ),
            ],
          ),
          SectionHeader(l10n.frequentlyVisited),
          ListGroup(
            rows: [
              for (final (letter, title, host) in _frequent)
                ListRow(
                  leading: Monogram(letter),
                  title: title,
                  subtitle: host,
                  trailing: SymbolIcon(
                    HIcons.northWest,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  onTap: () {},
                ),
            ],
          ),
          SectionHeader(l10n.readingList),
          SizedBox(
            height: 196,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _ReadingCard(
                  band: scheme.secondaryContainer,
                  title: 'Herbst am Schafberg',
                  meta: 'bergzeit.at · ${l10n.readMinutes(8)}',
                ),
                const SizedBox(width: 12),
                _ReadingCard(
                  band: scheme.tertiaryContainer,
                  title: 'Was Material 3 Expressive anders macht',
                  meta: 'm3.material.io · ${l10n.readMinutes(12)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Favourite extends StatelessWidget {
  const _Favourite({
    required this.letter,
    required this.title,
    required this.preset,
  });

  final String letter;
  final String title;
  final ShapePreset preset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Squish(
      semanticLabel: title,
      onTap: () {},
      child: Column(
        spacing: 6,
        children: [
          ShapeBadge(
            preset: preset,
            size: 64,
            color: scheme.surfaceBright,
            child: Text(
              letter,
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
    required this.title,
    required this.meta,
  });

  final Color band;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Squish(
      semanticLabel: title,
      pressedScale: 0.97,
      onTap: () {},
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
            Container(height: 96, color: band),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
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
