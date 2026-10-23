import 'dart:async';

import 'tabs/browser_tab.dart';
import 'status_bar/page_message.dart';
import 'web_engine.dart';

/// Which live web views go when there are too many (PLAN 4.1, D21).
abstract final class PoolPolicy {
  /// The ids to drop. [lru] lists the live tabs from the least to the most
  /// recently used; the tab in front is never dropped, so with a [limit] of
  /// 1 only it stays.
  static List<String> evict({
    required List<String> lru,
    required String active,
    required int limit,
  }) {
    final dropped = <String>[];
    var count = lru.length;
    for (final id in lru) {
      if (count <= limit) break;
      if (id == active) continue;
      dropped.add(id);
      count--;
    }
    return dropped;
  }
}

class _Live {
  _Live(this.engine);

  final WebEngine engine;
  double scrollY = 0;
  // ignore: cancel_subscriptions, cancelled when the pool releases the tab.
  StreamSubscription<PageMessage>? scrollSub;
  void Function()? unlink;
}

/// The live web views, at most [limit] of them. Everything else is only a
/// stored [BrowserTab] until it is opened again.
class TabPool {
  TabPool({
    required this.create,
    required this.onEvict,
    this.onCreated,
    this.limit = 3,
  });

  final WebEngine Function(BrowserTab tab) create;

  /// Called for a view that is about to be disposed, to save what it shows
  /// (scroll position, thumbnail) while it still exists.
  final Future<void> Function(String id, WebEngine engine) onEvict;

  /// Called when a view is made; returns what undoes what it set up.
  final void Function()? Function(BrowserTab tab, WebEngine engine)? onCreated;
  final int limit;

  /// Least recently used first.
  final _live = <String, _Live>{};

  List<String> get liveIds => _live.keys.toList();
  bool isLive(String id) => _live.containsKey(id);
  WebEngine? engineOf(String id) => _live[id]?.engine;

  /// The last scroll position the page of [id] reported.
  double scrollOf(String id) => _live[id]?.scrollY ?? 0;

  /// The view of [tab], made and loaded if it is not live. Using it makes it
  /// the most recent one.
  WebEngine engineFor(BrowserTab tab) {
    final existing = _live.remove(tab.id);
    if (existing != null) {
      _live[tab.id] = existing;
      return existing.engine;
    }
    final engine = create(tab);
    final live = _Live(engine)..scrollY = tab.scrollY ?? 0;
    live.scrollSub = engine.messages.listen((message) {
      if (message is ScrollMessage) live.scrollY = message.y;
    });
    live.unlink = onCreated?.call(tab, engine);
    _live[tab.id] = live;
    // Not at once: engineFor runs while a provider builds, and the page
    // state that loading changes must not be written back from there.
    final url = tab.url;
    if (url != null) {
      scheduleMicrotask(
        () => unawaited(engine.load(url, scrollY: tab.scrollY ?? 0)),
      );
    }
    return engine;
  }

  /// Drops the least recently used views beyond [limit] (or [keep]) and never
  /// [active]. Returns when they are saved and disposed.
  Future<void> trim(String active, {int? keep}) async {
    final ids = PoolPolicy.evict(
      lru: liveIds,
      active: active,
      limit: keep ?? limit,
    );
    for (final id in ids) {
      final live = _live[id];
      if (live == null) continue;
      try {
        await onEvict(id, live.engine);
      } finally {
        _release(id);
      }
    }
  }

  /// The tab was closed: nothing to save.
  void drop(String id) => _release(id);

  void _release(String id) {
    final live = _live.remove(id);
    if (live == null) return;
    live.unlink?.call();
    unawaited(live.scrollSub?.cancel());
    live.engine.dispose();
  }

  void dispose() {
    for (final id in liveIds) {
      _release(id);
    }
  }
}
