import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_engines.dart';
import 'tabs/browser_tab.dart';
import 'tabs/tab_session.dart';
import 'tabs/tabs_notifier.dart';
import 'web_engine.dart';
import 'webview_engine.dart';

/// The real web view of a tab, with the bridge attached.
WebEngine makeWebViewEngine(BrowserTab tab) {
  final engine = WebViewEngine();
  unawaited(engine.attachBridge());
  return engine;
}

/// The web view of the tab in front. Everything that follows "the page" (the
/// page state, the status bar) rebuilds when another tab comes forward.
/// Tests override it with a fake.
final webEngineProvider = Provider<WebEngine>((ref) {
  ref.watch(tabsProvider.select((s) => s.activeId));
  return ref.read(tabSessionProvider).engineForActive();
});

/// The engine the address bar searches with; a setting from milestone 8.
final searchEngineProvider = Provider<SearchEngine>(
  (ref) => SearchEngine.google,
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
