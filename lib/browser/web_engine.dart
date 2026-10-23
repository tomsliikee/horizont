import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'status_bar/page_message.dart';

/// Why a page could not be shown; the shell puts a page of its own over it.
enum PageErrorKind {
  /// No network, host not found, timeout.
  offline,

  /// The certificate was refused.
  certificate,

  /// HTTPS-only is on and the site has no HTTPS (PLAN 4.2).
  insecure,

  /// Anything else the web view gave up on.
  failed,
}

@immutable
class PageError {
  const PageError(this.kind, this.url, {this.description = ''});
  final PageErrorKind kind;
  final Uri url;
  final String description;

  @override
  bool operator ==(Object other) =>
      other is PageError &&
      other.kind == kind &&
      other.url == url &&
      other.description == description;

  @override
  int get hashCode => Object.hash(kind, url, description);
}

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
    this.error,
    this.reader = false,
    this.desktop = false,
  });

  /// Null while the tab shows the start page.
  final Uri? url;
  final String title;

  /// 0 to 1.
  final double progress;
  final bool loading;
  final bool canGoBack;
  final bool canGoForward;
  final PageError? error;

  /// The reader view is shown over the page.
  final bool reader;

  /// The page was asked for as on a desktop.
  final bool desktop;

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
    PageError? error,
    bool clearError = false,
    bool? reader,
    bool? desktop,
  }) => PageState(
    url: clearUrl ? null : url ?? this.url,
    title: title ?? this.title,
    progress: progress ?? this.progress,
    loading: loading ?? this.loading,
    canGoBack: canGoBack ?? this.canGoBack,
    canGoForward: canGoForward ?? this.canGoForward,
    error: clearError ? null : error ?? this.error,
    reader: reader ?? this.reader,
    desktop: desktop ?? this.desktop,
  );

  @override
  bool operator ==(Object other) =>
      other is PageState &&
      other.url == url &&
      other.title == title &&
      other.progress == progress &&
      other.loading == loading &&
      other.canGoBack == canGoBack &&
      other.canGoForward == canGoForward &&
      other.error == error &&
      other.reader == reader &&
      other.desktop == desktop;

  @override
  int get hashCode => Object.hash(
    url,
    title,
    progress,
    loading,
    canGoBack,
    canGoForward,
    error,
    reader,
    desktop,
  );
}

/// Something a page asks of the browser, or reports, that the UI answers.
/// Requests carry a completer; a request nobody listens to is answered with
/// the safe default by the engine.
sealed class EngineEvent {
  const EngineEvent();
}

/// A link to another app (`mailto:`, `intent:` ...), not followed by itself.
class ExternalLinkEvent extends EngineEvent {
  const ExternalLinkEvent(this.uri);
  final Uri uri;
}

/// The page wants [url] in a new tab.
class NewTabEvent extends EngineEvent {
  const NewTabEvent(this.url);
  final Uri url;
}

/// Find in page progressed: match [active] (1-based, 0 = none) of [count].
class FindResultEvent extends EngineEvent {
  const FindResultEvent(this.active, this.count);
  final int active;
  final int count;
}

/// The page started a download.
class DownloadRequestEvent extends EngineEvent {
  const DownloadRequestEvent({
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.userAgent,
    required this.cookies,
    required this.referer,
    this.bytes,
  });
  final Uri url;
  final String fileName;
  final String mimeType;

  /// Bytes, or null where the server did not say.
  final int? size;
  final String userAgent;
  final String? cookies;
  final Uri? referer;

  /// The content itself, for `blob:` and `data:` downloads.
  final Uint8List? bytes;
}

/// The renderer of the page died; the tab session replaces the view.
class PageCrashedEvent extends EngineEvent {
  const PageCrashedEvent();
}

/// Trackers blocked on the page since the last report.
class TrackersBlockedEvent extends EngineEvent {
  const TrackersBlockedEvent(this.pageHost, this.count);
  final String pageHost;
  final int count;
}

enum JsDialogKind { alert, confirm, prompt }

/// `alert`, `confirm` or `prompt`. Answered with null (alert), a bool
/// (confirm) or the text (prompt, null to cancel).
class JsDialogEvent extends EngineEvent {
  JsDialogEvent(this.kind, this.message, {this.defaultText = ''});
  final JsDialogKind kind;
  final String message;
  final String defaultText;
  final answer = Completer<Object?>();
}

