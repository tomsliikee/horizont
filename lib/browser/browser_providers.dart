import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'search_engines.dart';
import 'status_bar/page_message.dart';
import 'tabs/browser_tab.dart';
import 'tabs/tab_session.dart';
import 'tabs/tabs_notifier.dart';
import 'web_engine.dart';
import 'webview_engine.dart';

/// The real web view of [tab], set up from the settings: its own profile
/// when private, tracker blocking, Safe Browsing and HTTPS-only.
WebEngine makeWebViewEngine(BrowserTab tab, Ref ref) {
  final settings = ref.read(settingsProvider);
  return WebViewEngine(
    EngineOptions(
      profile: tab.isPrivate
          ? ref.read(tabSessionProvider).privateProfile
          : null,
      blocking: settings.blockTracking,
      safeBrowsing: settings.fraudWarning,
      httpsOnly: () => ref.read(settingsProvider).httpsOnly,
    ),
  );
}

/// The web view of the tab in front. Everything that follows "the page" (the
/// page state, the status bar) rebuilds when another tab comes forward.
/// Tests override it with a fake.
final webEngineProvider = Provider<WebEngine>((ref) {
  ref.watch(tabsProvider.select((s) => s.activeId));
  return ref.read(tabSessionProvider).engineForActive();
});

/// The engine the address bar searches with.
final searchEngineProvider = Provider<SearchEngine>(
  (ref) => ref.watch(settingsProvider.select((s) => s.searchEngine)),
);

/// The page state of the engine, for widgets that rebuild on it.
final pageStateProvider = NotifierProvider<PageStateNotifier, PageState>(
  PageStateNotifier.new,
);

class PageStateNotifier extends Notifier<PageState> {
  @override
  PageState build() {
    final listenable = ref.watch(webEngineProvider).state;
    void onChange() => state = listenable.value;
    listenable.addListener(onChange);
    ref.onDispose(() => listenable.removeListener(onChange));
    return listenable.value;
  }
}

/// How the bar stands while the page scrolls (PLAN 6.2): shrunk to the
/// minimal pill while reading down, hidden at the page end when that
/// setting is on.
enum BarMode { full, shrunk, hidden }

final barModeProvider = NotifierProvider<BarModeNotifier, BarMode>(
  BarModeNotifier.new,
);

class BarModeNotifier extends Notifier<BarMode> {
  @override
  BarMode build() {
    final engine = ref.watch(webEngineProvider);
    final settings = ref.watch(
      settingsProvider.select((s) => (s.shrinkOnScroll, s.hideBarAtPageEnd)),
    );
    final sub = engine.messages.listen((message) {
      if (message is! ScrollMessage) return;
      state = barModeFor(message, shrink: settings.$1, hideAtEnd: settings.$2);
    });
    ref.onDispose(sub.cancel);
    // A new page starts with the full bar.
    ref.listen(pageStateProvider.select((p) => p.url), (previous, next) {
      if (previous != next) state = BarMode.full;
    });
    return BarMode.full;
  }

  /// A tap on the shrunk bar brings it back.
  void expand() => state = BarMode.full;
}

/// How much of the view's height a bar the page keeps at the bottom takes
/// (0 to 0.4); the app's bar moves above it. 0 on every new page.
final pageBottomBarProvider = NotifierProvider<PageBottomBarNotifier, double>(
  PageBottomBarNotifier.new,
);

class PageBottomBarNotifier extends Notifier<double> {
  @override
  double build() {
    final engine = ref.watch(webEngineProvider);
    final sub = engine.messages.listen((message) {
      if (message is BottomMessage) state = message.fraction;
    });
    ref.onDispose(sub.cancel);
    ref.listen(pageStateProvider.select((p) => p.url), (previous, next) {
      if (previous != next) state = 0;
    });
    return 0;
  }
}

/// The bar for a scroll report: full near the top and while scrolling up,
/// shrunk while reading down, hidden at the end where the setting asks.
BarMode barModeFor(
  ScrollMessage m, {
  required bool shrink,
  required bool hideAtEnd,
}) {
  if (m.end && hideAtEnd && m.y > 0) return BarMode.hidden;
  if (!shrink || m.y < 24 || !m.down) return BarMode.full;
  return BarMode.shrunk;
}
