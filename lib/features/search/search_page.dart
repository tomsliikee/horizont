import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../browser/address.dart';
import '../../browser/search_engines.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/motion.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/lists.dart';
import '../../ui/motion/spring.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/squish.dart';
import '../../ui/tiles.dart';
import 'search_model.dart';

/// Opens the search screen; the field grows out of [origin] (the address
/// pill) and shrinks back into it on cancel (PLAN 6.2). Returns the address
/// to load, or null.
Future<Uri?> showSearchScreen(
  BuildContext context, {
  Rect? origin,
  String initial = '',
  SuggestionFetcher? fetch,
}) {
  return Navigator.of(context).push<Uri>(
    PageRouteBuilder<Uri>(
      opaque: false,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) =>
          SearchPage(origin: origin, initial: initial, fetch: fetch),
    ),
  );
}

/// The search screen (`P:313`–`P:349`): the field at the bottom (at the top
/// for the "oben" layout) above the keyboard, the top hit, suggestions and
/// the quick searches above it.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.origin, this.initial = '', this.fetch});

  final Rect? origin;
  final String initial;
  final SuggestionFetcher? fetch;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  /// The tallest keyboard seen, kept between openings: the results are laid
  /// out for it at once, so they do not move on every frame the keyboard
  /// slides in (only the field follows it).
  static double _keyboardMemory = 0;
  _Results? _results;
  (EdgeInsets, SearchEngine, String, bool)? _resultsKey;

  late final _open = AnimationController.unbounded(vsync: this);
  late final _text = TextEditingController(text: widget.initial)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );
  final _focus = FocusNode();
  late final SearchModel _model;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    final private = ref.read(tabsProvider).privateMode;
    _model = SearchModel(
      library: ref.read(libraryProvider),
      engine: settings.searchEngine,
      remoteAllowed: settings.searchSuggestions && !private,
      now: ref.read(clockProvider),
      fetch: widget.fetch ?? fetchSuggestions,
    );
    _text.addListener(_onText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      unawaited(_open.springTo(1, motion: HorizontMotion.spatialFor(context)));
    });
  }

  String _last = '';
  void _onText() {
    if (_text.text == _last) return;
    _last = _text.text;
    unawaited(_model.update(_text.text));
    setState(() {});
  }

  @override
  void dispose() {
    _open.dispose();
    _text.dispose();
    _focus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _close([Uri? result]) async {
    if (_closing) return;
    _closing = true;
    _focus.unfocus();
    if (result == null) {
      await _open.springTo(0, motion: HorizontMotion.effects);
    }
    if (mounted) Navigator.of(context).pop(result);
  }

  void _go(Uri uri) {
    HapticFeedback.lightImpact();
    unawaited(_close(uri));
  }

  void _submit(String text) {
    final engine = ref.read(settingsProvider).searchEngine;
    final top = _model.value.topHit;
    if (top is AddressSuggestion && _model.value.input == text.trim()) {
      _go(top.address);
      return;
    }
    final uri = resolveAddress(text, engine);
    if (uri != null) _go(uri);
  }

  void _insert(String text) {
    _text.value = TextEditingValue(
      text: '$text ',
      selection: TextSelection.collapsed(offset: text.length + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final settings = ref.watch(settingsProvider);
    final engine = settings.searchEngine;
    final atTop = settings.barLayout == BarLayout.oben;
    final keyboard = media.viewInsets.bottom;
    if (keyboard > _keyboardMemory) _keyboardMemory = keyboard;
    final listKeyboard = math.max(keyboard, _keyboardMemory);
    final width = media.size.width;
    const fieldHeight = 56.0;
    final cancelWidth = _cancelWidth(context, l10n.cancel);
    final target = atTop
        ? Rect.fromLTWH(
            16,
            media.viewPadding.top + 8,
            width - 32 - 8 - cancelWidth,
            fieldHeight,
          )
        : Rect.fromLTWH(
            16,
            media.size.height -
                math.max(keyboard + 12, media.viewPadding.bottom + 28) -
                fieldHeight,
            width - 32 - 8 - cancelWidth,
            fieldHeight,
          );

    // The results are laid out for the settled keyboard and kept as the same
    // widget while nothing about them changes, so the keyboard sliding in does
    // not rebuild or repaint the list.
    final listFieldTop = atTop
        ? target.top
        : media.size.height -
              math.max(listKeyboard + 12, media.viewPadding.bottom + 28) -
              fieldHeight;
    final listPadding = EdgeInsets.fromLTRB(
      16,
      atTop ? target.bottom + 16 : media.viewPadding.top + 16,
      16,
      atTop ? listKeyboard + 24 : media.size.height - listFieldTop + 16,
    );
    final key = (listPadding, engine, _text.text, atTop);
    if (_resultsKey != key || _results == null) {
      _resultsKey = key;
      _results = _Results(
        model: _model,
        engine: engine,
        input: _text.text,
        padding: listPadding,
        onOpen: _go,
        onInsert: _insert,
        reverse: !atTop,
      );
    }
    final results = RepaintBoundary(child: _results);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: AnimatedBuilder(
        animation: _open,
        builder: (context, _) {
          final t = _open.value;
          final shown = t.clamp(0.0, 1.0);
          final from = widget.origin ?? target.translate(0, atTop ? -40 : 40);
          final rect = Rect.lerp(from, target, t)!;
          final contentOpacity = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // A colour with alpha, not an Opacity: no offscreen layer.
                Positioned.fill(
                  child: ColoredBox(
                    color: scheme.surfaceContainer.withValues(
                      alpha: scheme.surfaceContainer.a * shown,
                    ),
                  ),
                ),
                Positioned.fill(child: results),
                Positioned.fromRect(
                  rect: rect,
                  child: _Field(
                    controller: _text,
                    focus: _focus,
                    engine: engine,
                    radius: lerpDouble(
                      rect.height / 2,
                      fieldHeight / 2,
                      shown,
                    )!,
                    contentOpacity: contentOpacity,
                    outline: shown,
                    onSubmit: _submit,
                    clearLabel: l10n.clearInput,
                    hint: ref.watch(tabsProvider.select((s) => s.privateMode))
                        ? l10n.privateSearchOrAddress
                        : l10n.searchOrEnterAddressLong,
                  ),
                ),
                Positioned(
                  right: 16,
                  top: target.top + (fieldHeight - 48) / 2,
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Transform.translate(
                      offset: Offset((1 - shown) * 80, 0),
                      child: PillButton(
                        label: l10n.cancel,
                        look: ButtonLook.highest,
                        onTap: () => unawaited(_close()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static double _cancelWidth(BuildContext context, String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: HorizontType.bodyMedium.copyWith(fontSize: 15),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width + 40;
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focus,
    required this.engine,
    required this.radius,
    required this.contentOpacity,
    required this.outline,
    required this.onSubmit,
    required this.clearLabel,
    required this.hint,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final SearchEngine engine;
  final double radius;
  final double contentOpacity;
  final double outline;
  final ValueChanged<String> onSubmit;
  final String clearLabel;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: scheme.primary.withValues(alpha: outline),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x29000000),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Opacity(
        opacity: contentOpacity,
        child: Row(
          children: [
            const SizedBox(width: 6),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  SymbolIcon(
                    HIcons.search,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                  Text(
                    engine.label,
                    style: HorizontType.bodyStrong.copyWith(
                      fontSize: 13,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focus,
                // Plain text keyboard so the keyboard offers word suggestions;
                // the URL keyboard hides them. The field takes searches too.
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                autocorrect: true,
                enableSuggestions: true,
                onSubmitted: onSubmit,
                cursorColor: scheme.primary,
                style: HorizontType.subtitle
                    .withWeight(500)
                    .copyWith(color: scheme.onSurface),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintMaxLines: 1,
                  hintStyle: HorizontType.subtitle.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => controller.text.isEmpty
                  ? const SizedBox(width: 12)
                  : RoundButton(
                      icon: HIcons.cancel,
                      semanticLabel: clearLabel,
                      size: 44,
                      iconSize: 20,
                      look: ButtonLook.plain,
                      onTap: controller.clear,
                    ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.model,
    required this.engine,
    required this.input,
    required this.padding,
    required this.onOpen,
    required this.onInsert,
    required this.reverse,
  });

  final SearchModel model;
  final SearchEngine engine;
  final String input;
  final EdgeInsets padding;
  final ValueChanged<Uri> onOpen;
  final ValueChanged<String> onInsert;

  /// The list grows up from the field at the bottom.
  final bool reverse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<SearchResults>(
      valueListenable: model,
      builder: (context, results, _) {
        final children = <Widget>[];
        var i = 0;
        Widget stagger(Widget child) =>
            StaggeredEntrance(key: ValueKey('s$i'), index: i++, child: child);

        if (results.input.isEmpty) {
          final frequent = ref.watch(frequentProvider).value ?? const [];
          if (frequent.isNotEmpty) {
            children
              ..add(_Label(l10n.frequentlyVisited))
              ..add(
                stagger(
                  ListGroup(
                    rows: [
                      for (final p in frequent)
                        _historyRow(context, l10n, p, onOpen),
                    ],
                  ),
                ),
              );
          }
        } else {
          final top = results.topHit;
          if (top != null) {
            children
              ..add(_Label(l10n.topHit))
              ..add(
                stagger(
                  _TopHit(suggestion: top, engine: engine, onOpen: onOpen),
                ),
              );
          }
          if (results.local.isNotEmpty) {
            children
              ..add(_Label(l10n.fromYourLibrary, gap: true))
              ..add(
                stagger(
                  ListGroup(
                    rows: [
                      for (final s in results.local)
                        _localRow(context, l10n, s, engine, onOpen),
                    ],
                  ),
                ),
              );
          }
          if (results.remote.isNotEmpty) {
            children
              ..add(_Label(l10n.suggestionsFrom(engine.label), gap: true))
              ..add(
                stagger(
                  ListGroup(
                    rows: [
                      for (final s in results.remote)
                        ListRow(
                          leading: _icon(context, HIcons.search),
                          title: s.query,
                          subtitle: l10n.suggestionSearch,
                          minHeight: 56,
                          onTap: () => onOpen(s.uri(engine)),
                          trailing: Squish(
                            semanticLabel: l10n.insertSuggestion,
                            onTap: () => onInsert(s.query),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _icon(context, HIcons.northWest, 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
          }
        }
        children
          ..add(_Label(l10n.quickSearch, gap: children.isNotEmpty))
          ..add(
            stagger(
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (kind, icon, label) in [
                    (QuickSearch.images, HIcons.image, l10n.quickImages),
                    (QuickSearch.maps, HIcons.map, l10n.quickMaps),
                    (QuickSearch.news, HIcons.newspaper, l10n.quickNews),
                    (
                      QuickSearch.weather,
                      HIcons.partlyCloudyDay,
                      l10n.quickWeather,
                    ),
                  ])
                    QuickChip(
                      icon: icon,
                      label: label,
                      selected: kind == QuickSearch.images && input.isNotEmpty,
                      onTap: () => onOpen(
                        engine.quickUri(
                          kind,
                          input,
                          weatherWord: l10n.weatherWord,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        return ListView(
          reverse: reverse,
          padding: padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ],
        );
      },
    );
  }

  static Widget _icon(
    BuildContext context,
    IconData icon, [
    double size = 22,
  ]) => SymbolIcon(
    icon,
    size: size,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static String _host(Uri url) =>
      url.host.startsWith('www.') ? url.host.substring(4) : url.host;

  static ListRow _historyRow(
    BuildContext context,
    AppLocalizations l10n,
    HistoryPage p,
    ValueChanged<Uri> onOpen,
  ) => ListRow(
    leading: _icon(context, HIcons.history),
    title: p.title.isEmpty ? _host(p.url) : p.title,
    subtitle: l10n.suggestionVisited(_host(p.url), p.visitCount),
    minHeight: 56,
    onTap: () => onOpen(p.url),
  );

  static ListRow _localRow(
    BuildContext context,
    AppLocalizations l10n,
    SearchSuggestion s,
    SearchEngine engine,
    ValueChanged<Uri> onOpen,
  ) {
    final locale = Localizations.localeOf(context).toString();
    return switch (s) {
      HistorySuggestion(:final page) => ListRow(
        leading: _icon(context, HIcons.history),
        title: page.title.isEmpty ? _host(page.url) : page.title,
        subtitle: l10n.suggestionHistory(_when(page.lastVisitAt, l10n, locale)),
        minHeight: 56,
        onTap: () => onOpen(page.url),
      ),
      BookmarkSuggestion(:final bookmark, :final folder) => ListRow(
        leading: _icon(context, HIcons.bookmark),
        title: bookmark.title.isEmpty ? _host(bookmark.url) : bookmark.title,
        subtitle: l10n.suggestionBookmark(folder),
        minHeight: 56,
        onTap: () => onOpen(bookmark.url),
      ),
      ReadingSuggestion(:final item) => ListRow(
        leading: _icon(context, HIcons.eyeglasses),
        title: item.title,
        subtitle: l10n.suggestionReading(item.host),
        minHeight: 56,
        onTap: () => onOpen(item.url),
      ),
      _ => ListRow(
        title: s.uri(engine).toString(),
        onTap: () => onOpen(s.uri(engine)),
      ),
    };
  }

  static String _when(DateTime at, AppLocalizations l10n, String locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return l10n.today;
    if (day == today.subtract(const Duration(days: 1))) return l10n.yesterday;
    return DateFormat.MMMd(locale).format(at);
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.gap = false});

  final String text;
  final bool gap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(4, gap ? 20 : 0, 4, 8),
    child: Text(
      text,
      style: HorizontType.label.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

/// The top hit (`P:316`): a `primaryContainer` card, radius 28.
class _TopHit extends StatelessWidget {
  const _TopHit({
    required this.suggestion,
    required this.engine,
    required this.onOpen,
  });

  final SearchSuggestion suggestion;
  final SearchEngine engine;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final uri = suggestion.uri(engine);
    final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    final (title, subtitle) = switch (suggestion) {
      AddressSuggestion() => (host, l10n.openAddress(uri.toString())),
      HistorySuggestion(:final page) => (
        page.title.isEmpty ? host : page.title,
        l10n.suggestionVisited(host, page.visitCount),
      ),
      BookmarkSuggestion(:final bookmark, :final folder) => (
        bookmark.title.isEmpty ? host : bookmark.title,
        '$host · ${l10n.suggestionBookmark(folder)}',
      ),
      ReadingSuggestion(:final item) => (
        item.title,
        l10n.suggestionReading(item.host),
      ),
      QuerySuggestion(:final query) => (query, l10n.suggestionSearch),
    };
    final letter = title.isEmpty ? '·' : title.characters.first.toUpperCase();
    return Squish(
      onTap: () => onOpen(uri),
      semanticLabel: title,
      pressedScale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                letter,
                style: HorizontType.monogramLarge.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
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
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HorizontType.caption.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            SymbolIcon(
              HIcons.arrowOutward,
              size: 22,
              color: scheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
