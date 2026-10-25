import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'tabs_notifier.dart';

/// Whether [since] lies longer ago than [limit] at [now]; never when either
/// is unknown or the setting is off.
bool awayTooLong(DateTime? since, DateTime now, Duration? limit) =>
    since != null && limit != null && now.difference(since) > limit;

final awayWatcherProvider = Provider<AwayWatcher>((ref) {
  final watcher = AwayWatcher(ref);
  WidgetsBinding.instance.addObserver(watcher);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(watcher));
  return watcher;
});

/// Opens the start page when the app comes back after longer away than
/// "Startseite nach Abwesenheit" allows (PLAN N2, D27). The time it left is
/// stored, so a process Android ended meanwhile counts too; that case is
/// checked by [start] once the tabs are restored.
class AwayWatcher with WidgetsBindingObserver {
  AwayWatcher(this._ref);

  final Ref _ref;
  var _started = false;

  /// Checks the time stored by an earlier process and starts watching.
  /// Lifecycle changes before it are ignored: the tabs are not back yet.
  void start() {
    if (_started) return;
    _started = true;
    _cameBack();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started) return;
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        final store = _ref.read(settingsStoreProvider);
        if (store.awaySince == null) {
          unawaited(store.saveAwaySince(_ref.read(clockProvider)()));
        }
      case AppLifecycleState.resumed:
        _cameBack();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  void _cameBack() {
    final store = _ref.read(settingsStoreProvider);
    final since = store.awaySince;
    if (since == null) return;
    unawaited(store.saveAwaySince(null));
    final limit = _ref.read(settingsProvider).homeAfterAway.after;
    if (awayTooLong(since, _ref.read(clockProvider)(), limit)) {
      _ref.read(tabsProvider.notifier).showStart();
    }
  }
}