/// The server asks for a user name and password.
class HttpAuthEvent extends EngineEvent {
  HttpAuthEvent(this.host, this.realm);
  final String host;
  final String? realm;

  /// The pair, or null to cancel.
  final answer = Completer<(String, String)?>();
}

enum SitePermissionKind { camera, microphone, location }

/// The page asks for camera, microphone or location.
class PermissionEvent extends EngineEvent {
  PermissionEvent(this.origin, this.kinds);
  final String origin;
  final Set<SitePermissionKind> kinds;
  final answer = Completer<bool>();
}

/// `<input type="file">`: answered with file URIs, empty to cancel.
class FileChooserEvent extends EngineEvent {
  FileChooserEvent(this.acceptTypes, {required this.multiple});
  final List<String> acceptTypes;
  final bool multiple;
  final answer = Completer<List<String>>();
}

/// A video went full screen: show [view] until [exit] is called, or until
/// [FullscreenExitEvent].
class FullscreenEvent extends EngineEvent {
  const FullscreenEvent(this.view, this.exit);
  final Widget view;
  final VoidCallback exit;
}

class FullscreenExitEvent extends EngineEvent {
  const FullscreenExitEvent();
}

/// Measures of the page for the reading list.
@immutable
class PageInfo {
  const PageInfo({this.words = 0, this.readFraction = 0});
  final int words;

  /// How far down the page is read, 0 to 1.
  final double readFraction;
}

/// The colours and size of the reader view.
@immutable
class ReaderStyle {
  const ReaderStyle({
    required this.background,
    required this.text,
    required this.muted,
    required this.accent,
    required this.textZoom,
  });
  final Color background;
  final Color text;
  final Color muted;
  final Color accent;

  /// Percent.
  final int textZoom;
}

/// One browsing context. The UI talks to this interface only, so tests swap
/// the web view for a fake.
abstract interface class WebEngine {
  ValueListenable<PageState> get state;

  /// Requests and reports from the page (section [EngineEvent]).
  Stream<EngineEvent> get events;

  /// What the page script reports: the colour at the top and the scroll
  /// state (PLAN 5.4).
  Stream<PageMessage> get messages;

  /// Completes once the native view is prepared (profile, page script); the
  /// first load waits for it.
  Future<void> get ready;

  /// The widget that shows the page.
  Widget buildView();

  /// Loads [uri]; with [scrollY] the page is scrolled there once it has
  /// loaded, for bringing a tab back where it was.
  Future<void> load(Uri uri, {double scrollY = 0});

  /// Loads a page bundled with the app, for the local test pages.
  Future<void> loadAsset(String key);

  /// Loads a file of the app (an offline copy from the reading list).
  Future<void> loadFile(String path);
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();

  /// Empties the tab so the start page shows.
  Future<void> goToStart();

  /// Scrolls the page smoothly to the top.
  Future<void> scrollToTop();

  /// The average colour of the top of what the page shows, from a capture of
  /// the native view; null where that is not possible.
  Future<Color?> sampleTop();

  /// How far the page is scrolled, in page pixels.
  Future<double> readScrollY();

  /// A small picture of what the page shows, [width] pixels wide (WebP).
  Future<Uint8List?> captureThumbnail(int width);

  /// Scrolls the focused page field to the middle of the visible page.
  Future<void> revealFocusedField();

  /// Text size in percent (50–200).
  Future<void> setTextZoom(int percent);

  /// Asks for the desktop version of the site and reloads.
  Future<void> setDesktopMode(bool on);

  /// Highlights [text] in the page; results arrive as [FindResultEvent]s.
  Future<void> find(String text);
  Future<void> findNext({bool forward = true});
  Future<void> clearFind();

  /// Shows the article of the page in a reader view, or leaves it. False
  /// where no article was found.
  Future<bool> setReader(bool on, {ReaderStyle? style});

  Future<PageInfo> readPageInfo();

  /// Saves the page for reading offline; the saved path or null.
  Future<String?> saveArchive(String path);

  /// Tracker blocking (D6) and Safe Browsing for this view.
  Future<void> setProtection({required bool blocking, required bool safe});

  /// HTTPS-only made an exception for [url]: load it over HTTP.
  Future<void> continueInsecure(Uri url);

  void dispose();
}
