import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/system_ui.dart';
import '../../browser/search_engines.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extensions.dart';
import '../../ui/cards.dart';
import '../../ui/controls.dart';
import '../../ui/lists.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/tiles.dart';
import 'labels.dart';

/// Suchmaschine (`P:637`–`P:665`), without "Top-Treffer vorladen" (D14).
class EnginePage extends ConsumerWidget {
  const EnginePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final radii = HorizontRadii.of(context);
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    const engines = SearchEngine.values;
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
                title: l10n.searchEngine,
                subtitle: l10n.engineSub,
                backLabel: l10n.back,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      spacing: 4,
                      children: [
                        for (var i = 0; i < engines.length; i++)
                          StaggeredEntrance(
                            index: i,
                            child: RadioRow(
                              letter: engines[i].letter,
                              title: engines[i].label,
                              subtitle: engineSubtitle(l10n, engines[i]),
                              selected: s.searchEngine == engines[i],
                              borderRadius: radii.groupItem(i, engines.length),
                              onTap: () => notifier.update(
                                (s) => s.copyWith(searchEngine: engines[i]),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SectionHeader(l10n.suggestions),
                    ListGroup(
                      rows: [
                        ListRow(
                          title: l10n.searchSuggestions,
                          subtitle: l10n.searchSuggestionsSub(
                            s.searchEngine.label,
                          ),
                          minHeight: 72,
                          trailing: HorizontSwitch(
                            value: s.searchSuggestions,
                            semanticLabel: l10n.searchSuggestions,
                            onChanged: (v) => notifier.update(
                              (s) => s.copyWith(searchSuggestions: v),
                            ),
                          ),
                        ),
                      ],
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
