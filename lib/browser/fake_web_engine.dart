import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'status_bar/page_message.dart';
import 'web_engine.dart';

/// A [WebEngine] without a web view, for tests. It keeps a back/forward list
/// like a browser and records what was asked of it.
class FakeWebEngine implements WebEngine {
  final _state = ValueNotifier(const PageState());
  final _blocked = StreamController<Uri>.broadcast();
  final _messages = StreamController<PageMessage>.broadcast();
  final _history = <Uri>[];
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
  Stream<Uri> get blockedLinks => _blocked.stream;

  @override
  Stream<PageMessage> get messages => _messages.stream;

  /// Lets a test pretend the page script reported [message].
  void report(PageMessage message) => _messages.add(message);

  @override
  Future<void> scrollToTop() async => scrollsToTop++;

  @override
  Future<Color?> sampleTop() async {
    samples++;
    return sample;
  }

  @override
  Widget buildView() => const ColoredBox(color: Color(0xFFFFFFFF));

  void _show() {
    _state.value = PageState(
      url: _index < 0 ? null : _history[_index],
      progress: 1,
      canGoBack: _index > 0,
      canGoForward: _index >= 0 && _index < _history.length - 1,
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
    _history.clear();
    _index = -1;
    _show();
  }

  /// Lets a test pretend the page asked to open [uri] elsewhere.
  void blockLink(Uri uri) => _blocked.add(uri);

  /// Lets a test set the page state directly (loading, title).
  void emit(PageState state) => _state.value = state;

  @override
  void dispose() {
    disposed = true;
    _state.dispose();
    _blocked.close();
    _messages.close();
  }
}
