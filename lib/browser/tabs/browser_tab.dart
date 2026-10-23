import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// One tab as it is stored: enough to bring its page back after the web view
/// is gone (PLAN 1.5). A null [url] is the start page.
@immutable
class BrowserTab {
  const BrowserTab({
    required this.id,
    required this.createdAt,
    required this.lastActiveAt,
    this.url,
    this.title = '',
    this.pageColor,
    this.openerId,
    this.groupId,
    this.groupName,
    this.position = 0,
    this.scrollY,
    this.thumbnailPath,
  });

  /// An empty tab showing the start page.
  factory BrowserTab.empty({
    required DateTime now,
    int position = 0,
    String? openerId,
    String? groupId,
    String? groupName,
    Uri? url,
  }) => BrowserTab(
    id: newTabId(),
    createdAt: now,
    lastActiveAt: now,
    position: position,
    openerId: openerId,
    groupId: groupId,
    groupName: groupName,
    url: url,
  );

  final String id;
  final Uri? url;
  final String title;

  /// The colour at the top of the page when the tab was last seen.
  final Color? pageColor;

  /// The tab this one was opened from.
  final String? openerId;

  /// Tabs with the same group id belong together (D13).
  final String? groupId;
  final String? groupName;
  final int position;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final double? scrollY;
  final String? thumbnailPath;

  String get host => url?.host ?? '';

  /// The title for lists: the page title, else the host, else the start page.
  String displayTitle(String startPage) {
    if (title.isNotEmpty) return title;
    return host.isNotEmpty ? host : startPage;
  }

  BrowserTab copyWith({
    Uri? url,
    bool clearUrl = false,
    String? title,
    Color? pageColor,
    bool clearPageColor = false,
    String? openerId,
    bool clearOpener = false,
    String? groupId,
    String? groupName,
    bool clearGroup = false,
    int? position,
    DateTime? lastActiveAt,
    double? scrollY,
    String? thumbnailPath,
    bool clearThumbnail = false,
  }) => BrowserTab(
    id: id,
    createdAt: createdAt,
    url: clearUrl ? null : url ?? this.url,
    title: title ?? this.title,
    pageColor: clearPageColor ? null : pageColor ?? this.pageColor,
    openerId: clearOpener ? null : openerId ?? this.openerId,
    groupId: clearGroup ? null : groupId ?? this.groupId,
    groupName: clearGroup ? null : groupName ?? this.groupName,
    position: position ?? this.position,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    scrollY: scrollY ?? this.scrollY,
    thumbnailPath: clearThumbnail ? null : thumbnailPath ?? this.thumbnailPath,
  );

  @override
  bool operator ==(Object other) =>
      other is BrowserTab &&
      other.id == id &&
      other.url == url &&
      other.title == title &&
      other.pageColor == pageColor &&
      other.openerId == openerId &&
      other.groupId == groupId &&
      other.groupName == groupName &&
      other.position == position &&
      other.createdAt == createdAt &&
      other.lastActiveAt == lastActiveAt &&
      other.scrollY == scrollY &&
      other.thumbnailPath == thumbnailPath;

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    pageColor,
    openerId,
    groupId,
    groupName,
    position,
    createdAt,
    lastActiveAt,
    scrollY,
    thumbnailPath,
  );
}

final _random = Random.secure();

/// A random version 4 UUID, without a package.
String newTabId() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int from, int to) => bytes
      .sublist(from, to)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
