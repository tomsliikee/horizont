import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browser_providers.dart';
import '../tabs/tab_session.dart';
import '../tabs/tabs_notifier.dart';
import 'page_color_tracker.dart';
import 'page_message.dart';

/// What the page script and the capture of the page top told the app.
class StatusBarInfo {
  const StatusBarInfo({this.pageColors, this.scrolled = false});

  /// The colours along the top of the page, left to right; kept while the
  /// next page loads so the bar does not flash to white (PLAN 5.4).
  final List<Color>? pageColors;

  /// The colour in the middle, null before the first report.
  Color? get pageColor {
    final c = pageColors;
    return c == null || c.isEmpty ? null : c[c.length ~/ 2];
  }

  /// Scrolled further than a few pixels.
  final bool scrolled;

  StatusBarInfo copyWith({List<Color>? pageColors, bool? scrolled}) =>
      StatusBarInfo(
        pageColors: pageColors ?? this.pageColors,
        scrolled: scrolled ?? this.scrolled,
      );

  @override
  bool operator ==(Object other) =>
      other is StatusBarInfo &&
      listEquals(other.pageColors, pageColors) &&
      other.scrolled == scrolled;

  @override
  int get hashCode => Object.hash(
    pageColors == null ? 0 : Object.hashAll(pageColors!),
    scrolled,
  );
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
    final colour = tab.pageColor;
    return StatusBarInfo(
      pageColors: colour == null ? null : [colour],
      scrolled: scrolled,
    );
  }

  void _setColor() {
    state = state.copyWith(pageColors: _tracker.colors);
    ref
        .read(tabsProvider.notifier)
        .updatePage(_tabId, pageColor: _tracker.color);
  }

  void _onMessage(PageMessage message) {
    switch (message) {
      case ColorMessage():
        // What the page shows beats what it says: capture first, and take the
        // script's colour only where a capture is not possible.
        unawaited(_sample(fallback: message));
      case RestMessage():
        unawaited(_sample());
      case ScrollMessage():
        final scrolled = message.y > 6;
        if (scrolled != state.scrolled) {
          state = state.copyWith(scrolled: scrolled);
        }
      case BottomMessage():
        break;
    }
  }

  /// The colours along the top of the page, from a capture of the native
  /// view. A capture without paint yet (transparent) counts as none.
  Future<void> _sample({ColorMessage? fallback}) async {
    if (!_tracker.mayTakeSample()) return;
    final colors = await ref.read(webEngineProvider).sampleTop();
    if (!ref.mounted) return;
    final painted =
        colors != null && colors.isNotEmpty && colors.every((c) => c.a >= 0.94);
    if (painted) {
      if (_tracker.reportSample([for (final c in colors) c.withAlpha(0xFF)])) {
        _setColor();
      }
    } else if (fallback != null && _tracker.report(fallback)) {
      _setColor();
    }
  }
}
