import '../../browser/tabs/browser_tab.dart';

/// Where normal tabs are kept between runs. Private tabs never reach it.
abstract interface class TabsRepository {
  /// All tabs ordered by position.
  Future<List<BrowserTab>> loadAll();

  Future<void> upsert(BrowserTab tab);
  Future<void> upsertAll(List<BrowserTab> tabs);
  Future<void> delete(String id);
}

/// Keeps tabs in memory: the repository of tests, and of private tabs later.
class InMemoryTabsRepository implements TabsRepository {
  InMemoryTabsRepository([Iterable<BrowserTab> initial = const []]) {
    for (final tab in initial) {
      _tabs[tab.id] = tab;
    }
  }

  final _tabs = <String, BrowserTab>{};

  @override
  Future<List<BrowserTab>> loadAll() async =>
      _tabs.values.toList()..sort((a, b) => a.position.compareTo(b.position));

  @override
  Future<void> upsert(BrowserTab tab) async => _tabs[tab.id] = tab;

  @override
  Future<void> upsertAll(List<BrowserTab> tabs) async {
    for (final tab in tabs) {
      _tabs[tab.id] = tab;
    }
  }

  @override
  Future<void> delete(String id) async {
    _tabs.remove(id);
    // Like the database: tabs opened from it keep going without an opener.
    for (final tab in _tabs.values.toList()) {
      if (tab.openerId == id) {
        _tabs[tab.id] = tab.copyWith(clearOpener: true);
      }
    }
  }
}
