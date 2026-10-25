import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/app/providers.dart';
import 'package:horizont/browser/tabs/away_watcher.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';
import 'package:horizont/browser/tabs/tabs_notifier.dart';
import 'package:horizont/data/repositories/tabs_repository.dart';
import 'package:horizont/data/settings.dart';
import 'package:horizont/data/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var now = DateTime(2026, 10, 25, 12);
  late SettingsStore store;
  final page = Uri.parse('https://bergzeit.example/herbst');

  BrowserTab tab(String id, {Uri? url, bool private = false}) => BrowserTab(
    id: id,
    createdAt: now,
    lastActiveAt: now,
    url: url,
    isPrivate: private,
  );

  Future<ProviderContainer> container({
    Settings settings = const Settings(),
    List<BrowserTab> stored = const [],
    DateTime? awaySince,
  }) async {
    SharedPreferences.setMockInitialValues({
      'settings': settings.toJson(),
      'awaySince': ?awaySince?.millisecondsSinceEpoch,
    });
    store = SettingsStore(await SharedPreferences.getInstance());
    final c = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
        tabsRepositoryProvider.overrideWithValue(
          InMemoryTabsRepository(stored),
        ),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    await c.read(tabsProvider.notifier).restore();
    return c;
  }

  setUp(() => now = DateTime(2026, 10, 25, 12));

  void away(ProviderContainer c, Duration time) {
    final watcher = c.read(awayWatcherProvider)
      ..didChangeAppLifecycleState(AppLifecycleState.hidden)
      ..didChangeAppLifecycleState(AppLifecycleState.paused);
    now = now.add(time);
    watcher.didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  test('awayTooLong', () {
    final at = DateTime(2026, 10, 25, 12);
    const hour = Duration(hours: 1);
    expect(awayTooLong(at, at.add(hour), hour), isFalse);
    expect(
      awayTooLong(at, at.add(hour + const Duration(seconds: 1)), hour),
      isTrue,
    );
    expect(awayTooLong(null, at, hour), isFalse);
    expect(awayTooLong(at, at.add(const Duration(days: 9)), null), isFalse);
  });

  test('under the limit the page stays in front', () async {
    final c = await container(stored: [tab('a', url: page)]);
    c.read(awayWatcherProvider).start();
    away(c, const Duration(minutes: 59));
    expect(c.read(tabsProvider).activeId, 'a');
    expect(c.read(tabsProvider).tabs, hasLength(1));
  });

  test('over the limit a new start tab opens; the old one stays', () async {
    final c = await container(stored: [tab('a', url: page)]);
    c.read(awayWatcherProvider).start();
    away(c, const Duration(minutes: 61));
    final state = c.read(tabsProvider);
    expect(state.tabs, hasLength(2));
    expect(state.active.url, isNull);
    expect(state.byId('a'), isNotNull);
    expect(store.awaySince, isNull);
  });

  test('an open empty start tab is reused', () async {
    final c = await container(
      stored: [
        tab('empty'),
        tab('a', url: page),
      ],
    );
    c.read(awayWatcherProvider).start();
    expect(c.read(tabsProvider).activeId, 'a');
    away(c, const Duration(hours: 2));
    expect(c.read(tabsProvider).activeId, 'empty');
    expect(c.read(tabsProvider).tabs, hasLength(2));
  });

  test('setting off: nothing happens', () async {
    final c = await container(
      settings: const Settings(homeAfterAway: HomeAfterAway.never),
      stored: [tab('a', url: page)],
    );
    c.read(awayWatcherProvider).start();
    away(c, const Duration(days: 3));
    expect(c.read(tabsProvider).activeId, 'a');
  });

  test('the shorter setting applies', () async {
    final c = await container(
      settings: const Settings(homeAfterAway: HomeAfterAway.halfHour),
      stored: [tab('a', url: page)],
    );
    c.read(awayWatcherProvider).start();
    away(c, const Duration(minutes: 31));
    expect(c.read(tabsProvider).active.url, isNull);
  });

  test('after the process was ended, the stored time counts', () async {
    final c = await container(
      stored: [tab('a', url: page)],
      awaySince: now.subtract(const Duration(hours: 5)),
    );
    expect(c.read(tabsProvider).activeId, 'a');
    c.read(awayWatcherProvider).start();
    expect(c.read(tabsProvider).active.url, isNull);
    expect(store.awaySince, isNull);
  });

  test('lifecycle before start is ignored', () async {
    final c = await container(stored: [tab('a', url: page)]);
    away(c, const Duration(hours: 5));
    expect(c.read(tabsProvider).activeId, 'a');
    expect(store.awaySince, isNull);
  });

  test('from private mode it lands on a normal start tab', () async {
    final c = await container(stored: [tab('a', url: page)]);
    c.read(tabsProvider.notifier).open(url: page, private: true);
    expect(c.read(tabsProvider).privateMode, isTrue);
    c.read(awayWatcherProvider).start();
    away(c, const Duration(hours: 2));
    final state = c.read(tabsProvider);
    expect(state.privateMode, isFalse);
    expect(state.active.url, isNull);
    expect(state.privateTabs, hasLength(1));
  });
}
