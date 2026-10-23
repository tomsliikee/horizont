import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Joins the stored tabs and the live web views: it makes the view of the tab
/// in front, keeps the stored tab up to date with its page, and saves a
/// thumbnail and the scroll position when a view goes away or is left.
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
        unawaited(_ref.read(thumbnailStoreProvider).delete(id));
      }
    });
  }

  static const thumbnailWidth = 400;

  final Ref _ref;
  late final TabPool pool;

  TabsNotifier get _tabs => _ref.read(tabsProvider.notifier);

  /// The web view of the tab in front. Views beyond the limit go afterwards.
  WebEngine engineForActive() {
    final state = _ref.read(tabsProvider);
    final engine = pool.engineFor(state.active);
    final active = state.activeId;
    scheduleMicrotask(() => unawaited(pool.trim(active)));
    return engine;
  }

  /// Keeps the stored tab in step with what its page does.
  void Function() _link(BrowserTab tab, WebEngine engine) {
    // A view that is still to load the stored address reports no address; that
    // must not erase it.
    var armed = tab.url == null;
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
    }

    engine.state.addListener(onState);
    return () => engine.state.removeListener(onState);
  }

  /// Saves scroll position and picture of the tab [id] while its view is
  /// still there; used when it is left or evicted.
  Future<void> _save(String id, WebEngine engine) async {
    _tabs.updatePage(id, scrollY: await engine.readScrollY());
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
    final path = await _ref.read(thumbnailStoreProvider).write(id, bytes);
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
    pool.dispose();
  }
}
