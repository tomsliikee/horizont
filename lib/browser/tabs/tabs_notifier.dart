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
  const TabsState({
    required this.tabs,
    required this.activeId,
    this.lastNormalId,
  });

  /// Normal and private tabs, each kind in its own order.
  final List<BrowserTab> tabs;
  final String activeId;

  /// The normal tab to come back to when private mode is left.
  final String? lastNormalId;

  BrowserTab get active => tabs.firstWhere((t) => t.id == activeId);

  /// Private mode is on while a private tab is in front (PLAN 1.4).
  bool get privateMode => active.isPrivate;

  /// The tabs of the mode in front, as the overview shows them.
  List<BrowserTab> get visible =>
      tabs.where((t) => t.isPrivate == privateMode).toList();

  List<BrowserTab> get normalTabs => tabs.where((t) => !t.isPrivate).toList();
  List<BrowserTab> get privateTabs => tabs.where((t) => t.isPrivate).toList();

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
      other.lastNormalId == lastNormalId &&
      listEquals(other.tabs, tabs);

  @override
  int get hashCode => Object.hash(activeId, lastNormalId, Object.hashAll(tabs));
}

final tabsProvider = NotifierProvider<TabsNotifier, TabsState>(
  TabsNotifier.new,
);

/// The open tabs and which one is in front. The state starts with one empty
/// tab so the first frame needs no database; [restore] replaces it. Private
/// tabs are never written (PLAN 1.6).
class TabsNotifier extends Notifier<TabsState> {
  static const saveDelay = Duration(milliseconds: 500);

  final _dirty = <String>{};
  final _deleted = <String>{};
  Timer? _saveTimer;

  DateTime _now() => ref.read(clockProvider)();

  /// The id of the tab the first frame took from the snapshot, if any.
  String? _snapshotId;

  @override
  TabsState build() {
    ref.onDispose(() => _saveTimer?.cancel());
    // The tab in front last time, from the snapshot: the first frame shows
    // it and its page loads while the database is still being read.
    final snap = ref.read(settingsStoreProvider).activeSnapshot;
    if (snap != null) {
      _snapshotId = snap.id;
      final first = BrowserTab(
        id: snap.id,
        createdAt: _now(),
        lastActiveAt: _now(),
        url: snap.url,
        title: snap.title,
        scrollY: snap.scrollY,
        thumbnailPath: snap.thumbnailPath,
      );
      return TabsState(tabs: [first], activeId: first.id);
    }
    final first = BrowserTab.empty(now: _now());
    _dirty.add(first.id);
    return TabsState(tabs: [first], activeId: first.id);
  }

  /// Brings the stored tabs back, closes the stale ones and keeps the tab in
  /// front: the remembered one, else the one that was in front last time.
  Future<void> restore() async {
    final stored = await ref.read(tabsRepositoryProvider).loadAll();
    if (!ref.mounted) return;
    if (stored.isEmpty) {
      _dirty.addAll(state.tabs.map((t) => t.id));
      _scheduleSave();
      return;
    }
    final storedIds = {for (final t in stored) t.id};
    // Tabs of the first frame that were never stored go, unless they were
    // given a page meanwhile (a link from another app). The snapshot's tab
    // comes back from the store; if the store no longer has it, it goes.
    final kept = [
      for (final t in state.tabs)
        if (!storedIds.contains(t.id) && t.url != null && t.id != _snapshotId)
          t,
    ];
    final tabs = [...stored, ...kept];
    final rememberedId = ref.read(settingsStoreProvider).activeTabId;
    final activeId = tabs.any((t) => t.id == state.activeId)
        ? state.activeId
        : tabs.any((t) => t.id == rememberedId)
        ? rememberedId!
        : stored.last.id;
    _dirty
      ..clear()
      ..addAll(kept.map((t) => t.id));
    state = TabsState(tabs: tabs, activeId: activeId);
    if (kept.isNotEmpty) _scheduleSave();
    closeStale();
  }

  /// A link from another app: it takes the empty tab of the first frame, or
  /// opens a tab of its own when the first frame shows a remembered tab.
  void openLink(Uri url) {
    final active = state.active;
    if (active.url == null && active.id != _snapshotId) {
      updatePage(active.id, url: url);
      _external.add(active.id);
    } else {
      _external.add(open(url: url, private: false).id);
    }
  }

  /// Tabs a link from another app opened, this run only. Back from the first
  /// page of such a tab closes it and returns to that app.
  final _external = <String>{};

