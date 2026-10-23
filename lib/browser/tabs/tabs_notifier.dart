import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/repositories/tabs_repository.dart';
import 'browser_tab.dart';

/// Overridden in `main` with the database; tests override it with memory.
final tabsRepositoryProvider = Provider<TabsRepository>(
  (ref) => throw UnimplementedError('tabsRepositoryProvider not overridden'),
);

/// The time source, replaced in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

@immutable
class TabsState {
  const TabsState({required this.tabs, required this.activeId});

  final List<BrowserTab> tabs;
  final String activeId;

  BrowserTab get active => tabs.firstWhere((t) => t.id == activeId);

  BrowserTab? byId(String id) {
    for (final tab in tabs) {
      if (tab.id == id) return tab;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is TabsState &&
      other.activeId == activeId &&
      listEquals(other.tabs, tabs);

  @override
  int get hashCode => Object.hash(activeId, Object.hashAll(tabs));
}

final tabsProvider = NotifierProvider<TabsNotifier, TabsState>(
  TabsNotifier.new,
);

/// The open tabs and which one is in front. The state starts with one empty
/// tab so the first frame needs no database; [restore] replaces it.
class TabsNotifier extends Notifier<TabsState> {
  static const saveDelay = Duration(milliseconds: 500);

  final _dirty = <String>{};
  final _deleted = <String>{};
  Timer? _saveTimer;

  DateTime _now() => ref.read(clockProvider)();

  @override
  TabsState build() {
    ref.onDispose(() => _saveTimer?.cancel());
    final first = BrowserTab.empty(now: _now());
    _dirty.add(first.id);
    return TabsState(tabs: [first], activeId: first.id);
  }

  /// Brings the stored tabs back, closes the stale ones and puts the tab that
  /// was in front last time in front again.
  Future<void> restore() async {
    final stored = await ref.read(tabsRepositoryProvider).loadAll();
    if (!ref.mounted) return;
    if (stored.isEmpty) {
      _scheduleSave();
      return;
    }
    _dirty.clear();
    final rememberedId = ref.read(settingsStoreProvider).activeTabId;
    final remembered = stored.any((t) => t.id == rememberedId)
        ? rememberedId!
        : stored.last.id;
    // The tab of the first frame was never stored, so it just goes away.
    state = TabsState(tabs: stored, activeId: remembered);
    closeStale();
  }

  /// Closes the tabs not looked at for longer than the setting allows; never
  /// the one in front.
  void closeStale() {
    final after = ref.read(settingsProvider).autoCloseTabs.after;
    if (after == null) return;
    final limit = _now().subtract(after);
    final stale = state.tabs
        .where((t) => t.id != state.activeId && t.lastActiveAt.isBefore(limit))
        .map((t) => t.id)
        .toList();
    for (final id in stale) {
      close(id);
    }
  }

  /// Opens a tab. Opened from [openerId] it sits next to the opener and joins
  /// its group (D13) while grouping is on.
  BrowserTab open({Uri? url, String? openerId, bool activate = true}) {
    final opener = openerId == null ? null : state.byId(openerId);
    final grouping = opener != null && ref.read(settingsProvider).groupTabs;
    final groupId = grouping ? opener.groupId ?? opener.id : null;
    final groupName = grouping
        ? opener.groupName ?? opener.displayTitle(opener.host)
        : null;
    final tab = BrowserTab.empty(
      now: _now(),
      url: url,
      openerId: opener?.id,
      groupId: groupId,
      groupName: groupName,
    );
    final tabs = [...state.tabs];
    if (grouping && opener.groupId == null) {
      final i = tabs.indexWhere((t) => t.id == opener.id);
      tabs[i] = opener.copyWith(groupId: groupId, groupName: groupName);
    }
    // Next to the opener's group, else at the end.
    var at = tabs.length;
    if (opener != null) {
      final lastOfGroup = tabs.lastIndexWhere(
        (t) => t.id == opener.id || (groupId != null && t.groupId == groupId),
      );
      at = lastOfGroup + 1;
    }
    tabs.insert(at, tab);
    _commit(tabs, activate ? tab.id : state.activeId, touched: {tab.id});
    return tab;
  }

  void activate(String id) {
    final tab = state.byId(id);
    if (tab == null) return;
    final tabs = [
      for (final t in state.tabs)
        if (t.id == id) t.copyWith(lastActiveAt: _now()) else t,
    ];
    _commit(tabs, id, touched: {id});
  }

  /// Closes [id]. The last tab is replaced by an empty one. Closing the one in
  /// front brings its opener forward, else the next tab to the right, else the
  /// one to the left.
  void close(String id) {
    final index = state.tabs.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final closing = state.tabs[index];
    final rest = [...state.tabs]..removeAt(index);
    _deleted.add(id);
    _dirty.remove(id);
    if (rest.isEmpty) {
      final fresh = BrowserTab.empty(now: _now());
      _commit([fresh], fresh.id, touched: {fresh.id});
      return;
    }
    var active = state.activeId;
    if (active == id) {
      final opener = closing.openerId == null
          ? null
          : rest.where((t) => t.id == closing.openerId).firstOrNull;
      active =
          (opener ?? rest[index < rest.length ? index : rest.length - 1]).id;
    }
    _commit(rest, active, touched: const {});
  }

  /// Moves the tab at [from] to [to] (indices as shown, after the move).
  void reorder(int from, int to) {
    final tabs = [...state.tabs];
    tabs.insert(to, tabs.removeAt(from));
    _commit(tabs, state.activeId, touched: tabs.map((t) => t.id).toSet());
  }

  /// What the page of [id] reports. Fields left out stay as they are.
  void updatePage(
    String id, {
    Uri? url,
    bool clearUrl = false,
    String? title,
    Color? pageColor,
    double? scrollY,
    String? thumbnailPath,
  }) {
    final tab = state.byId(id);
    if (tab == null) return;
    final next = tab.copyWith(
      url: url,
      clearUrl: clearUrl,
      title: title,
      pageColor: pageColor,
      scrollY: scrollY,
      thumbnailPath: thumbnailPath,
    );
    if (next == tab) return;
    _commit(
      [
        for (final t in state.tabs)
          if (t.id == id) next else t,
      ],
      state.activeId,
      touched: {id},
    );
  }

  /// Writes what is pending now, for when the app goes to the background.
  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final repository = ref.read(tabsRepositoryProvider);
    final dirty = state.tabs.where((t) => _dirty.contains(t.id)).toList();
    final deleted = _deleted.toList();
    _dirty.clear();
    _deleted.clear();
    for (final id in deleted) {
      await repository.delete(id);
    }
    await repository.upsertAll(dirty);
  }

  void _commit(
    List<BrowserTab> tabs,
    String activeId, {
    required Set<String> touched,
  }) {
    // Positions follow the order, and only changed positions are written.
    final numbered = <BrowserTab>[];
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      if (tab.position != i) {
        numbered.add(tab.copyWith(position: i));
        _dirty.add(tab.id);
      } else {
        numbered.add(tab);
      }
    }
    _dirty.addAll(touched);
    final previous = state.activeId;
    state = TabsState(tabs: numbered, activeId: activeId);
    if (previous != activeId) {
      unawaited(ref.read(settingsStoreProvider).saveActiveTabId(activeId));
    }
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveTimer ??= Timer(saveDelay, () {
      _saveTimer = null;
      unawaited(flush());
    });
  }
}
