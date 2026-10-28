import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/motion.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/haptics.dart';
import '../../ui/lists.dart';
import '../../ui/shapes.dart';
import '../../ui/squish.dart';
import '../../ui/tiles.dart';

/// The favourites, four to a row. A long press lifts one and starts
/// arranging: every favourite wiggles, the lifted one follows the finger
/// and the others slide aside. Done ends it; a tap while arranging offers a
/// new tab or removing.
class FavouritesGrid extends ConsumerStatefulWidget {
  const FavouritesGrid({
    super.key,
    required this.favourites,
    required this.onOpen,
    this.onOpenInNewTab,
  });

  static const shown = 8;

  final List<Bookmark> favourites;
  final ValueChanged<Uri> onOpen;
  final ValueChanged<Uri>? onOpenInNewTab;

  @override
  ConsumerState<FavouritesGrid> createState() => _FavouritesGridState();
}

class _FavouritesGridState extends ConsumerState<FavouritesGrid>
    with SingleTickerProviderStateMixin {
  late final _wiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  var _editing = false;
  int? _dragging;
  late List<Bookmark> _order = _visible;

  List<Bookmark> get _visible =>
      widget.favourites.take(FavouritesGrid.shown).toList();

  @override
  void didUpdateWidget(FavouritesGrid old) {
    super.didUpdateWidget(old);
    if (_dragging == null) _order = _visible;
    if (_order.isEmpty) _stop();
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  void _start() {
    if (_editing) return;
    setState(() => _editing = true);
    if (!HorizontMotion.reduced(context)) unawaited(_wiggle.repeat());
  }

  void _stop() {
    if (!_editing) return;
    Haptics.play(Haptic.confirm);
    _wiggle.stop();
    setState(() => _editing = false);
  }

  void _hover(int over) {
    final from = _order.indexWhere((b) => b.id == _dragging);
    if (from < 0 || from == over) return;
    Haptics.play(Haptic.tick);
    setState(() {
      final moving = _order.removeAt(from);
      _order.insert(over, moving);
    });
  }

  Future<void> _drop() async {
    final id = _dragging;
    setState(() => _dragging = null);
    if (id == null) return;
    final to = _order.indexWhere((b) => b.id == id);
    final from = _visible.indexWhere((b) => b.id == id);
    if (to != from) await ref.read(libraryProvider).moveBookmark(id, to);
  }

  Future<void> _actions(Bookmark b) async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DragHandle(),
              ListGroup(
                rows: [
                  if (widget.onOpenInNewTab != null)
                    ListRow(
                      leading: const IconWell(icon: HIcons.add),
                      title: l10n.newTab,
                      minHeight: 56,
                      onTap: () => Navigator.of(context).pop('tab'),
                    ),
                  ListRow(
                    leading: const IconWell(icon: HIcons.deleteIcon),
                    title: l10n.remove,
                    minHeight: 56,
                    onTap: () => Navigator.of(context).pop('remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'tab') widget.onOpenInNewTab?.call(b.url);
    if (action == 'remove') {
      await ref.read(libraryProvider).removeBookmark(b.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SectionHeader(
                _editing ? l10n.editFavourites : l10n.favourites,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _editing
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: QuickChip(
                        icon: HIcons.check,
                        label: l10n.done,
                        selected: true,
                        onTap: _stop,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 4;
            const rowGap = 16.0;
            final cellW = constraints.maxWidth / columns;
            final cellH = cellW / 0.92;
            final rows = (_order.length / columns).ceil();
            return SizedBox(
              height: rows * cellH + math.max(0, rows - 1) * rowGap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, b) in _order.indexed)
                    AnimatedPositioned(
                      key: ValueKey(b.id),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      left: (i % columns) * cellW,
                      top: (i ~/ columns) * (cellH + rowGap),
                      width: cellW,
                      height: cellH,
                      child: _slot(i, b, Size(cellW, cellH)),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _slot(int i, Bookmark b, Size size) {
    final l10n = AppLocalizations.of(context);
    // Each favourite's own colour and shape follow the bookmark, not the slot,
    // so they travel with it.
    final index = widget.favourites.indexWhere((f) => f.id == b.id);
    final tile = _FavouriteTile(
      bookmark: b,
      index: index < 0 ? i : index,
      editing: _editing,
      wiggle: _wiggle,
      onTap: _editing
          ? () => unawaited(_actions(b))
          : () => widget.onOpen(b.url),
    );
    final feedback = Material(
      type: MaterialType.transparency,
      child: SizedBox.fromSize(
        size: size,
        child: Transform.scale(scale: 1.12, child: tile),
      ),
    );
    final hidden = Opacity(opacity: 0, child: tile);
    void started() {
      Haptics.play(Haptic.dragStart);
      _start();
      setState(() => _dragging = b.id);
    }

    // One kind of draggable throughout: swapping it when arranging starts
    // would end the drag that started it before the drop is saved.
    final draggable = LongPressDraggable<int>(
      data: b.id,
      // While arranging, a short hold is enough to lift one.
      delay: _editing ? const Duration(milliseconds: 150) : kLongPressTimeout,
      feedback: feedback,
      childWhenDragging: hidden,
      hapticFeedbackOnStart: false,
      onDragStarted: started,
      onDragEnd: (_) => unawaited(_drop()),
      child: tile,
    );
    return Semantics(
      hint: _editing ? l10n.moveFavouriteHint : null,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          _hover(i);
          return true;
        },
        builder: (context, _, _) => draggable,
      ),
    );
  }
}

/// A favourite: a letter on a shape; it squishes and turns a little on press
/// (PLAN 6.2, Shapes) and wiggles while the favourites are arranged.
class _FavouriteTile extends StatelessWidget {
  const _FavouriteTile({
    required this.bookmark,
    required this.index,
    required this.editing,
    required this.wiggle,
    required this.onTap,
  });

  final Bookmark bookmark;
  final int index;
  final bool editing;
  final Animation<double> wiggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = bookmark.title.isEmpty ? bookmark.url.host : bookmark.title;
    final reduced = HorizontMotion.reduced(context);
    final squish = Squish(
      semanticLabel: title,
      onTap: onTap,
      morph: (context, pressed) => Column(
        spacing: 6,
        children: [
          MaterialShapeBadge(
            shape: materialFavourite(index),
            pressedShape: MaterialShapes.circle,
            pressed: pressed,
            size: 68,
            color: [
              scheme.primaryContainer,
              scheme.tertiaryContainer,
              scheme.secondaryContainer,
              scheme.surfaceBright,
            ][index % 4],
            child: Text(
              title.characters.first.toUpperCase(),
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
    if (!editing) return squish;
    if (reduced) {
      // Without animations an outline says the favourites can be moved.
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: squish,
      );
    }
    // Each favourite has its own phase, so they do not wiggle in step.
    final phase = (index * 0.37) % 1;
    return AnimatedBuilder(
      animation: wiggle,
      builder: (context, child) => Transform.rotate(
        angle: math.sin((wiggle.value + phase) * 2 * math.pi) * 0.035,
        child: child,
      ),
      child: squish,
    );
  }
}
