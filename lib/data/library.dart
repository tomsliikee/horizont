import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../browser/web_engine.dart' show SitePermissionKind;

/// The icon of a bookmark folder (`P:889`–`P:894`).
enum FolderIcon { star, school, hiking, restaurant, bookmarks, folder }

/// The colour pair of a bookmark folder tile.
enum FolderTone { primary, secondary, tertiary, neutral }

@immutable
class BookmarkFolder {
  const BookmarkFolder({
    required this.id,
    required this.name,
    this.icon = FolderIcon.folder,
    this.tone = FolderTone.neutral,
    this.position = 0,
    this.isFavorites = false,
    this.count = 0,
  });
  final int id;
  final String name;
  final FolderIcon icon;
  final FolderTone tone;
  final int position;

  /// The folder whose bookmarks are the start page's favourites.
  final bool isFavorites;

  /// Bookmarks in it, when read with counts.
  final int count;
}

@immutable
class Bookmark {
  const Bookmark({
    required this.id,
    required this.folderId,
    required this.url,
    required this.title,
    this.position = 0,
    required this.createdAt,
  });
  final int id;
  final int folderId;
  final Uri url;
  final String title;
  final int position;
  final DateTime createdAt;
}

@immutable
class HistoryVisit {
  const HistoryVisit({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
  });
  final int id;
  final Uri url;
  final String title;
  final DateTime visitedAt;
}

/// One address with all its visits counted, for "Häufig besucht" and the top
/// hit.
@immutable
class HistoryPage {
  const HistoryPage({
    required this.url,
    required this.title,
    required this.visitCount,
    required this.lastVisitAt,
  });
  final Uri url;
  final String title;
  final int visitCount;
  final DateTime lastVisitAt;

  /// Visits weighted by how recent the last one was (Firefox-like buckets).
  double frecency(DateTime now) {
    final days = now.difference(lastVisitAt).inHours / 24;
    final weight = days < 4
        ? 100
        : days < 14
        ? 70
        : days < 31
        ? 50
        : days < 90
        ? 30
        : 10;
    return visitCount * weight.toDouble();
  }
}

/// What the reading list shows under an item (`P:895`–`P:899`); derived, not
/// stored.
enum ReadingState { unread, started, half, almostDone, offline }

@immutable
class ReadingItem {
  const ReadingItem({
    required this.id,
    required this.url,
    required this.title,
    required this.addedAt,
    this.readFraction = 0,
    this.estimatedMinutes = 0,
    this.offlinePath,
  });
  final int id;
  final Uri url;
  final String title;
  final DateTime addedAt;
  final double readFraction;
  final int estimatedMinutes;
  final String? offlinePath;

  String get host {
    final h = url.host;
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  ReadingState get state {
    if (readFraction >= 0.9) return ReadingState.almostDone;
    if (readFraction >= 0.4) return ReadingState.half;
    if (readFraction >= 0.05) return ReadingState.started;
    if (offlinePath != null) return ReadingState.offline;
    return ReadingState.unread;
  }
}

enum DownloadStatus { waiting, running, paused, done, failed, canceled }

@immutable
class DownloadItem {
  const DownloadItem({
    required this.taskId,
    required this.url,
    required this.fileName,
    this.mimeType = '',
    this.totalBytes,
    this.receivedBytes = 0,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.savedUri,
  });
  final String taskId;
  final Uri url;
  final String fileName;
  final String mimeType;
  final int? totalBytes;
  final int receivedBytes;
  final DownloadStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;

  /// Where the finished file lives (a path or `content:` URI).
  final String? savedUri;

  String get host {
    final h = url.host;
    return h.startsWith('www.') ? h.substring(4) : h;
  }

  double? get fraction => totalBytes == null || totalBytes == 0
      ? null
      : (receivedBytes / totalBytes!).clamp(0, 1);

  bool get active =>
      status == DownloadStatus.running ||
      status == DownloadStatus.waiting ||
      status == DownloadStatus.paused;

