import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'browser_tab.dart';

/// A normal tab that was closed, enough to bring it back with the same id,
/// so its picture and stored scroll position still belong to it.
@immutable
class ClosedTab {
  const ClosedTab({
    required this.id,
    required this.url,
    required this.closedAt,
    this.title = '',
    this.scrollY,
    this.thumbnailPath,
    this.pageColor,
  });

  factory ClosedTab.of(BrowserTab tab, DateTime at) => ClosedTab(
    id: tab.id,
    url: tab.url!,
    closedAt: at,
    title: tab.title,
    scrollY: tab.scrollY,
    thumbnailPath: tab.thumbnailPath,
    pageColor: tab.pageColor,
  );

  final String id;
  final Uri url;
  final DateTime closedAt;
  final String title;
  final double? scrollY;
  final String? thumbnailPath;
  final Color? pageColor;

  String get host => url.host;

  BrowserTab reopen(DateTime now) => BrowserTab(
    id: id,
    createdAt: now,
    lastActiveAt: now,
    url: url,
    title: title,
    scrollY: scrollY,
    thumbnailPath: thumbnailPath,
    pageColor: pageColor,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url.toString(),
    'closedAt': closedAt.millisecondsSinceEpoch,
    'title': title,
    'scrollY': scrollY,
    'thumbnailPath': thumbnailPath,
    'pageColor': pageColor?.toARGB32(),
  };

  static ClosedTab? fromJson(Map<String, dynamic> map) {
    final id = map['id'];
    final url = map['url'] is String
        ? Uri.tryParse(map['url'] as String)
        : null;
    final at = map['closedAt'];
    if (id is! String || url == null || at is! int) return null;
    final title = map['title'];
    final scrollY = map['scrollY'];
    final thumbnail = map['thumbnailPath'];
    final color = map['pageColor'];
    return ClosedTab(
      id: id,
      url: url,
      closedAt: DateTime.fromMillisecondsSinceEpoch(at),
      title: title is String ? title : '',
      scrollY: scrollY is num ? scrollY.toDouble() : null,
      thumbnailPath: thumbnail is String ? thumbnail : null,
      pageColor: color is int ? Color(color) : null,
    );
  }
}

final closedTabsProvider =
    NotifierProvider<ClosedTabsNotifier, List<ClosedTab>>(
      ClosedTabsNotifier.new,
    );

/// The normal tabs closed last, newest first, kept across starts. Private
/// tabs never come here.
class ClosedTabsNotifier extends Notifier<List<ClosedTab>> {
  static const limit = 10;

  @override
  List<ClosedTab> build() => [
    for (final map in ref.read(settingsStoreProvider).closedTabs)
      ?ClosedTab.fromJson(map),
  ].take(limit).toList();

  /// Remembers [tab] unless it is private or shows the start page.
  void remember(BrowserTab tab, DateTime at) {
    if (tab.isPrivate || tab.url == null) return;
    _set(
      [
        ClosedTab.of(tab, at),
        ...state.where((c) => c.id != tab.id),
      ].take(limit).toList(),
    );
  }

  /// Takes [id] out of the list to reopen it; null when it is gone.
  ClosedTab? take(String id) {
    final found = state.where((c) => c.id == id).firstOrNull;
    if (found != null) _set(state.where((c) => c.id != id).toList());
    return found;
  }

  void clear() => _set(const []);

  void _set(List<ClosedTab> next) {
    state = next;
    unawaited(
      ref.read(settingsStoreProvider).saveClosedTabs([
        for (final c in next) c.toJson(),
      ]),
    );
  }
}
