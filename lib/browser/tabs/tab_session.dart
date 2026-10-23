import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/library_providers.dart';
import '../../platform/horizont_webkit.dart';
import '../browser_providers.dart';
import '../tab_pool.dart';
import '../web_engine.dart';
import 'browser_tab.dart';
import 'tabs_notifier.dart';
import 'thumbnail_store.dart';

/// How the live web views are made; tests answer with fakes.
final engineFactoryProvider = Provider<WebEngine Function(BrowserTab tab)>(
  (ref) => throw UnimplementedError('engineFactoryProvider not overridden'),
);

final thumbnailStoreProvider = Provider<ThumbnailStore>(
  (ref) => throw UnimplementedError('thumbnailStoreProvider not overridden'),
);

final tabSessionProvider = Provider<TabSession>((ref) {
  final session = TabSession(ref);
  ref.onDispose(session.dispose);
  return session;
});

/// An event of the page in tab [tabId].
typedef TabEvent = ({String tabId, EngineEvent event});

/// Joins the stored tabs and the live web views: it makes the view of the tab
/// in front, keeps the stored tab and the history up to date with its page,
/// and saves a thumbnail and the scroll position when a view goes away or is
/// left. Page requests the UI must answer come out of [events].
class TabSession with WidgetsBindingObserver {
  TabSession(this._ref) {
    pool = TabPool(
      create: (tab) => _ref.read(engineFactoryProvider)(tab),
      onCreated: _link,
      onEvict: _save,
    );
    WidgetsBinding.instance.addObserver(this);
    _ref.listen(tabsProvider.select((s) => s.activeId), (previous, next) {
      if (previous != null) unawaited(leave(previous));
    });
    _ref.listen(tabsProvider.select((s) => {for (final t in s.tabs) t.id}), (
      previous,
      next,
    ) {
      for (final id in (previous ?? const <String>{}).difference(next)) {
        pool.drop(id);
        MemoryThumbnails.remove(id);
        unawaited(_ref.read(thumbnailStoreProvider).delete(id));
      }
    });
    // The last private tab closed: its profile is emptied and the next
    // private session gets a fresh one (PLAN 4.4).
    _ref.listen(tabsProvider.select((s) => s.privateTabs.isNotEmpty), (
      previous,
      next,
    ) {
      if (previous == true && !next) unawaited(_endPrivateSession());
    });
    _ref.listen(
      settingsProvider.select((s) => (s.blockTracking, s.fraudWarning)),
      (previous, next) {
        for (final id in pool.liveIds) {
          unawaited(
            pool.engineOf(id)?.setProtection(blocking: next.$1, safe: next.$2),
          );
        }
      },
    );
  }

  static const thumbnailWidth = 400;
  static const privatePrefix = 'private-';

  final Ref _ref;
  late final TabPool pool;
  final _events = StreamController<TabEvent>.broadcast();
  String? _privateProfile;

  /// Requests and reports of every live page, for the UI.
  Stream<TabEvent> get events => _events.stream;

