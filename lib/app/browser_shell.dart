import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../browser/bars/bar_actions.dart';
import '../browser/bars/browser_bars.dart';
import '../browser/browser_providers.dart';
import '../browser/error_page.dart';
import '../browser/find_in_page.dart';
import '../browser/status_bar/status_bar_look.dart';
import '../browser/status_bar/status_bar_provider.dart';
import '../browser/status_bar/status_bar_tint.dart';
import '../browser/tabs/tab_session.dart';
import '../browser/tabs/tabs_notifier.dart';
import '../browser/tabs/thumbnail_store.dart';
import '../features/downloads/downloads_page.dart';
import '../features/library/library_page.dart';
import '../features/menu/menu_sheet.dart';
import '../features/private/private_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/settings_page.dart';
import '../features/start/start_page.dart';
import '../features/tabs/tabs_page.dart';
import '../platform/biometric_lock.dart';
import '../platform/horizont_webkit.dart';
import '../theme/extensions.dart';
import '../theme/horizont_theme.dart';
import '../theme/motion.dart';
import '../ui/motion/spring.dart';
import 'engine_requests.dart';
import 'page_actions.dart';
import 'providers.dart';
import 'routes.dart';
import 'system_ui.dart';

/// The root of the browser: the page at the bottom of a `Stack`, the start
/// page (or the private page) over it while the tab is empty, an error page
/// where loading failed, and the bars floating above all of them. The page
/// starts below the status bar (PLAN 5.3) and below the top bar of the
/// layouts that have one; the bottom bar floats over its lower edge.
class BrowserShell extends ConsumerStatefulWidget {
  const BrowserShell({super.key});

  @override
  ConsumerState<BrowserShell> createState() => _BrowserShellState();
}

