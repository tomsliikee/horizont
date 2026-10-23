import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'status_bar/page_message.dart';

/// What the browser chrome needs to know about the page of one tab.
@immutable
class PageState {
  const PageState({
    this.url,
    this.title = '',
    this.progress = 0,
    this.loading = false,
    this.canGoBack = false,
    this.canGoForward = false,
  });

  /// Null while the tab shows the start page.
  final Uri? url;
  final String title;

  /// 0 to 1.
  final double progress;
  final bool loading;
  final bool canGoBack;
  final bool canGoForward;

  bool get secure => url?.scheme == 'https';
  String get host => url?.host ?? '';

  /// The host as the address bar shows it, without a leading `www.`.
  String get displayHost => host.startsWith('www.') ? host.substring(4) : host;

  PageState copyWith({
    Uri? url,
    bool clearUrl = false,
    String? title,
    double? progress,
    bool? loading,
    bool? canGoBack,
    bool? canGoForward,
  }) => PageState(
    url: clearUrl ? null : url ?? this.url,
    title: title ?? this.title,
    progress: progress ?? this.progress,
    loading: loading ?? this.loading,
    canGoBack: canGoBack ?? this.canGoBack,
    canGoForward: canGoForward ?? this.canGoForward,
  );

  @override
  bool operator ==(Object other) =>
      other is PageState &&
      other.url == url &&
      other.title == title &&
      other.progress == progress &&
      other.loading == loading &&
      other.canGoBack == canGoBack &&
      other.canGoForward == canGoForward;

  @override
  int get hashCode =>
      Object.hash(url, title, progress, loading, canGoBack, canGoForward);
}

/// One browsing context. The UI talks to this interface only, so tests swap
/// the web view for a fake.
abstract interface class WebEngine {
  ValueListenable<PageState> get state;

  /// Links the page tried to open in another app (`mailto:`, `intent:` ...).
  /// They are not followed here.
  Stream<Uri> get blockedLinks;

  /// What the page script reports: the colour at the top and the scroll
  /// state (PLAN 5.4).
  Stream<PageMessage> get messages;

  /// The widget that shows the page.
  Widget buildView();

  /// Loads [uri]; with [scrollY] the page is scrolled there once it has
  /// loaded, for bringing a tab back where it was.
  Future<void> load(Uri uri, {double scrollY = 0});

  /// Loads a page bundled with the app, for the local test pages.
  Future<void> loadAsset(String key);
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();

  /// Empties the tab so the start page shows.
  Future<void> goToStart();

  /// Scrolls the page smoothly to the top.
  Future<void> scrollToTop();

  /// The average colour of the top of what the page shows, from a capture of
  /// the native view; null where that is not possible. The fallback for pages
  /// whose top is a gradient or a photo.
  Future<Color?> sampleTop();

  /// How far the page is scrolled, in page pixels, for bringing the tab back
  /// to the same place. The page script only reports threshold crossings, so
  /// this asks the page.
  Future<double> readScrollY();

  /// A small picture of what the page shows, [width] pixels wide, for the tab
  /// overview (WebP); null where capturing is not possible.
  Future<Uint8List?> captureThumbnail(int width);

  /// Scrolls the focused page field to the middle of the visible page, for
  /// when the keyboard has just taken space from it.
  Future<void> revealFocusedField();

  void dispose();
}