  /// The web profile of the current private session.
  String get privateProfile => _privateProfile ??=
      '$privatePrefix${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _endPrivateSession() async {
    final name = _privateProfile;
    _privateProfile = null;
    if (name != null) await HorizontWebKit.clearProfile(name);
    // Views of the session may still be alive for a moment; whatever cannot
    // go now goes at the next start.
    await HorizontWebKit.deleteProfiles(privatePrefix, keep: _privateProfile);
  }

  TabsNotifier get _tabs => _ref.read(tabsProvider.notifier);

  /// The web view of the tab in front. Views beyond the limit go afterwards.
  WebEngine engineForActive() {
    final state = _ref.read(tabsProvider);
    final engine = pool.engineFor(state.active);
    final active = state.activeId;
    scheduleMicrotask(() => unawaited(pool.trim(active)));
    return engine;
  }

  /// Keeps the stored tab and the history in step with what its page does,
  /// and handles what the page reports that needs no answer.
  void Function() _link(BrowserTab tab, WebEngine engine) {
    // A view that is still to load the stored address reports no address; that
    // must not erase it.
    var armed = tab.url == null;
    Uri? recorded;
    String? zoomHost;
    void onState() {
      final page = engine.state.value;
      if (!armed) {
        if (page.url == null) return;
        armed = true;
      }
      _tabs.updatePage(
        tab.id,
        url: page.url,
        clearUrl: page.url == null,
        title: page.title,
      );
      final url = page.url;
      if (url == null) return;
      if (url.host != zoomHost) {
        zoomHost = url.host;
        final zoom = _ref.read(settingsProvider).textZoomFor(url.host);
        unawaited(engine.setTextZoom(zoom));
      }
      if (tab.isPrivate || page.error != null) return;
      if (url.scheme != 'http' && url.scheme != 'https') return;
      final library = _ref.read(libraryProvider);
      if (url != recorded && !page.loading) {
        recorded = url;
        unawaited(
          library.recordVisit(url, page.title, _ref.read(clockProvider)()),
        );
      } else if (url == recorded && page.title.isNotEmpty) {
        unawaited(library.updateTitle(url, page.title));
      }
    }

    engine.state.addListener(onState);
    final sub = engine.events.listen((event) => _onEvent(tab.id, event));
    return () {
      engine.state.removeListener(onState);
      unawaited(sub.cancel());
    };
  }

  void _onEvent(String tabId, EngineEvent event) {
    final tab = _ref.read(tabsProvider).byId(tabId);
    if (tab == null) return;
    switch (event) {
      case NewTabEvent(:final url):
        _tabs.open(url: url, openerId: tabId);
      case PageCrashedEvent():
        // The renderer is gone; a new view loads the page again.
        pool.drop(tabId);
        if (_ref.read(tabsProvider).activeId == tabId) {
          _ref.invalidate(webEngineProvider);
        }
      case TrackersBlockedEvent(:final pageHost, :final count):
        if (!tab.isPrivate && count > 0) {
          unawaited(
            _ref
                .read(libraryProvider)
                .addBlocked(
                  pageHost.isEmpty ? tab.host : pageHost,
                  count,
                  _ref.read(clockProvider)(),
                ),
          );
        }
      default:
        _events.add((tabId: tabId, event: event));
    }
  }

  /// Saves scroll position, reading progress and picture of the tab [id]
  /// while its view is still there; used when it is left or evicted.
  Future<void> _save(String id, WebEngine engine) async {
    _tabs.updatePage(id, scrollY: await engine.readScrollY());
    final tab = _ref.read(tabsProvider).byId(id);
    final url = tab?.url;
    if (tab != null && !tab.isPrivate && url != null) {
      final library = _ref.read(libraryProvider);
      if (await library.readingItem(url) != null) {
        final info = await engine.readPageInfo();
        await library.updateReading(url, readFraction: info.readFraction);
      }
    }
    await _captureThumbnail(id, engine);
  }

  Future<void> leave(String id) async {
    final engine = pool.engineOf(id);
    if (engine == null) return;
    await _save(id, engine);
  }

  /// A fresh picture of the tab in front, for the overview that is about to
  /// open. Waits at most [limit].
  Future<void> captureActive({
    Duration limit = const Duration(milliseconds: 150),
  }) async {
    final id = _ref.read(tabsProvider).activeId;
    final engine = pool.engineOf(id);
    if (engine == null) return;
    await Future.any([
      _captureThumbnail(id, engine),
      Future<void>.delayed(limit),
    ]);
  }

  Future<void> _captureThumbnail(String id, WebEngine engine) async {
    final tab = _ref.read(tabsProvider).byId(id);
    if (tab == null || tab.url == null) return;
    final bytes = await engine.captureThumbnail(thumbnailWidth);
    if (bytes == null || !_ref.mounted) return;
    final path = tab.isPrivate
        ? MemoryThumbnails.put(id, bytes)
        : await _ref.read(thumbnailStoreProvider).write(id, bytes);
    if (_ref.mounted && _ref.read(tabsProvider).byId(id) != null) {
      _tabs.updatePage(id, thumbnailPath: path);
    }
  }

  /// Writes the scroll position of every live page into its tab.
  Future<void> syncScroll() async {
    for (final id in pool.liveIds) {
      final engine = pool.engineOf(id);
      if (engine == null) continue;
      _tabs.updatePage(id, scrollY: await engine.readScrollY());
    }
  }

  @override
  void didHaveMemoryPressure() {
    unawaited(pool.trim(_ref.read(tabsProvider).activeId, keep: 1));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(syncScroll().then((_) => _tabs.flush()));
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_events.close());
    pool.dispose();
  }
}