class _BrowserShellState extends ConsumerState<BrowserShell>
    with TickerProviderStateMixin {
  StreamSubscription<TabEvent>? _events;
  StreamSubscription<BridgeEvent>? _bridge;
  final _addressKey = GlobalKey();
  final _menuKey = GlobalKey();
  final _themes = ThemeCache();
  bool _keyboardUp = false;
  bool _finding = false;

  /// The tab swipe on the bar: how far the page pictures are moved.
  late final _swipe = AnimationController.unbounded(vsync: this);
  late final _swipeFade = AnimationController.unbounded(vsync: this, value: 1);
  ({String from, String? previous, String? next})? _swiping;
  var _crossed = false;

  @override
  void initState() {
    super.initState();
    _events = ref.read(tabSessionProvider).events.listen(_onTabEvent);
    _bridge = HorizontWebKit.events.listen((event) {
      if (event is OpenUrlEvent) {
        final uri = Uri.tryParse(event.url);
        if (uri != null)
          ref.read(tabsProvider.notifier).open(url: uri, private: false);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    unawaited(_bridge?.cancel());
    _swipe.dispose();
    _swipeFade.dispose();
    super.dispose();
  }

  void _onTabEvent(TabEvent event) {
    if (!mounted) return;
    unawaited(
      EngineRequests(
        context,
        ref,
        onDownloadsTap: _openDownloads,
      ).handle(event),
    );
  }

  PageActions get _actions => PageActions(ref, ScaffoldMessenger.of(context));

  Future<void> _search({String? initial}) async {
    final engine = ref.read(webEngineProvider);
    final page = ref.read(pageStateProvider);
    final uri = await showSearchScreen(
      context,
      origin: rectOf(_addressKey),
      initial: initial ?? page.url?.toString() ?? '',
    );
    if (uri == null || !mounted) return;
    // Local test pages for the spikes; not reachable in a release build.
    if (!kReleaseMode && uri.toString().contains('test%3Abergzeit')) {
      await engine.loadAsset('assets/test_pages/bergzeit.html');
      return;
    }
    setState(() => _finding = false);
    await engine.load(uri);
  }

  Future<void> _menu() async {
    final actions = _actions;
    final destination = await showMenuSheet(
      context,
      origin: rectOf(_menuKey),
      actions: actions,
    );
    if (!mounted || destination == null) return;
    switch (destination) {
      case MenuDestination.find:
        setState(() => _finding = true);
      case MenuDestination.tabs:
        await showTabsPage(context, ref);
      case MenuDestination.library:
        await _openLibrary();
      case MenuDestination.downloads:
        _openDownloads();
      case MenuDestination.privateTab:
        actions.openPrivateTab();
      case MenuDestination.newTab:
        actions.openNewTab();
      case MenuDestination.settings:
        await Navigator.of(context)
            .push(screenRoute<void>(const SettingsPage()));
    }
  }

  Future<void> _openLibrary() async {
    final result = await Navigator.of(context)
        .push(screenRoute<LibraryResult>(const LibraryPage()));
    if (result == null || !mounted) return;
    await ref.read(webEngineProvider).load(result.url);
  }

  void _openDownloads() => unawaited(
    Navigator.of(context).push(screenRoute<void>(const DownloadsPage())),
  );

  Future<void> _open(Uri uri) => ref.read(webEngineProvider).load(uri);

  // Tab swipe on the bar (PLAN 6.2): the page pictures follow the finger.

  void _onSwipeUpdate(double dx) {
    final width = MediaQuery.sizeOf(context).width;
    if (_swiping == null) {
      final state = ref.read(tabsProvider);
      final visible = state.visible;
      final i = visible.indexWhere((t) => t.id == state.activeId);
      _swiping = (
        from: state.activeId,
        previous: i > 0 ? visible[i - 1].id : null,
        next: i >= 0 && i < visible.length - 1 ? visible[i + 1].id : null,
      );
      _crossed = false;
      _swipe.stop();
      _swipeFade.value = 1;
      unawaited(ref.read(tabSessionProvider).captureActive());
      setState(() {});
    }
    final s = _swiping!;
    final allowed = dx > 0 ? s.previous != null : s.next != null;
    // Without a neighbour that way the picture stretches less and less.
    _swipe.value = allowed ? dx : dx.sign * 40 * (1 - 1 / (1 + dx.abs() / 120));
    final crossed = allowed && dx.abs() > width / 3;
    if (crossed != _crossed) {
      _crossed = crossed;
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _onSwipeEnd(double velocity) async {
    final s = _swiping;
    if (s == null) return;
    final width = MediaQuery.sizeOf(context).width;
    final dx = _swipe.value;
    final dir = dx == 0 ? -velocity.sign : dx.sign;
    final target = dir > 0 ? s.previous : s.next;
    final commit =
        target != null &&
        (dx.abs() > width / 3 ||
            (velocity.abs() > 700 && velocity.sign == dx.sign));
    if (!commit) {
      await _swipe.springTo(
        0,
        motion: HorizontMotion.spatial,
        velocity: velocity,
      );
      if (mounted) setState(() => _swiping = null);
      return;
    }
    HapticFeedback.lightImpact();
    await _swipe.springTo(
      dir * width,
      motion: HorizontMotion.spatialFast,
      velocity: velocity,
    );
    if (!mounted) return;
    ref.read(tabsProvider.notifier).activate(target);
    // The live page of the new tab is under the picture now; let it show.
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await _swipeFade.springTo(0, motion: HorizontMotion.effects);
    if (mounted) setState(() => _swiping = null);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final tabs = ref.watch(tabsProvider);
    final private = tabs.privateMode;
    final palette = ref.watch(systemPaletteProvider).value;
    final base = Theme.of(context);
    // Private mode always uses the dark scheme of the colourway (`P:792`).
    final theme = private
        ? _themes.get(settings.colourway, Brightness.dark, palette: palette)
        : base;
    return Theme(
      data: theme,
      child: Builder(builder: (context) => _build(context, tabs)),
    );
  }

  Widget _build(BuildContext context, TabsState tabs) {
    final layout = ref.watch(settingsProvider.select((s) => s.barLayout));
    final engine = ref.watch(webEngineProvider);
    final page = ref.watch(pageStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final colors = HorizontColors.of(context);
    final private = tabs.privateMode;
    final top = MediaQuery.viewPaddingOf(context).top;
    final reserve = topReserveOf(layout);
    final status = ref.watch(statusBarProvider);
    final tint = ref.watch(settingsProvider.select((s) => s.tintFromPage));
    final surface = private
        ? colors.privateBackground
        : scheme.surfaceContainer;
    final onPage = page.url != null && page.error == null;
    final look = statusBarLook(
      onPage: onPage,
      tint: tint,
      pageColor: status.pageColor,
      scrolled: status.scrolled,
      surface: surface,
    );
    // The bar steps aside for the keyboard; the Scaffold shrinks the page to
    // the space above it, so a focused page field stays in view.
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardUp != _keyboardUp) {
      _keyboardUp = keyboardUp;
      // Only for a field of the page: the search screen above has its own.
      if (keyboardUp &&
          !_finding &&
          (ModalRoute.of(context)?.isCurrent ?? true)) {
        Timer(const Duration(milliseconds: 350), () {
          if (mounted) unawaited(engine.revealFocusedField());
        });
      }
    }
    final barMode = ref.watch(barModeProvider);

    final actions = BarActions(
      back: page.canGoBack
          ? engine.goBack
          : (page.url != null ? engine.goToStart : null),
      forward: page.canGoForward ? engine.goForward : null,
      reload: page.url == null ? null : engine.reload,
      search: () => unawaited(_search()),
      menu: () => unawaited(_menu()),
      tabs: () => unawaited(showTabsPage(context, ref)),
      library: () => unawaited(_openLibrary()),
      share: onPage ? () => unawaited(_actions.share()) : null,
      newTab: () => ref.read(tabsProvider.notifier).open(),
      home: () => unawaited(engine.goToStart()),
      reader: onPage
          ? () => unawaited(_actions.setReader(context, !page.reader))
          : null,
      tabCount: tabs.visible.length,
      readerOn: page.reader,
      privateMode: private,
      addressKey: _addressKey,
      menuKey: _menuKey,
    );

    // Back: find, then the reader, then the page's history, then the tab
    // this one was opened from (closing it), then the start page, then the
    // app.
    final openerId = tabs.active.openerId;
    final hasOpener = openerId != null && tabs.byId(openerId) != null;
    return PopScope(
      canPop:
          !_finding &&
          !page.reader &&
          page.url == null &&
          !page.canGoBack &&
          !hasOpener,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_finding) {
          setState(() => _finding = false);
        } else if (page.reader) {
          unawaited(_actions.setReader(context, false));
        } else if (page.canGoBack) {
          unawaited(engine.goBack());
        } else if (hasOpener) {
          final notifier = ref.read(tabsProvider.notifier);
          notifier.activate(openerId);
          notifier.close(tabs.activeId);
        } else {
          unawaited(engine.goToStart());
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiStyle(
          contentBrightness: statusBarContentBrightness(look),
          navigationBrightness: private ? Brightness.dark : scheme.brightness,
        ),
        child: Scaffold(
          backgroundColor: surface,
          body: Stack(
            children: [
              Positioned.fill(
                top: top + reserve,
                child: KeyedSubtree(
                  key: ValueKey(tabs.activeId),
                  child: engine.buildView(),
                ),
              ),
              if (page.url == null)
                Positioned.fill(
                  child: private
                      ? PrivatePage(topPadding: reserve)
                      : StartPage(
                          topPadding: reserve,
                          onOpen: _open,
                          onOpenInNewTab: (uri) =>
                              ref.read(tabsProvider.notifier).open(url: uri),
                        ),
                ),
              if (page.error != null)
                Positioned.fill(
                  top: top + reserve,
                  child: ErrorPage(
                    error: page.error!,
                    onRetry: () => unawaited(engine.reload()),
                    onContinueInsecure: () =>
                        unawaited(engine.continueInsecure(page.error!.url)),
                    onBack: page.canGoBack
                        ? () => unawaited(engine.goBack())
                        : () => unawaited(engine.goToStart()),
                  ),
                ),
              if (_swiping != null) _swipeLayer(context, top + reserve, tabs),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: StatusBarTint(
                  look: look,
                  height: top + reserve,
                  onTapEdge: page.url == null
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          unawaited(engine.scrollToTop());
                        },
                ),
              ),
              Positioned.fill(
                child: _finding
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: keyboardUp
                                ? 0
                                : MediaQuery.viewPaddingOf(context).bottom + 12,
                          ),
                          child: FindBar(
                            onClose: () => setState(() => _finding = false),
                          ),
                        ),
                      )
                    : BrowserBars(
                        layout: layout,
                        page: page,
                        actions: actions,
                        mode: page.url == null ? BarMode.full : barMode,
                        keyboardUp: keyboardUp,
                        engineLabel: ref.watch(searchEngineProvider).label,
                        onExpand: () =>
                            ref.read(barModeProvider.notifier).expand(),
                        onSwipeUpdate: _onSwipeUpdate,
                        onSwipeEnd: (v) => unawaited(_onSwipeEnd(v)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The pictures of the tab in front and its neighbour, moved by the swipe.
  Widget _swipeLayer(BuildContext context, double top, TabsState tabs) {
    final s = _swiping!;
    final width = MediaQuery.sizeOf(context).width;
    final scheme = Theme.of(context).colorScheme;
    Widget picture(String? id) {
      final tab = id == null ? null : tabs.byId(id);
      final path = tab?.thumbnailPath;
      return SizedBox(
        width: width,
        child: path != null && tab?.url != null
            ? Image(
                image: thumbnailImage(path),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                gaplessPlayback: true,
              )
            : ColoredBox(color: scheme.surfaceContainer),
      );
    }

    return Positioned.fill(
      top: top,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_swipe, _swipeFade]),
          builder: (context, _) {
            final dx = _swipe.value;
            return Opacity(
              opacity: _swipeFade.value.clamp(0.0, 1.0),
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      left: dx,
                      top: 0,
                      bottom: 0,
                      child: picture(s.from),
                    ),
                    if (dx > 0 && s.previous != null)
                      Positioned(
                        left: dx - width - 12,
                        top: 0,
                        bottom: 0,
                        child: picture(s.previous),
                      ),
                    if (dx < 0 && s.next != null)
                      Positioned(
                        left: dx + width + 12,
                        top: 0,
                        bottom: 0,
                        child: picture(s.next),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The lock over private tabs, above every route (PLAN 4.4).
class PrivateLockLayer extends ConsumerWidget {
  const PrivateLockLayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(privateLockActiveProvider);
    return Stack(
      children: [
        child,
        if (locked)
          const Positioned.fill(
            child: SystemUiRegion(
              brightness: Brightness.dark,
              child: PrivateLockCover(),
            ),
          ),
      ],
    );
  }
}
