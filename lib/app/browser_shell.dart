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
import '../browser/web_engine.dart';
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
import '../ui/haptics.dart';
import '../ui/motion/presence.dart';
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

  /// The search screen is open above: the keyboard that comes up for it must
  /// not shrink the page below, or the web view is laid out again every frame.
  bool _searching = false;
  bool _finding = false;

  /// Home was tapped and the web view has not reported the start page yet:
  /// the start page shows at once, so the blank page is never seen.
  bool _homing = false;
  Timer? _homingTimeout;

  void _home(WebEngine engine) {
    setState(() => _homing = true);
    // The web view turns blank as soon as it is told; the start page must
    // be on screen first.
    unawaited(
      WidgetsBinding.instance.endOfFrame.then((_) => engine.goToStart()),
    );
    // Should the web view never report it, the page is not hidden for good.
    _homingTimeout?.cancel();
    _homingTimeout = Timer(const Duration(seconds: 2), () {
      if (mounted && _homing) setState(() => _homing = false);
    });
  }

  /// The tab swipe on the bar: how far the page pictures are moved.
  late final _swipe = AnimationController.unbounded(vsync: this);
  late final _swipeFade = AnimationController.unbounded(vsync: this, value: 1);
  ({String from, String? previous, String? next})? _swiping;
  var _crossed = false;

  /// The swipe already said there is no tab that way.
  var _rejected = false;

  @override
  void initState() {
    super.initState();
    _events = ref.read(tabSessionProvider).events.listen(_onTabEvent);
    _bridge = HorizontWebKit.events.listen((event) {
      if (event is OpenUrlEvent) {
        final uri = Uri.tryParse(event.url);
        if (uri != null) ref.read(tabsProvider.notifier).openLink(uri);
      }
    });
  }

  @override
  void dispose() {
    _homingTimeout?.cancel();
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

  /// Opens the search, growing out of [origin] (the address bar when
  /// null), with [initial] in its field.
  Future<void> _search({Rect? origin, String? initial}) async {
    final engine = ref.read(webEngineProvider);
    final page = ref.read(pageStateProvider);
    setState(() => _searching = true);
    final uri = await showSearchScreen(
      context,
      origin: origin ?? rectOf(_addressKey),
      initial: initial ?? page.url?.toString() ?? '',
    );
    if (mounted) setState(() => _searching = false);
    if (uri == null || !mounted) return;
    // Local test pages for the spikes; not reachable in a release build.
    if (!kReleaseMode && uri.toString().contains('test%3Abergzeit')) {
      await engine.loadAsset('assets/test_pages/bergzeit.html');
      return;
    }
    if (!kReleaseMode && uri.toString().contains('testdarkmeta')) {
      await engine.loadAsset('assets/test_pages/dark_meta.html');
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
      _rejected = false;
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
      Haptics.play(crossed ? Haptic.threshold : Haptic.release);
    }
    if (!allowed && dx.abs() > 60 && !_rejected) {
      _rejected = true;
      Haptics.play(Haptic.reject);
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
    Haptics.play(Haptic.tap);
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
    final colourway = ref.watch(settingsProvider.select((s) => s.colourway));
    final translucent = ref.watch(
      settingsProvider.select((s) => s.translucentBars),
    );
    final private = ref.watch(tabsProvider.select((t) => t.privateMode));
    final palette = ref.watch(systemPaletteProvider).value;
    final base = Theme.of(context);
    // Private mode always uses the dark scheme of the colourway (`P:792`).
    final theme = private
        ? _themes.get(
            colourway,
            Brightness.dark,
            palette: palette,
            translucentBars: translucent,
          )
        : base;
    ref.listen(pageStateProvider.select((p) => p.url), (_, url) {
      if (_homing && url == null) {
        _homingTimeout?.cancel();
        setState(() => _homing = false);
      }
    });
    return Theme(
      data: theme,
      child: Builder(builder: _build),
    );
  }

  Widget _build(BuildContext context) {
    // Only what the shell shows: a title, scroll position or thumbnail of a
    // tab must not rebuild the whole browser (PLAN N4).
    final tabs = ref.watch(tabsProvider.select(_ShellTabs.of));
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
    final blur = ref.watch(settingsProvider.select((s) => s.statusBarBlur));
    final surface = private
        ? colors.privateBackground
        : scheme.surfaceContainer;
    final onPage = page.url != null && page.error == null;
    final look = statusBarLook(
      onPage: onPage,
      tint: tint,
      pageColors: status.pageColors,
      scrolled: status.scrolled,
      surface: surface,
    );
    // The bar steps aside for the keyboard; the Scaffold shrinks the page to
    // the space above it, so a focused page field stays in view.
    // Not for the search screen above: the bars are covered and need not move.
    final keyboardUp =
        !_searching && MediaQuery.viewInsetsOf(context).bottom > 0;
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
    // The chosen height, and above a bar the page keeps at the bottom; the
    // web view fills the screen, so its fraction is of the screen height.
    final (barRaise, liftOver) = ref.watch(
      settingsProvider.select((s) => (s.barRaise, s.liftOverPageBars)),
    );
    final pageBar = liftOver && page.url != null
        ? ref.watch(pageBottomBarProvider) * MediaQuery.sizeOf(context).height
        : 0.0;
    final raise = barRaise + pageBar;
    // Until a restored tab's page reports, the bar shows the tab's address.
    final restoring = page.url == null && tabs.activeUrl != null && !_homing;
    final barPage = restoring
        ? page.copyWith(url: tabs.activeUrl, title: tabs.activeTitle)
        : page;

    final actions = BarActions(
      forward: page.canGoForward ? engine.goForward : null,
      reload: page.url == null ? null : engine.reload,
      search: () => unawaited(_search()),
      menu: () => unawaited(_menu()),
      tabs: () => unawaited(showTabsPage(context, ref)),
      library: () => unawaited(_openLibrary()),
      share: onPage ? () => unawaited(_actions.share()) : null,
      copyAddress: onPage ? () => unawaited(_actions.copyAddress()) : null,
      newTab: () => ref.read(tabsProvider.notifier).open(),
      home: () => _home(engine),
      reader: onPage
          ? () => unawaited(_actions.setReader(context, !page.reader))
          : null,
      tabCount: tabs.count,
      readerOn: page.reader,
      privateMode: private,
      addressKey: _addressKey,
      menuKey: _menuKey,
    );

    // Back: find, then the reader, then the page's history, then (a tab a
    // link from another app opened) closing it and returning to that app,
    // then the tab this one was opened from (closing it), then the start
    // page, then the app. The start page ends the history: `goToStart` adds
    // about:blank, so `canGoBack` is true behind it and must not count.
    final openerId = tabs.openerId;
    final hasOpener = openerId != null;
    final external = ref.read(tabsProvider.notifier).isExternal(tabs.activeId);
    return PopScope(
      canPop:
          !_finding &&
          !page.reader &&
          page.url == null &&
          !hasOpener &&
          !external,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_finding) {
          setState(() => _finding = false);
        } else if (page.reader) {
          unawaited(_actions.setReader(context, false));
        } else if (page.url != null && page.canGoBack) {
          unawaited(engine.goBack());
        } else if (external) {
          ref.read(tabsProvider.notifier).close(tabs.activeId);
          unawaited(SystemNavigator.pop());
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
          resizeToAvoidBottomInset: !_searching,
          backgroundColor: surface,
          body: Stack(
            children: [
              Positioned.fill(
                top: top + reserve,
                child: KeyedSubtree(
                  key: ValueKey(tabs.activeId),
                  // Hidden while searching: a native view under a screen that
                  // changes every frame is composed again each frame.
                  child: Offstage(
                    offstage: _searching,
                    child: engine.buildView(),
                  ),
                ),
              ),
              // A restored tab's picture until its page reports, so the
              // empty web view is not what the first second shows (PLAN N4).
              Positioned.fill(
                top: top + reserve,
                child: SpringPresence(
                  visible: restoring && tabs.activeThumbnail != null,
                  child: tabs.activeThumbnail == null
                      ? const SizedBox.shrink()
                      : Image(
                          image: thumbnailImage(tabs.activeThumbnail!),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          gaplessPlayback: true,
                        ),
                ),
              ),
              Positioned.fill(
                child: SpringPresence(
                  // A restored tab reports its address only once its page
                  // starts loading; until then it is not the start page.
                  visible:
                      (page.url == null && tabs.activeUrl == null) || _homing,
                  backdrop: surface,
                  child: _startPage(private: private, reserve: reserve),
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
              if (_swiping != null)
                _swipeLayer(context, top + reserve, ref.watch(tabsProvider)),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: StatusBarTint(
                  look: look,
                  height: top + reserve,
                  edgeHeight: blur.edgeHeight,
                  onTapEdge: page.url == null
                      ? null
                      : () {
                          Haptics.play(Haptic.tap);
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
                        page: barPage,
                        actions: actions,
                        mode: page.url == null ? BarMode.full : barMode,
                        keyboardUp: keyboardUp,
                        engineLabel: ref.watch(searchEngineProvider).label,
                        onExpand: () =>
                            ref.read(barModeProvider.notifier).expand(),
                        onSwipeUpdate: _onSwipeUpdate,
                        onSwipeEnd: (v) => unawaited(_onSwipeEnd(v)),
                        raise: keyboardUp ? 0 : raise,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The start page, made once per look: the same widget instance lets
  /// Flutter skip its whole subtree when the shell rebuilds for the page's
  /// progress or the bar (PLAN N4).
  Widget? _start;
  (bool, double)? _startKey;

  Widget _startPage({required bool private, required double reserve}) {
    if (_start == null || _startKey != (private, reserve)) {
      _startKey = (private, reserve);
      _start = private
          ? PrivatePage(topPadding: reserve)
          : StartPage(
              topPadding: reserve,
              onOpen: _open,
              onSearch: ({origin, initial}) =>
                  unawaited(_search(origin: origin, initial: initial)),
              onOpenInNewTab: (uri) =>
                  ref.read(tabsProvider.notifier).open(url: uri),
            );
    }
    return _start!;
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

/// The part of [TabsState] the shell shows; compared by value, so other
/// changes to the tabs do not rebuild it.
typedef _ShellTabsView = ({
  String activeId,
  bool privateMode,
  int count,
  String? openerId,
  Uri? activeUrl,
  String activeTitle,
  String? activeThumbnail,
});

abstract final class _ShellTabs {
  static _ShellTabsView of(TabsState t) {
    final opener = t.active.openerId;
    return (
      activeId: t.activeId,
      privateMode: t.privateMode,
      count: t.visible.length,
      openerId: opener != null && t.byId(opener) != null ? opener : null,
      activeUrl: t.active.url,
      activeTitle: t.active.title,
      activeThumbnail: t.active.thumbnailPath,
    );
  }
}