  bool isExternal(String id) => _external.contains(id);

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
  /// its group (D13) while grouping is on. It is private when [private] says
  /// so, else like its opener, else like the tab in front.
  BrowserTab open({
    Uri? url,
    String? openerId,
    bool activate = true,
    bool? private,
  }) {
    final opener = openerId == null ? null : state.byId(openerId);
    final isPrivate = private ?? opener?.isPrivate ?? state.privateMode;
    final grouping =
        opener != null &&
        opener.isPrivate == isPrivate &&
        ref.read(settingsProvider).groupTabs;
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
      isPrivate: isPrivate,
    );
    final tabs = [...state.tabs];
    if (grouping && opener.groupId == null) {
      final i = tabs.indexWhere((t) => t.id == opener.id);
      tabs[i] = opener.copyWith(groupId: groupId, groupName: groupName);
    }
    // Next to the opener's group, else at the end.
    var at = tabs.length;
    if (opener != null && opener.isPrivate == isPrivate) {
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

  /// Puts a normal tab with the start page in front (PLAN N2): the newest
  /// empty one already open, else a new one. Private tabs stay as they are.
  void showStart() {
    final empty = state.normalTabs.where((t) => t.url == null).lastOrNull;
    if (empty != null) {
      activate(empty.id);
    } else {
      open(private: false);
    }
  }

  /// Switches to private mode: the private tab used last, or a new one.
  void enterPrivate() {
    if (state.privateMode) return;
    final privateTabs = state.privateTabs;
    if (privateTabs.isEmpty) {
      open(private: true);
    } else {
      final last = privateTabs.reduce(
        (a, b) => a.lastActiveAt.isAfter(b.lastActiveAt) ? a : b,
      );
      activate(last.id);
    }
  }

  /// Switches back to the normal tabs, keeping the private ones.
  void showNormal() {
    if (!state.privateMode) return;
    final back = state.lastNormalId;
    if (back != null && state.byId(back) != null) {
      activate(back);
      return;
    }
    final normal = state.normalTabs;
    if (normal.isEmpty) {
      open(private: false);
    } else {
      activate(normal.last.id);
    }
  }

  /// Closes every private tab: nothing of the session is left (`P:139`).
  void leavePrivate() {
    final private = state.privateTabs.map((t) => t.id).toList();
    showNormal();
    for (final id in private) {
      close(id);
    }
  }

  /// Closes [id]. Closing the one in front brings its opener forward, else
  /// the next tab of the same kind to the right, else the one to the left.
  /// The last normal tab is replaced by an empty one; after the last private
  /// tab the normal tabs come back.
  void close(String id) {
    final closing = state.byId(id);
    if (closing == null) return;
    _external.remove(id);
    final rest = [...state.tabs]..removeWhere((t) => t.id == id);
    _deleted.add(id);
    _dirty.remove(id);
    final sameKind = rest
        .where((t) => t.isPrivate == closing.isPrivate)
        .toList();
    var active = state.activeId;
    if (active == id) {
      if (sameKind.isEmpty) {
        if (closing.isPrivate) {
          final back = state.lastNormalId;
          final normal = rest.where((t) => !t.isPrivate).toList();
          if (normal.isEmpty) {
            final fresh = BrowserTab.empty(now: _now());
            _commit([...rest, fresh], fresh.id, touched: {fresh.id});
            return;
          }
          active = back != null && normal.any((t) => t.id == back)
              ? back
              : normal.last.id;
        } else {
          final fresh = BrowserTab.empty(now: _now());
          _commit([...rest, fresh], fresh.id, touched: {fresh.id});
          return;
        }
      } else {
        final kindIndex = state.tabs
            .where((t) => t.isPrivate == closing.isPrivate)
            .toList()
            .indexWhere((t) => t.id == id);
        final opener = closing.openerId == null
            ? null
            : sameKind.where((t) => t.id == closing.openerId).firstOrNull;
        active =
            (opener ??
                    sameKind[kindIndex < sameKind.length
                        ? kindIndex
                        : sameKind.length - 1])
                .id;
      }
    } else if (!closing.isPrivate && sameKind.isEmpty) {
      // The last normal tab closed from private mode: keep one to return to.
      final fresh = BrowserTab.empty(now: _now());
      _commit([...rest, fresh], active, touched: {fresh.id});
      return;
    }
    _commit(rest, active, touched: const {});
  }

  /// Closes every tab of the mode in front.
  void closeAll() {
    final ids = state.visible.map((t) => t.id).toList();
    for (final id in ids) {
      close(id);
    }
  }

  /// Moves the tab at [from] to [to] among the tabs of the mode in front
  /// (indices as shown, after the move).
  void reorder(int from, int to) {
    final visible = state.visible;
    if (from < 0 || from >= visible.length) return;
    final moving = visible.removeAt(from);
    visible.insert(to.clamp(0, visible.length), moving);
    final others = state.tabs.where((t) => t.isPrivate != state.privateMode);
    final tabs = state.privateMode
        ? [...others, ...visible]
        : [...visible, ...others];
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
  /// Private tabs are left out.
  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final repository = ref.read(tabsRepositoryProvider);
    final dirty = state.tabs
        .where((t) => !t.isPrivate && _dirty.contains(t.id))
        .toList();
    final deleted = _deleted.toList();
    _dirty.clear();
    _deleted.clear();
    for (final id in deleted) {
      await repository.delete(id);
    }
    await repository.upsertAll(dirty);
    final front = state.privateMode
        ? state.byId(state.lastNormalId ?? '')
        : state.active;
    if (front != null && !front.isPrivate) {
      await ref
          .read(settingsStoreProvider)
          .saveActiveSnapshot(
            id: front.id,
            url: front.url,
            title: front.title,
            scrollY: front.scrollY ?? 0,
            thumbnailPath: front.thumbnailPath,
          );
    }
  }

  void _commit(
    List<BrowserTab> tabs,
    String activeId, {
    required Set<String> touched,
  }) {
    // Positions follow the order within each kind; only changed positions
    // are written.
    final numbered = <BrowserTab>[];
    var normal = 0;
    var private = 0;
    for (final tab in tabs) {
      final position = tab.isPrivate ? private++ : normal++;
      if (tab.position != position) {
        numbered.add(tab.copyWith(position: position));
        _dirty.add(tab.id);
      } else {
        numbered.add(tab);
      }
    }
    _dirty.addAll(touched);
    final previous = state.activeId;
    final previousTab = state.byId(previous);
    var lastNormal = state.lastNormalId;
    if (previousTab != null && !previousTab.isPrivate) lastNormal = previous;
    final activeTab = numbered.firstWhere((t) => t.id == activeId);
    if (!activeTab.isPrivate) lastNormal = activeId;
    if (lastNormal != null && !numbered.any((t) => t.id == lastNormal)) {
      lastNormal = null;
    }
    state = TabsState(
      tabs: numbered,
      activeId: activeId,
      lastNormalId: lastNormal,
    );
    if (previous != activeId && !activeTab.isPrivate) {
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
