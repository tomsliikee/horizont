import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browser_providers.dart';
import '../tabs/tab_session.dart';
import '../tabs/tabs_notifier.dart';
import 'page_color_tracker.dart';
import 'page_message.dart';

/// What the page script and the capture fallback told the app.
class StatusBarInfo {
  const StatusBarInfo({this.pageColor, this.scrolled = false});

  /// The last colour at the top of the page; kept while the next page loads
  /// so the bar does not flash to white (PLAN 5.4).
  final Color? pageColor;

  /// Scrolled further than a few pixels.
  final bool scrolled;

  StatusBarInfo copyWith({Color? pageColor, bool? scrolled}) => StatusBarInfo(
    pageColor: pageColor ?? this.pageColor,
    scrolled: scrolled ?? this.scrolled,
  );

  @override
  bool operator ==(Object other) =>
      other is StatusBarInfo &&
      other.pageColor == pageColor &&
      other.scrolled == scrolled;

  @override
  int get hashCode => Object.hash(pageColor, scrolled);
}

final statusBarProvider = NotifierProvider<StatusBarNotifier, StatusBarInfo>(
  StatusBarNotifier.new,
);

class StatusBarNotifier extends Notifier<StatusBarInfo> {
  final _tracker = PageColorTracker();
  late String _tabId;

  @override
  StatusBarInfo build() {
    final engine = ref.watch(webEngineProvider);
    final sub = engine.messages.listen(_onMessage);
    ref.onDispose(sub.cancel);
    // A new page starts at the top.
    ref.listen(pageStateProvider.select((p) => p.url), (previous, next) {
      if (previous != next && state.scrolled) {
        state = state.copyWith(scrolled: false);
      }
    });
    // Coming back to a tab: its colour and scroll state are where it left
    // them, and the page script only reports when something changes.
    final tab = ref.read(tabsProvider).active;
    _tabId = tab.id;
    final scrolled = ref.read(tabSessionProvider).pool.scrollOf(tab.id) > 6;
    return StatusBarInfo(pageColor: tab.pageColor, scrolled: scrolled);
  }

  void _setColor() {
    state = state.copyWith(pageColor: _tracker.color);
    ref
        .read(tabsProvider.notifier)
        .updatePage(_tabId, pageColor: _tracker.color);
  }

  void _onMessage(PageMessage message) {
    switch (message) {
      case ColorMessage():
        if (message.color == null) {
          unawaited(_sample());
        } else if (_tracker.report(message)) {
          _setColor();
        }
      case ScrollMessage():
        final scrolled = message.y > 6;
        if (scrolled != state.scrolled) {
          state = state.copyWith(scrolled: scrolled);
        }
    }
  }

  /// The fallback for a page whose top is a gradient or a photo.
  Future<void> _sample() async {
    if (!_tracker.mayTakeSample()) return;
    final color = await ref.read(webEngineProvider).sampleTop();
    if (color == null || !ref.mounted) return;
    if (_tracker.reportSample(color.withAlpha(0xFF))) _setColor();
  }
}
