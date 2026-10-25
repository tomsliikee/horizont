import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'status_bar/page_message.dart';
import 'web_engine.dart';

/// A [WebEngine] without a web view, for tests. It keeps a back/forward list
/// like a browser and records what was asked of it.
class FakeWebEngine implements WebEngine {
  final _state = ValueNotifier(const PageState());
  final _events = StreamController<EngineEvent>.broadcast();
  final _messages = StreamController<PageMessage>.broadcast();
  /// Null entries are the start page, as `about:blank` is in the web view.
  final _history = <Uri?>[];
  var _index = -1;
  var reloads = 0;
  var reveals = 0;
  var scrollsToTop = 0;

  /// What [sampleTop] answers; null like a platform without capture.
  Color? sample;
  var samples = 0;

  @override
  ValueListenable<PageState> get state => _state;

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Stream<PageMessage> get messages => _messages.stream;

  @override
  Future<void> get ready => Future.value();

  /// Lets a test pretend the page script reported [message].
  void report(PageMessage message) => _messages.add(message);

  /// Lets a test pretend the page sent [event].
  void raise(EngineEvent event) => _events.add(event);

  @override
  Future<void> scrollToTop() async => scrollsToTop++;

  @override
  Future<Color?> sampleTop() async {
    samples++;
    return sample;
  }

  @override
  Widget buildView() => const ColoredBox(color: Color(0xFFFFFFFF));

  /// The title pages get when they load.
  String Function(Uri url) titleFor = (url) => '';

  void _show() {
    final url = _index < 0 ? null : _history[_index];
    _state.value = PageState(
      url: url,
      title: url == null ? '' : titleFor(url),
      progress: 1,
      canGoBack: _index > 0,
      canGoForward: _index >= 0 && _index < _history.length - 1,
      desktop: _state.value.desktop,
    );
  }

  /// Every `load` call, with the scroll position it asked for.
  final loads = <(Uri, double)>[];

  /// What [captureThumbnail] answers; null like a platform without capture.
  Uint8List? thumbnail;
  var captures = 0;
  var disposed = false;

  /// What [readScrollY] answers.
  double scrollY = 0;

  @override
  Future<double> readScrollY() async => scrollY;

  @override
  Future<Uint8List?> captureThumbnail(int width) async {
    captures++;
    return thumbnail;
  }

  @override
  Future<void> load(Uri uri, {double scrollY = 0}) async {
    loads.add((uri, scrollY));
    _history
      ..removeRange(_index + 1, _history.length)
      ..add(uri);
    _index = _history.length - 1;
    _show();
  }

  final assets = <String>[];

  @override
  Future<void> loadAsset(String key) async => assets.add(key);

  final files = <String>[];

  @override
  Future<void> loadFile(String path) async {
    files.add(path);
    await load(Uri.file(path));
  }

  @override
  Future<void> goBack() async {
    if (_index > 0) _index--;
    _show();
  }

  @override
  Future<void> goForward() async {
    if (_index < _history.length - 1) _index++;
    _show();
  }

  @override
  Future<void> reload() async => reloads++;

  @override
  Future<void> revealFocusedField() async => reveals++;

  @override
  Future<void> goToStart() async {
    if (_index < 0 || _history[_index] == null) return;
    _history
      ..removeRange(_index + 1, _history.length)
      ..add(null);
    _index = _history.length - 1;
    _show();
  }

  /// Lets a test pretend the page asked to open [uri] elsewhere.
  void blockLink(Uri uri) => _events.add(ExternalLinkEvent(uri));

  /// Lets a test set the page state directly (loading, title).
  void emit(PageState state) => _state.value = state;

  int? textZoom;

  @override
  Future<void> setTextZoom(int percent) async => textZoom = percent;

  @override
  Future<void> setDesktopMode(bool on) async =>
      _state.value = _state.value.copyWith(desktop: on);

  final finds = <String>[];
  var findNexts = 0;
  var findClears = 0;

  @override
  Future<void> find(String text) async => finds.add(text);

  @override
  Future<void> findNext({bool forward = true}) async => findNexts++;

  @override
  Future<void> clearFind() async => findClears++;

  /// Whether the page has an article for the reader view.
  bool hasArticle = true;

  @override
  Future<bool> setReader(bool on, {ReaderStyle? style}) async {
    if (on && !hasArticle) return false;
    _state.value = _state.value.copyWith(reader: on);
    return true;
  }

  PageInfo info = const PageInfo(words: 1600, readFraction: 0.5);

  @override
  Future<PageInfo> readPageInfo() async => info;

  final archives = <String>[];

  @override
  Future<String?> saveArchive(String path) async {
    archives.add(path);
    return path;
  }

  ({bool blocking, bool safe})? protection;

  @override
  Future<void> setProtection({
    required bool blocking,
    required bool safe,
  }) async => protection = (blocking: blocking, safe: safe);

  final insecure = <Uri>[];

  @override
  Future<void> continueInsecure(Uri url) async {
    insecure.add(url);
    await load(url);
  }

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    _state.dispose();
    _events.close();
    _messages.close();
  }
}
