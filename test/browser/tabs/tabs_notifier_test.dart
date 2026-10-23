import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/providers.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';
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
}
