import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/providers.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';
import 'package:horizont/browser/tabs/closed_tabs.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/data/repositories/tabs_repository.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/data/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  var now = DateTime(2026, 10, 23, 12);
  late InMemoryTabsRepository repository;
  late SettingsStore store;

  Future<ProviderContainer> container({
    Settings settings = const Settings(),
    List<BrowserTab> stored = const [],
  }) async {
    SharedPreferences.setMockInitialValues({'settings': settings.toJson()});
    store = SettingsStore(await SharedPreferences.getInstance());
    repository = InMemoryTabsRepository(stored);
    final c = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
        tabsRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => now = DateTime(2026, 10, 23, 12));

  BrowserTab tab(
    String id, {
    int position = 0,
    DateTime? active,
    String? opener,
  }) => BrowserTab(
    id: id,
    position: position,
    createdAt: now,
    lastActiveAt: active ?? now,
    openerId: opener,
  );

  test('starts with one empty tab in front', () async {
    final c = await container();
    final state = c.read(tabsProvider);
    expect(state.tabs, hasLength(1));
    expect(state.active.url, isNull);
  });

  test('open puts the new tab in front at the end', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final first = c.read(tabsProvider).active;
    final second = notifier.open(url: Uri.parse('https://a.example'));
    final state = c.read(tabsProvider);
    expect(state.tabs.map((t) => t.id), [first.id, second.id]);
    expect(state.activeId, second.id);
    expect(state.tabs.map((t) => t.position), [0, 1]);
  });

  test('open without activate keeps the tab in front', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final first = c.read(tabsProvider).active;
    notifier.open(activate: false);
    expect(c.read(tabsProvider).activeId, first.id);
  });

  test(
    'a tab opened from another joins its group and sits next to it',
    () async {
      final c = await container();
      final notifier = c.read(tabsProvider.notifier);
      final a = c.read(tabsProvider).active;
      notifier.updatePage(a.id, title: 'Schafberg');
      final other = notifier.open(); // unrelated, after a
      final child1 = notifier.open(openerId: a.id);
      final child2 = notifier.open(openerId: a.id);
      final state = c.read(tabsProvider);
      expect(state.tabs.map((t) => t.id), [
        a.id,
        child1.id,
        child2.id,
        other.id,
      ]);
      expect(state.byId(a.id)!.groupName, 'Schafberg');
      expect(state.byId(child1.id)!.groupId, a.id);
      expect(state.byId(child2.id)!.groupName, 'Schafberg');
      expect(state.byId(other.id)!.groupId, isNull);
    },
  );

  test('no grouping when the setting is off', () async {
    final c = await container(settings: const Settings(groupTabs: false));
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    final child = notifier.open(openerId: a.id);
    expect(c.read(tabsProvider).byId(child.id)!.groupId, isNull);
    expect(c.read(tabsProvider).byId(child.id)!.openerId, a.id);
  });

  test('closing the tab in front brings its opener forward', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    notifier.open(); // b
    final child = notifier.open(openerId: a.id);
    notifier.close(child.id);
    expect(c.read(tabsProvider).activeId, a.id);
  });

  test('closing the tab in front without opener takes the right neighbour, '
      'else the left', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    final b = notifier.open();
    final d = notifier.open();
    notifier.activate(b.id);
    notifier.close(b.id);
    expect(c.read(tabsProvider).activeId, d.id);
    notifier.close(d.id);
    expect(c.read(tabsProvider).activeId, a.id);
  });

  test('closing the last tab leaves a fresh empty one', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    notifier.close(a.id);
    final state = c.read(tabsProvider);
    expect(state.tabs, hasLength(1));
    expect(state.active.id, isNot(a.id));
  });

  test('closing a background tab keeps the one in front', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    final b = notifier.open();
    notifier.close(a.id);
    expect(c.read(tabsProvider).activeId, b.id);
  });

  test('reorder renumbers positions', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    final b = notifier.open();
    final d = notifier.open();
    notifier.reorder(2, 0);
    final state = c.read(tabsProvider);
    expect(state.tabs.map((t) => t.id), [d.id, a.id, b.id]);
    expect(state.tabs.map((t) => t.position), [0, 1, 2]);
  });

  test('updatePage changes only what is given', () async {
    final c = await container();
    final notifier = c.read(tabsProvider.notifier);
    final a = c.read(tabsProvider).active;
    notifier.updatePage(a.id, url: Uri.parse('https://a.example/'), title: 'A');
    notifier.updatePage(a.id, scrollY: 120);
    final updated = c.read(tabsProvider).active;
    expect(updated.url, Uri.parse('https://a.example/'));
    expect(updated.title, 'A');
    expect(updated.scrollY, 120);
  });

  group('persistence', () {
    test('writes after the delay, and a closed tab is deleted', () async {
      final c = await container();
      final notifier = c.read(tabsProvider.notifier);
      final a = c.read(tabsProvider).active;
      final b = notifier.open();
      await notifier.flush();
      expect((await repository.loadAll()).map((t) => t.id), [a.id, b.id]);
      notifier.close(b.id);
      await notifier.flush();
      expect((await repository.loadAll()).map((t) => t.id), [a.id]);
    });

    test('a tab closed before it was written is never written', () async {
      final c = await container();
      final notifier = c.read(tabsProvider.notifier);
      final b = notifier.open();
      notifier.close(b.id);
      await notifier.flush();
      expect((await repository.loadAll()).any((t) => t.id == b.id), isFalse);
    });

    test('the tab in front is remembered', () async {
      final c = await container();
      final notifier = c.read(tabsProvider.notifier);
      final b = notifier.open();
      await Future<void>.delayed(Duration.zero);
      expect(store.activeTabId, b.id);
    });

    test('restore brings tabs back with the one that was in front', () async {
      final c = await container(
        stored: [tab('a'), tab('b', position: 1), tab('c', position: 2)],
      );
      await store.saveActiveTabId('b');
      await c.read(tabsProvider.notifier).restore();
      final state = c.read(tabsProvider);
      expect(state.tabs.map((t) => t.id), ['a', 'b', 'c']);
      expect(state.activeId, 'b');
    });

    test('restore falls back to the last tab for an unknown id', () async {
      final c = await container(stored: [tab('a'), tab('b', position: 1)]);
      await store.saveActiveTabId('gone');
      await c.read(tabsProvider.notifier).restore();
      expect(c.read(tabsProvider).activeId, 'b');
    });

    test(
      'restore with nothing stored keeps the empty tab and writes it',
      () async {
        final c = await container();
        final notifier = c.read(tabsProvider.notifier);
        final a = c.read(tabsProvider).active;
        await notifier.restore();
        await notifier.flush();
        expect((await repository.loadAll()).map((t) => t.id), [a.id]);
      },
    );
  });

  group('snapshot of the tab in front', () {
    final page = Uri.parse('https://a.example/x');

    test('the first frame shows the remembered tab', () async {
      final c = await container(stored: [tab('a'), tab('b', position: 1)]);
      await store.saveActiveSnapshot(
        id: 'b',
        url: page,
        title: 'X',
        scrollY: 40,
      );
      final fresh = ProviderContainer(
        overrides: [
          settingsStoreProvider.overrideWithValue(store),
          tabsRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(fresh.dispose);
      c.dispose();
      final first = fresh.read(tabsProvider).active;
      expect(
        (first.id, first.url, first.title, first.scrollY),
        ('b', page, 'X', 40.0),
      );
      await fresh.read(tabsProvider.notifier).restore();
      final state = fresh.read(tabsProvider);
      expect(state.tabs.map((t) => t.id), ['a', 'b']);
      expect(state.activeId, 'b');
      // Nothing to write: the snapshot's tab was stored already.
      await fresh.read(tabsProvider.notifier).flush();
      expect((await repository.loadAll()), hasLength(2));
    });

    Future<ProviderContainer> withSnapshot(
      List<BrowserTab> stored,
      String id,
    ) async {
      final c = await container(stored: stored);
      await store.saveActiveSnapshot(id: id, url: page);
      final fresh = ProviderContainer(
        overrides: [
          settingsStoreProvider.overrideWithValue(store),
          tabsRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(fresh.dispose);
      c.dispose();
      return fresh;
    }

    test('a remembered tab the store no longer has goes', () async {
      final c = await withSnapshot([tab('a'), tab('b', position: 1)], 'gone');
      await store.saveActiveTabId('a');
      await c.read(tabsProvider.notifier).restore();
      final state = c.read(tabsProvider);
      expect(state.tabs.map((t) => t.id), ['a', 'b']);
      expect(state.activeId, 'a');
    });

    test('a link opens its own tab beside the remembered one', () async {
      final c = await withSnapshot([tab('a')], 'a');
      final link = Uri.parse('https://link.example');
      c.read(tabsProvider.notifier).openLink(link);
      await c.read(tabsProvider.notifier).restore();
      final state = c.read(tabsProvider);
      expect(state.tabs, hasLength(2));
      expect(state.active.url, link);
      expect(state.byId('a'), isNotNull);
    });

    test('without a snapshot a link takes the empty first tab', () async {
      final c = await container(stored: [tab('a')]);
      final link = Uri.parse('https://link.example');
      c.read(tabsProvider.notifier).openLink(link);
      await c.read(tabsProvider.notifier).restore();
      final state = c.read(tabsProvider);
      expect(state.tabs, hasLength(2));
      expect(state.active.url, link);
    });

    test('flush remembers the normal tab, also from private mode', () async {
      final c = await container(stored: [tab('a')]);
      final n = c.read(tabsProvider.notifier);
      await n.restore();
      n.updatePage('a', url: page, title: 'A');
      n.enterPrivate();
      await n.flush();
      expect(store.activeSnapshot?.id, 'a');
      expect(store.activeSnapshot?.url, page);
    });
  });

  group('auto-close', () {
    List<BrowserTab> aged() => [
      tab('new', active: now.subtract(const Duration(days: 29))),
      tab('old', position: 1, active: now.subtract(const Duration(days: 31))),
      tab('front', position: 2, active: now.subtract(const Duration(days: 90))),
    ];

    test(
      'month closes tabs older than 30 days, never the one in front',
      () async {
        final c = await container(stored: aged());
        await store.saveActiveTabId('front');
        await c.read(tabsProvider.notifier).restore();
        expect(c.read(tabsProvider).tabs.map((t) => t.id), ['new', 'front']);
      },
    );

    test('never keeps everything', () async {
      final c = await container(
        settings: const Settings(autoCloseTabs: AutoCloseTabs.never),
        stored: aged(),
      );
      await c.read(tabsProvider.notifier).restore();
      expect(c.read(tabsProvider).tabs, hasLength(3));
    });

    test('day closes tabs older than a day, boundary kept', () async {
      final c = await container(
        settings: const Settings(autoCloseTabs: AutoCloseTabs.day),
        stored: [
          tab('exact', active: now.subtract(const Duration(days: 1))),
          tab(
            'older',
            position: 1,
            active: now.subtract(const Duration(days: 1, minutes: 1)),
          ),
          tab('front', position: 2),
        ],
      );
      await c.read(tabsProvider.notifier).restore();
      expect(c.read(tabsProvider).tabs.map((t) => t.id), ['exact', 'front']);
    });
  });

  group('private mode', () {
    test('a private tab is in front of its own list', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final normal = c.read(tabsProvider).active;
      n.enterPrivate();
      final state = c.read(tabsProvider);
      expect(state.privateMode, isTrue);
      expect(state.visible.single.isPrivate, isTrue);
      expect(state.normalTabs.single.id, normal.id);
      // A link from a private tab stays private.
      final child = n.open(
        url: Uri.parse('https://a.example'),
        openerId: state.activeId,
      );
      expect(child.isPrivate, isTrue);
    });

    test(
      'showNormal goes back to the normal tab and keeps the private ones',
      () async {
        final c = await container();
        final n = c.read(tabsProvider.notifier);
        final normal = c.read(tabsProvider).active;
        n.enterPrivate();
        n.showNormal();
        expect(c.read(tabsProvider).activeId, normal.id);
        expect(c.read(tabsProvider).privateTabs, hasLength(1));
        // Entering again comes back to the same private tab.
        final private = c.read(tabsProvider).privateTabs.single;
        n.enterPrivate();
        expect(c.read(tabsProvider).activeId, private.id);
      },
    );

    test('closing the last private tab returns to the normal tabs', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final normal = c.read(tabsProvider).active;
      n.enterPrivate();
      n.close(c.read(tabsProvider).activeId);
      expect(c.read(tabsProvider).privateMode, isFalse);
      expect(c.read(tabsProvider).activeId, normal.id);
    });

    test('leaving private mode closes every private tab', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      n.enterPrivate();
      n.open(url: Uri.parse('https://a.example'));
      n.leavePrivate();
      expect(c.read(tabsProvider).privateTabs, isEmpty);
      expect(c.read(tabsProvider).privateMode, isFalse);
    });

    test('private tabs are never written', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      n.enterPrivate();
      n.updatePage(
        c.read(tabsProvider).activeId,
        url: Uri.parse('https://secret.example'),
      );
      await n.flush();
      final stored = await repository.loadAll();
      expect(stored.where((t) => t.isPrivate), isEmpty);
      expect(stored.where((t) => t.url?.host == 'secret.example'), isEmpty);
      expect(stored, hasLength(1));
    });
  });

  group('recently closed', () {
    test('a closed page is remembered, a start page and private not', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final empty = c.read(tabsProvider).active;
      final page = n.open(url: Uri.parse('https://a.example'));
      n.updatePage(page.id, title: 'A', scrollY: 120);
      final secret = n.open(url: Uri.parse('https://b.example'), private: true);
      n
        ..close(secret.id)
        ..close(page.id)
        ..close(empty.id);
      final closed = c.read(closedTabsProvider);
      expect(closed.map((t) => t.id), [page.id]);
      expect(closed.single.title, 'A');
    });

    test('keeps the ten newest, newest first', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final ids = [
        for (var i = 0; i < 12; i++)
          n.open(url: Uri.parse('https://$i.example')).id,
      ];
      for (final id in ids) {
        n.close(id);
      }
      final closed = c.read(closedTabsProvider);
      expect(closed, hasLength(ClosedTabsNotifier.limit));
      expect(closed.first.id, ids.last);
    });

    test('reopen brings the same tab back in front with its scroll', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final page = n.open(url: Uri.parse('https://a.example'));
      n
        ..updatePage(page.id, scrollY: 300)
        ..close(page.id)
        ..reopenClosed(page.id);
      final state = c.read(tabsProvider);
      expect(state.activeId, page.id);
      expect(state.active.url, Uri.parse('https://a.example'));
      expect(state.active.scrollY, 300);
      expect(c.read(closedTabsProvider), isEmpty);
      await n.flush();
      expect((await repository.loadAll()).map((t) => t.id), contains(page.id));
    });

    test('survive a restart', () async {
      final c = await container();
      final n = c.read(tabsProvider.notifier);
      final page = n.open(url: Uri.parse('https://a.example'));
      n.close(page.id);
      await Future<void>.delayed(Duration.zero);
      final again = ProviderContainer(
        overrides: [settingsStoreProvider.overrideWithValue(store)],
      );
      addTearDown(again.dispose);
      expect(again.read(closedTabsProvider).single.url.host, 'a.example');
    });
  });
}
