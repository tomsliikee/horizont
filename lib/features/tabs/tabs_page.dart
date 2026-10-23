import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../app/system_ui.dart';
import '../../browser/tabs/tab_session.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../browser/tabs/thumbnail_store.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extensions.dart';
import '../../theme/motion.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/floating_surface.dart';
import '../../ui/motion/flip.dart';
import '../../ui/motion/spring.dart';
import '../../ui/tab_card.dart';

/// Opens the tab overview above the browser. The picture of the page in front
/// is taken first, so the zoom starts from what is on screen (waits at most a
/// moment).
Future<void> showTabsPage(BuildContext context, WidgetRef ref) async {
  await ref.read(tabSessionProvider).captureActive();
  if (!context.mounted) return;
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, _, _) =>
          const Material(type: MaterialType.transparency, child: TabsPage()),
    ),
  );
}

/// The tab overview (`P:352`–`P:385`). The page zooms out into its card
/// while the other cards rise around it; a tapped card zooms back to full
/// screen (PLAN 6.2). The live web view is never animated: a picture of it
/// flies instead (7.2).
class TabsPage extends ConsumerStatefulWidget {
  const TabsPage({super.key});

  @override
  ConsumerState<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends ConsumerState<TabsPage>
    with SingleTickerProviderStateMixin {
  /// 0: the page fills the screen; 1: it sits in its card.
  late final _zoom = AnimationController.unbounded(vsync: this);
  final _cardKeys = <String, GlobalKey>{};
  final _scroll = ScrollController();
  String? _flying;
  var _leaving = false;
  String? _appearing;

  GlobalKey _keyFor(String id) => _cardKeys.putIfAbsent(id, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _flying = ref.read(tabsProvider).activeId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _scrollToActive();
      await _zoom.springTo(
        1,
        motion: HorizontMotion.spatialFor(context, HorizontMotion.spatial),
      );
      if (mounted) setState(() => _flying = null);
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToActive() {
    final state = ref.read(tabsProvider);
    final index = state.visible.indexWhere((t) => t.id == state.activeId);
    if (index < 0 || !_scroll.hasClients) return;
    final row = index ~/ 2;
    final target = math.max(0.0, row * 268.0 - 120);
    _scroll.jumpTo(math.min(target, _scroll.position.maxScrollExtent));
  }

  /// Zooms [id] to full screen and leaves the overview with it in front.
  Future<void> _openTab(String id) async {
    if (_leaving) return;
    _leaving = true;
    HapticFeedback.lightImpact();
    setState(() => _flying = id);
    final reduced = HorizontMotion.reduced(context);
    await _zoom.springTo(
      0,
      motion: reduced ? HorizontMotion.effects : HorizontMotion.spatialFast,
    );
    if (!mounted) return;
    ref.read(tabsProvider.notifier).activate(id);
    Navigator.of(context).pop();
  }

  Future<void> _newTab() async {
    if (_leaving) return;
    final tab = ref.read(tabsProvider.notifier).open(activate: false);
    setState(() => _appearing = tab.id);
    HapticFeedback.mediumImpact();
    // The new card pops out first, then it opens.
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    await _openTab(tab.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(tabsProvider);
    final notifier = ref.read(tabsProvider.notifier);
    final media = MediaQuery.of(context);
    final cardWidth = (media.size.width - 32 - 12) / 2;
    final cacheWidth = (cardWidth * media.devicePixelRatio).round();
    final visible = state.visible;
    final group = state.active.groupName;
    final private = state.privateMode;

    final subtitle = private
        ? l10n.privateTabsCount(visible.length)
        : group == null
        ? l10n.tabsOpen(visible.length)
        : l10n.tabsOpenInGroup(visible.length, group);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_openTab(ref.read(tabsProvider).activeId));
      },
      child: SystemUiRegion(
        brightness: private ? Brightness.dark : null,
        child: AnimatedBuilder(
          animation: _zoom,
          builder: (context, _) {
            final t = _zoom.value;
            final shown = t.clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: shown,
                    child: ColoredBox(
                      color: private
                          ? HorizontColors.of(context).privateBackground
                          : scheme.surfaceContainer,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: ((t - 0.15) / 0.85).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: lerpDouble(1.06, 1, shown),
                      child: CustomScrollView(
                        controller: _scroll,
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
                                    private ? l10n.privateMode : l10n.tabs,
                                    style: HorizontType.display.copyWith(
                                      color: private
                                          ? const Color(0xFFFFFFFF)
                                          : scheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    subtitle,
                                    style: HorizontType.subtitle.copyWith(
                                      color: private
                                          ? HorizontColors.of(context)
                                                .privateOnSurfaceVariant
                                          : scheme.onSurfaceVariant,
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
                              itemCount: visible.length,
                              itemBuilder: (context, i) {
                                final tab = visible[i];
                                final title = tab.displayTitle(l10n.startPage);
                                return FlipSlot(
                                  key: ValueKey(tab.id),
                                  appear: tab.id == _appearing,
                                  child: _FlingCard(
                                    onClosed: () {
                                      notifier.close(tab.id);
                                      if (ref
                                              .read(tabsProvider)
                                              .visible
                                              .isEmpty &&
                                          private) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Opacity(
                                      opacity: _flying == tab.id ? 0 : 1,
                                      child: Semantics(
                                        label: l10n.tabPosition(
                                          title,
                                          i + 1,
                                          visible.length,
                                        ),
                                        selected: tab.id == state.activeId,
                                        child: TabCard(
                                          key: _keyFor(tab.id),
                                          title: title,
                                          letter: _letter(title),
                                          closeLabel: l10n.closeTab,
                                          active: tab.id == state.activeId,
                                          pageColor: tab.pageColor,
                                          thumbnail: tab.thumbnailPath == null
                                              ? null
                                              : thumbnailImage(
                                                  tab.thumbnailPath!,
                                                  cacheWidth: cacheWidth,
                                                ),
                                          onTap: () =>
                                              unawaited(_openTab(tab.id)),
                                          onClose: () {
                                            HapticFeedback.lightImpact();
                                            notifier.close(tab.id);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_flying != null) _flight(context, state, t),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 28 + math.max(0, media.viewPadding.bottom - 24),
                  child: Opacity(
                    opacity: shown,
                    child: Transform.translate(
                      offset: Offset(0, (1 - shown) * 40),
                      child: Row(
                        spacing: 8,
                        children: [
                          RoundButton(
                            icon: HIcons.add,
                            semanticLabel: l10n.newTab,
                            size: 56,
                            iconSize: 26,
                            onTap: () => unawaited(_newTab()),
                          ),
                          Expanded(
                            child: _ModePill(
                              privateLabel: l10n.privateMode,
                              tabsLabel: l10n.tabsCount(
                                state.normalTabs.length,
                              ),
                              private: private,
                              onPrivate: () {
                                if (private) return;
                                HapticFeedback.selectionClick();
                                notifier.enterPrivate();
                                // A new private tab has nothing to show yet.
                                if (ref.read(tabsProvider).active.url == null) {
                                  unawaited(
                                    _openTab(ref.read(tabsProvider).activeId),
                                  );
                                }
                              },
                              onNormal: () {
                                if (!private) return;
                                HapticFeedback.selectionClick();
                                notifier.showNormal();
                              },
                            ),
                          ),
                          PillButton(
                            label: l10n.done,
                            height: 56,
                            look: ButtonLook.glass,
                            onTap: () => unawaited(_openTab(state.activeId)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The picture that flies between full screen and the card.
  Widget _flight(BuildContext context, TabsState state, double t) {
    final id = _flying!;
    final tab = state.byId(id);
    final media = MediaQuery.of(context);
    final full = Rect.fromLTWH(
      0,
      media.viewPadding.top,
      media.size.width,
      media.size.height - media.viewPadding.top,
    );
    final card = _cardRect(id) ?? full.deflate(full.width * 0.25);
    final rect = Rect.lerp(full, card, t)!;
    final radius = lerpDouble(0, 24, t.clamp(0.0, 1.0))!;
    final scheme = Theme.of(context).colorScheme;
    final path = tab?.thumbnailPath;
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius),
            bottom: Radius.circular(lerpDouble(0, 8, t.clamp(0.0, 1.0))!),
          ),
          child: path != null && tab?.url != null
              ? Image(
                  image: thumbnailImage(path),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  gaplessPlayback: true,
                )
              : ColoredBox(
                  color: tab?.isPrivate ?? false
                      ? HorizontColors.of(context).privateBackground
                      : scheme.surfaceContainer,
                ),
        ),
      ),
    );
  }

  /// The preview part of the card of [id], globally.
  Rect? _cardRect(String id) {
    final box = _cardKeys[id]?.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & Size(box.size.width, TabCard.previewHeight);
  }

  /// The first letter of the title, for the monogram.
  static String _letter(String title) {
    final runes = title.trim().runes;
    return runes.isEmpty ? '·' : String.fromCharCode(runes.first).toUpperCase();
  }
}

/// A card that is flicked sideways to close: it follows the finger, turns a
/// little, and flies off with the finger's speed; short of the threshold it
/// springs back (PLAN 6.2, Close a tab).
class _FlingCard extends StatefulWidget {
  const _FlingCard({required this.child, required this.onClosed});

  final Widget child;
  final VoidCallback onClosed;

  @override
  State<_FlingCard> createState() => _FlingCardState();
}

class _FlingCardState extends State<_FlingCard>
    with SingleTickerProviderStateMixin {
  late final _dx = AnimationController.unbounded(vsync: this);
  var _past = false;

  @override
  void dispose() {
    _dx.dispose();
    super.dispose();
  }

  /// The card's width, from the last layout.
  double _width = 180;

  void _update(DragUpdateDetails d) {
    _dx.value += d.delta.dx;
    final past = _dx.value.abs() > _width * 0.45;
    if (past != _past) {
      _past = past;
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _end(DragEndDetails d) async {
    final v = d.velocity.pixelsPerSecond.dx;
    final fling = v.abs() > 800 && v.sign == _dx.value.sign;
    if (_past || fling) {
      final target =
          (_dx.value.sign == 0 ? v.sign : _dx.value.sign) * _width * 2.2;
      await _dx.springTo(
        target,
        motion: HorizontMotion.spatialFast,
        velocity: v,
      );
      if (mounted) widget.onClosed();
    } else {
      await _dx.springTo(0, motion: HorizontMotion.spatial, velocity: v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth.isFinite ? constraints.maxWidth : 180;
        return _gesture();
      },
    );
  }

  Widget _gesture() {
    return GestureDetector(
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: (d) => unawaited(_end(d)),
      child: AnimatedBuilder(
        animation: _dx,
        child: widget.child,
        builder: (context, child) {
          final f = (_dx.value / _width).clamp(-2.5, 2.5);
          return Transform.translate(
            offset: Offset(_dx.value, 0),
            child: Transform.rotate(
              angle: f * 0.12,
              child: Opacity(
                opacity: (1 - f.abs() * 0.5).clamp(0.0, 1.0),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The glass pill with "Privat" and "n Tabs"; the selected side is the
/// `primary` pill, which slides when the mode changes.
class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.privateLabel,
    required this.tabsLabel,
    required this.private,
    required this.onPrivate,
    required this.onNormal,
  });

  final String privateLabel;
  final String tabsLabel;
  final bool private;
  final VoidCallback onPrivate;
  final VoidCallback onNormal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingSurface(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 48,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final privateWidth = w * 10 / 23;
              return SingleMotionBuilder(
                value: private ? 0 : 1,
                motion: HorizontMotion.spatialFor(
                  context,
                  HorizontMotion.spatialFast,
                ),
                builder: (context, raw, _) {
                  final t = raw.clamp(-0.1, 1.1);
                  final left = lerpDouble(0, privateWidth + 4, t)!;
                  final width = lerpDouble(
                    privateWidth,
                    w - privateWidth - 4,
                    t,
                  )!;
                  return Stack(
                    children: [
                      Positioned(
                        left: left,
                        width: width,
                        top: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          Expanded(
                            flex: 10,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onPrivate,
                              child: Semantics(
                                button: true,
                                selected: private,
                                child: Center(
                                  child: Text(
                                    privateLabel,
                                    style: HorizontType.navLabel(1 - t)
                                        .copyWith(
                                          color: Color.lerp(
                                            scheme.onPrimary,
                                            scheme.onSurfaceVariant,
                                            t.clamp(0, 1),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 13,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onNormal,
                              child: Semantics(
                                button: true,
                                selected: !private,
                                child: Center(
                                  child: Text(
                                    tabsLabel,
                                    style: HorizontType.navLabel(t).copyWith(
                                      color: Color.lerp(
                                        scheme.onSurfaceVariant,
                                        scheme.onPrimary,
                                        t.clamp(0, 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
