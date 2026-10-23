import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/fake_web_engine.dart';
import 'package:horizont/browser/status_bar/page_message.dart';
import 'package:horizont/browser/tab_pool.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';

void main() {
  group('PoolPolicy', () {
    test('keeps everything within the limit', () {
      expect(
        PoolPolicy.evict(lru: ['a', 'b', 'c'], active: 'c', limit: 3),
        isEmpty,
      );
    });

    test('drops the least recently used first', () {
      expect(
        PoolPolicy.evict(lru: ['a', 'b', 'c', 'd'], active: 'd', limit: 3),
        ['a'],
      );
      expect(
        PoolPolicy.evict(lru: ['a', 'b', 'c', 'd', 'e'], active: 'e', limit: 3),
        ['a', 'b'],
      );
    });

    test('never drops the tab in front, even when it is the oldest', () {
      expect(
        PoolPolicy.evict(lru: ['a', 'b', 'c', 'd'], active: 'a', limit: 3),
        ['b'],
      );
    });

    test('a limit of one leaves only the tab in front', () {
      expect(PoolPolicy.evict(lru: ['a', 'b', 'c'], active: 'b', limit: 1), [
        'a',
        'c',
      ]);
    });
  });

  group('TabPool', () {
    final t0 = DateTime(2026, 10, 23);
    BrowserTab tab(String id, {Uri? url, double? scrollY}) => BrowserTab(
      id: id,
      createdAt: t0,
      lastActiveAt: t0,
      url: url,
      scrollY: scrollY,
    );

    late Map<String, FakeWebEngine> engines;
    late List<String> evicted;
    late TabPool pool;

    setUp(() {
      engines = {};
      evicted = [];
      pool = TabPool(
        create: (tab) => engines[tab.id] = FakeWebEngine(),
        onEvict: (id, engine) async => evicted.add(id),
      );
    });

    test(
      'makes a view once per tab and loads the stored page at its scroll',
      () async {
        final a = tab('a', url: Uri.parse('https://a.example/'), scrollY: 300);
        final first = pool.engineFor(a);
        expect(pool.engineFor(a), same(first));
        expect(engines, hasLength(1));
        await pumpEventQueue();
        expect(engines['a']!.loads, [(Uri.parse('https://a.example/'), 300.0)]);
      },
    );

    test('an empty tab loads nothing', () {
      pool.engineFor(tab('a'));
      expect(engines['a']!.loads, isEmpty);
    });

    test('evicts the least recently used view beyond three', () async {
      for (final id in ['a', 'b', 'c']) {
        pool.engineFor(tab(id));
      }
      pool.engineFor(tab('a')); // a is recent again; b is the oldest
      pool.engineFor(tab('d'));
      await pool.trim('d');
      expect(evicted, ['b']);
      expect(pool.liveIds, ['c', 'a', 'd']);
      expect(engines['b']!.disposed, isTrue);
      expect(engines['a']!.disposed, isFalse);
    });

    test('keeps only the tab in front under memory pressure', () async {
      for (final id in ['a', 'b', 'c']) {
        pool.engineFor(tab(id));
      }
      await pool.trim('b', keep: 1);
      expect(pool.liveIds, ['b']);
      expect(evicted, unorderedEquals(['a', 'c']));
    });

    test('a view that fails to save is still disposed', () async {
      pool = TabPool(
        create: (tab) => engines[tab.id] = FakeWebEngine(),
        onEvict: (id, engine) async => throw StateError('disk full'),
        limit: 1,
      );
      pool.engineFor(tab('a'));
      pool.engineFor(tab('b'));
      await expectLater(pool.trim('b'), throwsStateError);
      expect(engines['a']!.disposed, isTrue);
      expect(pool.liveIds, ['b']);
    });

    test('remembers the last scroll position the page reported', () async {
      pool.engineFor(tab('a', scrollY: 50));
      expect(pool.scrollOf('a'), 50);
      engines['a']!.report(ScrollMessage(420, false));
      await Future<void>.delayed(Duration.zero);
      expect(pool.scrollOf('a'), 420);
    });

    test('drop disposes without saving', () {
      pool.engineFor(tab('a'));
      pool.drop('a');
      expect(evicted, isEmpty);
      expect(engines['a']!.disposed, isTrue);
      expect(pool.isLive('a'), isFalse);
    });
  });
}
