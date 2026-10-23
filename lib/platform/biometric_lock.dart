import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../app/providers.dart';
import '../browser/tabs/tabs_notifier.dart';

/// Asks for the fingerprint (or the screen lock); tests replace it.
final authenticateProvider = Provider<Future<bool> Function(String reason)>(
  (ref) => (reason) async {
    try {
      return await LocalAuthentication().authenticate(localizedReason: reason);
    } on Object {
      return false;
    }
  },
);

/// Whether the private tabs are covered (PLAN 4.4): set when the app goes to
/// the background with private tabs open and "Private Tabs sperren" on,
/// cleared by the fingerprint.
final privateLockProvider = NotifierProvider<PrivateLock, bool>(
  PrivateLock.new,
);

class PrivateLock extends Notifier<bool> with WidgetsBindingObserver {
  @override
  bool build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    // Nothing to protect once the private tabs are gone.
    ref.listen(tabsProvider.select((s) => s.privateTabs.isEmpty), (_, empty) {
      if (empty) state = false;
    });
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle != AppLifecycleState.paused &&
        lifecycle != AppLifecycleState.hidden) {
      return;
    }
    final lock = ref.read(settingsProvider).lockPrivateTabs;
    if (lock && ref.read(tabsProvider).privateTabs.isNotEmpty) state = true;
  }

  Future<bool> unlock(String reason) async {
    final ok = await ref.read(authenticateProvider)(reason);
    if (ok) state = false;
    return ok;
  }

  /// Leaves private mode without unlocking: the normal tabs are not locked.
  void showNormalTabs() {
    ref.read(tabsProvider.notifier).showNormal();
  }
}

/// The cover shows while locked and a private tab is in front.
final privateLockActiveProvider = Provider<bool>(
  (ref) =>
      ref.watch(privateLockProvider) &&
      ref.watch(tabsProvider.select((s) => s.privateMode)),
);