  DownloadItem copyWith({
    int? totalBytes,
    int? receivedBytes,
    DownloadStatus? status,
    DateTime? finishedAt,
    String? savedUri,
    String? fileName,
  }) => DownloadItem(
    taskId: taskId,
    url: url,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType,
    totalBytes: totalBytes ?? this.totalBytes,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    status: status ?? this.status,
    startedAt: startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    savedUri: savedUri ?? this.savedUri,
  );
}

/// The privacy report: trackers blocked in the last 7 days, on how many
/// sites, and how that compares with the 7 days before.
@immutable
class TrackerReport {
  const TrackerReport({this.week = 0, this.lastWeek = 0, this.sites = 0});
  final int week;
  final int lastWeek;
  final int sites;
  int get change => week - lastWeek;
}

@immutable
class SitePermission {
  const SitePermission(this.origin, this.kind, {required this.allowed});
  final String origin;
  final SitePermissionKind kind;
  final bool allowed;
}

/// `yyyy-mm-dd` of [t] in local time, the key of the tracker statistics.
String dayKey(DateTime t) {
  final l = t.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

/// Bookmarks, history, reading list, downloads, tracker counts and site
/// permissions (PLAN 1.5). The database implements it; tests and the
/// in-memory fallback use [MemoryLibrary]. [changes] fires after every write.
abstract interface class Library {
  Stream<void> get changes;

  Future<List<BookmarkFolder>> folders();
  Future<int> createFolder(String name, {FolderIcon icon, FolderTone tone});
  Future<void> renameFolder(int id, String name);

  /// Deletes the folder and its bookmarks; the favourites stay.
  Future<void> deleteFolder(int id);
  Future<List<Bookmark>> bookmarksIn(int folderId);
  Future<List<Bookmark>> favourites();
  Future<int> addBookmark(int folderId, Uri url, String title);
  Future<void> removeBookmark(int id);

  /// Bookmarks of [url] in any folder.
  Future<List<Bookmark>> bookmarksOf(Uri url);
  Future<List<Bookmark>> searchBookmarks(String query, {int limit});

  Future<void> recordVisit(Uri url, String title, DateTime at);
  Future<void> updateTitle(Uri url, String title);

  /// Visits, newest first; only those matching [query] when it is not empty.
  Future<List<HistoryVisit>> visits({String query, int limit});
  Future<void> deleteVisit(int id);
  Future<void> clearHistory();

  /// Pages by frecency, best first.
  Future<List<HistoryPage>> frequent(DateTime now, {int limit});
  Future<List<HistoryPage>> searchPages(
    String query,
    DateTime now, {
    int limit,
  });

  Future<List<ReadingItem>> readingItems();
  Future<ReadingItem?> readingItem(Uri url);
  Future<int> addReading(Uri url, String title, DateTime at, {int minutes});
  Future<void> updateReading(
    Uri url, {
    double? readFraction,
    String? offlinePath,
  });
  Future<void> removeReading(int id);

  Future<List<DownloadItem>> downloads();
  Future<void> putDownload(DownloadItem item);
  Future<void> removeDownload(String taskId);
  Future<void> clearDownloads();

  Future<void> addBlocked(String host, int count, DateTime at);
  Future<TrackerReport> trackerReport(DateTime now);

  Future<bool?> permission(String origin, SitePermissionKind kind);
  Future<void> setPermission(
    String origin,
    SitePermissionKind kind,
    bool allowed,
  );
  Future<List<SitePermission>> permissions();
  Future<void> removePermission(String origin, SitePermissionKind kind);
  Future<void> clearPermissions();
}

/// The favourites a new library starts with (the prototype's list, `P:853`,
/// without its made-up sites).
final defaultFavourites = <(String, String)>[
  ('Wikipedia', 'https://de.wikipedia.org/'),
  ('ORF', 'https://orf.at/'),
  ('YouTube', 'https://m.youtube.com/'),
  ('GitHub', 'https://github.com/'),
  ('Karten', 'https://www.google.com/maps'),
  ('Wetter', 'https://www.geosphere.at/'),
  ('Chefkoch', 'https://www.chefkoch.de/'),
  ('Der Standard', 'https://www.derstandard.at/'),
];

/// [Library] in memory.
class MemoryLibrary implements Library {
  MemoryLibrary({bool seed = true}) {
    _folders[1] = const BookmarkFolder(
      id: 1,
      name: 'Favoriten',
      icon: FolderIcon.star,
      tone: FolderTone.primary,
      isFavorites: true,
    );
    _nextFolder = 2;
    if (seed) {
      for (final (title, url) in defaultFavourites) {
        final id = _nextBookmark++;
        _bookmarks[id] = Bookmark(
          id: id,
          folderId: 1,
          url: Uri.parse(url),
          title: title,
          position: id,
          createdAt: DateTime(2026),
        );
      }
    }
  }

  final _changes = StreamController<void>.broadcast();
  final _folders = <int, BookmarkFolder>{};
  final _bookmarks = <int, Bookmark>{};
  final _visits = <int, HistoryVisit>{};
  final _reading = <int, ReadingItem>{};
  final _downloads = <String, DownloadItem>{};
  final _trackers = <(String, String), int>{};
  final _permissions = <(String, SitePermissionKind), bool>{};
  var _nextFolder = 1;
  var _nextBookmark = 1;
  var _nextVisit = 1;
  var _nextReading = 1;

  void _changed() => _changes.add(null);

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<List<BookmarkFolder>> folders() async {
    final list = _folders.values
        .map(
          (f) => BookmarkFolder(
            id: f.id,
            name: f.name,
            icon: f.icon,
            tone: f.tone,
            position: f.position,
            isFavorites: f.isFavorites,
            count: _bookmarks.values.where((b) => b.folderId == f.id).length,
          ),
        )
        .toList();
    list.sort((a, b) {
      if (a.isFavorites != b.isFavorites) return a.isFavorites ? -1 : 1;
      return a.position.compareTo(b.position);
    });
    return list;
  }

  @override
  Future<int> createFolder(
    String name, {
    FolderIcon icon = FolderIcon.folder,
    FolderTone tone = FolderTone.neutral,
  }) async {
    final id = _nextFolder++;
    _folders[id] = BookmarkFolder(
      id: id,
      name: name,
      icon: icon,
      tone: tone,
      position: id,
    );
    _changed();
    return id;
  }

  @override
  Future<void> renameFolder(int id, String name) async {
    final f = _folders[id];
    if (f == null) return;
    _folders[id] = BookmarkFolder(
      id: id,
      name: name,
      icon: f.icon,
      tone: f.tone,
      position: f.position,
      isFavorites: f.isFavorites,
    );
    _changed();
  }

  @override
  Future<void> deleteFolder(int id) async {
    if (_folders[id]?.isFavorites ?? true) return;
    _folders.remove(id);
    _bookmarks.removeWhere((_, b) => b.folderId == id);
    _changed();
  }

  @override
  Future<List<Bookmark>> bookmarksIn(int folderId) async =>
      _bookmarks.values.where((b) => b.folderId == folderId).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

  @override
  Future<List<Bookmark>> favourites() async {
    final fav = _folders.values.firstWhere((f) => f.isFavorites);
    return bookmarksIn(fav.id);
  }

  @override
  Future<int> addBookmark(int folderId, Uri url, String title) async {
    final id = _nextBookmark++;
    _bookmarks[id] = Bookmark(
      id: id,
      folderId: folderId,
      url: url,
      title: title,
      position: id,
      createdAt: DateTime.now(),
    );
    _changed();
    return id;
  }

  @override
  Future<void> removeBookmark(int id) async {
    _bookmarks.remove(id);
    _changed();
  }

  @override
  Future<List<Bookmark>> bookmarksOf(Uri url) async =>
      _bookmarks.values.where((b) => b.url == url).toList();

  @override
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 20}) async {
    final q = query.toLowerCase();
    return _bookmarks.values
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.url.toString().toLowerCase().contains(q),
        )
        .take(limit)
        .toList();
  }

  @override
  Future<void> recordVisit(Uri url, String title, DateTime at) async {
    final id = _nextVisit++;
    _visits[id] = HistoryVisit(id: id, url: url, title: title, visitedAt: at);
    _changed();
  }

  @override
  Future<void> updateTitle(Uri url, String title) async {
    final last = _visits.values
        .where((v) => v.url == url)
        .fold<HistoryVisit?>(
          null,
          (a, b) => a == null || b.visitedAt.isAfter(a.visitedAt) ? b : a,
        );
    if (last == null || last.title == title) return;
    _visits[last.id] = HistoryVisit(
      id: last.id,
      url: url,
      title: title,
      visitedAt: last.visitedAt,
    );
    _changed();
  }

  @override
  Future<List<HistoryVisit>> visits({
    String query = '',
    int limit = 500,
  }) async {
    final q = query.toLowerCase();
    final list =
        _visits.values
            .where(
              (v) =>
                  q.isEmpty ||
                  v.title.toLowerCase().contains(q) ||
                  v.url.toString().toLowerCase().contains(q),
            )
            .toList()
          ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return list.take(limit).toList();
  }

  @override
  Future<void> deleteVisit(int id) async {
    _visits.remove(id);
    _changed();
  }

  @override
  Future<void> clearHistory() async {
    _visits.clear();
    _changed();
  }

  List<HistoryPage> _pages() {
    final byUrl = <Uri, List<HistoryVisit>>{};
    for (final v in _visits.values) {
      byUrl.putIfAbsent(v.url, () => []).add(v);
    }
    return [
      for (final e in byUrl.entries)
        () {
          final last = e.value.reduce(
            (a, b) => a.visitedAt.isAfter(b.visitedAt) ? a : b,
          );
          return HistoryPage(
            url: e.key,
            title: last.title,
            visitCount: e.value.length,
            lastVisitAt: last.visitedAt,
          );
        }(),
    ];
  }

  @override
  Future<List<HistoryPage>> frequent(DateTime now, {int limit = 5}) async =>
      (_pages()..sort((a, b) => b.frecency(now).compareTo(a.frecency(now))))
          .take(limit)
          .toList();

  @override
  Future<List<HistoryPage>> searchPages(
    String query,
    DateTime now, {
    int limit = 5,
  }) async {
    final q = query.toLowerCase();
    return (_pages()
          ..retainWhere(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.url.toString().toLowerCase().contains(q),
          )
          ..sort((a, b) => b.frecency(now).compareTo(a.frecency(now))))
        .take(limit)
        .toList();
  }

  @override
  Future<List<ReadingItem>> readingItems() async =>
      _reading.values.toList()..sort((a, b) => b.addedAt.compareTo(a.addedAt));

  @override
  Future<ReadingItem?> readingItem(Uri url) async =>
      _reading.values.where((r) => r.url == url).firstOrNull;

  @override
  Future<int> addReading(
    Uri url,
    String title,
    DateTime at, {
    int minutes = 0,
  }) async {
    final existing = await readingItem(url);
    if (existing != null) return existing.id;
    final id = _nextReading++;
    _reading[id] = ReadingItem(
      id: id,
      url: url,
      title: title,
      addedAt: at,
      estimatedMinutes: minutes,
    );
    _changed();
    return id;
  }

  @override
  Future<void> updateReading(
    Uri url, {
    double? readFraction,
    String? offlinePath,
  }) async {
    final item = await readingItem(url);
    if (item == null) return;
    _reading[item.id] = ReadingItem(
      id: item.id,
      url: item.url,
      title: item.title,
      addedAt: item.addedAt,
      readFraction: readFraction == null
          ? item.readFraction
          : math.max(item.readFraction, readFraction),
      estimatedMinutes: item.estimatedMinutes,
      offlinePath: offlinePath ?? item.offlinePath,
    );
    _changed();
  }

  @override
  Future<void> removeReading(int id) async {
    _reading.remove(id);
    _changed();
  }

  @override
  Future<List<DownloadItem>> downloads() async =>
      _downloads.values.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  @override
  Future<void> putDownload(DownloadItem item) async {
    _downloads[item.taskId] = item;
    _changed();
  }

  @override
  Future<void> removeDownload(String taskId) async {
    _downloads.remove(taskId);
    _changed();
  }

  @override
  Future<void> clearDownloads() async {
    _downloads.removeWhere((_, d) => !d.active);
    _changed();
  }

  @override
  Future<void> addBlocked(String host, int count, DateTime at) async {
    final key = (dayKey(at), host);
    _trackers[key] = (_trackers[key] ?? 0) + count;
    _changed();
  }

  @override
  Future<TrackerReport> trackerReport(DateTime now) async => reportFrom(
    _trackers.entries.map((e) => (e.key.$1, e.key.$2, e.value)),
    now,
  );

  @override
  Future<bool?> permission(String origin, SitePermissionKind kind) async =>
      _permissions[(origin, kind)];

  @override
  Future<void> setPermission(
    String origin,
    SitePermissionKind kind,
    bool allowed,
  ) async {
    _permissions[(origin, kind)] = allowed;
    _changed();
  }

  @override
  Future<List<SitePermission>> permissions() async => [
    for (final e in _permissions.entries)
      SitePermission(e.key.$1, e.key.$2, allowed: e.value),
  ];

  @override
  Future<void> removePermission(String origin, SitePermissionKind kind) async {
    _permissions.remove((origin, kind));
    _changed();
  }

  @override
  Future<void> clearPermissions() async {
    _permissions.clear();
    _changed();
  }
}

/// The report over rows of (day, host, count): this week is today and the
/// six days before it, last week the seven before those.
TrackerReport reportFrom(Iterable<(String, String, int)> rows, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final thisWeek = {
    for (var i = 0; i < 7; i++) dayKey(today.subtract(Duration(days: i))),
  };
  final lastWeek = {
    for (var i = 7; i < 14; i++) dayKey(today.subtract(Duration(days: i))),
  };
  var week = 0;
  var last = 0;
  final sites = <String>{};
  for (final (day, host, count) in rows) {
    if (thisWeek.contains(day)) {
      week += count;
      sites.add(host);
    } else if (lastWeek.contains(day)) {
      last += count;
    }
  }
  return TrackerReport(week: week, lastWeek: last, sites: sites.length);
}
