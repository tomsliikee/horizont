import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../browser/web_engine.dart' show SitePermissionKind;
import '../db/app_database.dart';
import '../library.dart';

/// [Library] in the app database.
class DriftLibrary implements Library {
  DriftLibrary(this._db);

  final AppDatabase _db;
  final _changes = StreamController<void>.broadcast();

  void _changed() => _changes.add(null);

  @override
  Stream<void> get changes => _changes.stream;

  static BookmarkFolder _folder(FolderRow r, [int count = 0]) => BookmarkFolder(
    id: r.id,
    name: r.name,
    icon: FolderIcon.values.asNameMap()[r.icon] ?? FolderIcon.folder,
    tone: FolderTone.values.asNameMap()[r.tone] ?? FolderTone.neutral,
    position: r.position,
    isFavorites: r.isFavorites,
    count: count,
  );

  static Bookmark _bookmark(BookmarkRow r) => Bookmark(
    id: r.id,
    folderId: r.folderId,
    url: Uri.parse(r.url),
    title: r.title,
    position: r.position,
    createdAt: r.createdAt,
  );

  @override
  Future<List<BookmarkFolder>> folders() async {
    final count = _db.bookmarks.id.count();
    final query =
        _db.select(_db.bookmarkFolders).join([
            leftOuterJoin(
              _db.bookmarks,
              _db.bookmarks.folderId.equalsExp(_db.bookmarkFolders.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.bookmarkFolders.id])
          ..orderBy([
            OrderingTerm.desc(_db.bookmarkFolders.isFavorites),
            OrderingTerm.asc(_db.bookmarkFolders.position),
            OrderingTerm.asc(_db.bookmarkFolders.id),
          ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        _folder(row.readTable(_db.bookmarkFolders), row.read(count) ?? 0),
    ];
  }

  @override
  Future<int> createFolder(
    String name, {
    FolderIcon icon = FolderIcon.folder,
    FolderTone tone = FolderTone.neutral,
  }) async {
    final max = _db.bookmarkFolders.position.max();
    final top = await (_db.selectOnly(
      _db.bookmarkFolders,
    )..addColumns([max])).map((r) => r.read(max)).getSingle();
    final id = await _db
        .into(_db.bookmarkFolders)
        .insert(
          BookmarkFoldersCompanion.insert(
            name: name,
            icon: Value(icon.name),
            tone: Value(tone.name),
            position: Value((top ?? 0) + 1),
          ),
        );
    _changed();
    return id;
  }

  @override
  Future<void> renameFolder(int id, String name) async {
    await (_db.update(_db.bookmarkFolders)..where((f) => f.id.equals(id)))
        .write(BookmarkFoldersCompanion(name: Value(name)));
    _changed();
  }

  @override
  Future<void> deleteFolder(int id) async {
    await (_db.delete(
      _db.bookmarkFolders,
    )..where((f) => f.id.equals(id) & f.isFavorites.equals(false))).go();
    _changed();
  }

  @override
  Future<List<Bookmark>> bookmarksIn(int folderId) async {
    final rows =
        await (_db.select(_db.bookmarks)
              ..where((b) => b.folderId.equals(folderId))
              ..orderBy([
                (b) => OrderingTerm.asc(b.position),
                (b) => OrderingTerm.asc(b.id),
              ]))
            .get();
    return rows.map(_bookmark).toList();
  }

  @override
  Future<List<Bookmark>> favourites() async {
    final fav = await (_db.select(
      _db.bookmarkFolders,
    )..where((f) => f.isFavorites.equals(true))).getSingleOrNull();
    return fav == null ? const [] : bookmarksIn(fav.id);
  }

  @override
  Future<int> addBookmark(int folderId, Uri url, String title) async {
    final max = _db.bookmarks.position.max();
    final top =
        await (_db.selectOnly(_db.bookmarks)
              ..addColumns([max])
              ..where(_db.bookmarks.folderId.equals(folderId)))
            .map((r) => r.read(max))
            .getSingle();
    final id = await _db
        .into(_db.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            folderId: folderId,
            url: url.toString(),
            title: Value(title),
            position: Value((top ?? 0) + 1),
            createdAt: DateTime.now(),
          ),
        );
    _changed();
    return id;
  }

  @override
  Future<void> removeBookmark(int id) async {
    await (_db.delete(_db.bookmarks)..where((b) => b.id.equals(id))).go();
    _changed();
  }

  @override
  Future<List<Bookmark>> bookmarksOf(Uri url) async {
    final rows = await (_db.select(
      _db.bookmarks,
    )..where((b) => b.url.equals(url.toString()))).get();
    return rows.map(_bookmark).toList();
  }

  @override
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 20}) async {
    final like = '%${_escape(query)}%';
    final rows =
        await (_db.select(_db.bookmarks)
              ..where(
                (b) =>
                    b.title.like(like, escapeChar: r'\') |
                    b.url.like(like, escapeChar: r'\'),
              )
              ..limit(limit))
            .get();
    return rows.map(_bookmark).toList();
  }

  static String _escape(String q) =>
      q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  @override
  Future<void> recordVisit(Uri url, String title, DateTime at) async {
    final key = url.toString();
    await _db.transaction(() async {
      await _db
          .into(_db.visits)
          .insert(
            VisitsCompanion.insert(
              url: key,
              title: Value(title),
              visitedAt: at,
            ),
          );
      final existing = await (_db.select(
        _db.pages,
      )..where((p) => p.url.equals(key))).getSingleOrNull();
      await _db
          .into(_db.pages)
          .insertOnConflictUpdate(
            PagesCompanion.insert(
              url: key,
              title: Value(title.isEmpty ? existing?.title ?? '' : title),
              visitCount: Value((existing?.visitCount ?? 0) + 1),
              lastVisitAt: at,
            ),
          );
    });
    _changed();
  }

  @override
  Future<void> updateTitle(Uri url, String title) async {
    if (title.isEmpty) return;
    final key = url.toString();
    final last =
        await (_db.select(_db.visits)
              ..where((v) => v.url.equals(key))
              ..orderBy([(v) => OrderingTerm.desc(v.visitedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (last == null || last.title == title) return;
    await (_db.update(_db.visits)..where((v) => v.id.equals(last.id))).write(
      VisitsCompanion(title: Value(title)),
    );
    await (_db.update(_db.pages)..where((p) => p.url.equals(key))).write(
      PagesCompanion(title: Value(title)),
    );
    _changed();
  }

  @override
  Future<List<HistoryVisit>> visits({
    String query = '',
    int limit = 500,
  }) async {
    final select = _db.select(_db.visits)
      ..orderBy([(v) => OrderingTerm.desc(v.visitedAt)])
      ..limit(limit);
    if (query.isNotEmpty) {
      final like = '%${_escape(query)}%';
      select.where(
        (v) =>
            v.title.like(like, escapeChar: r'\') |
            v.url.like(like, escapeChar: r'\'),
      );
    }
    final rows = await select.get();
    return [
      for (final r in rows)
        HistoryVisit(
          id: r.id,
          url: Uri.parse(r.url),
          title: r.title,
          visitedAt: r.visitedAt,
        ),
    ];
  }

  @override
  Future<void> deleteVisit(int id) async {
    await _db.transaction(() async {
      final visit = await (_db.select(
        _db.visits,
      )..where((v) => v.id.equals(id))).getSingleOrNull();
      if (visit == null) return;
      await (_db.delete(_db.visits)..where((v) => v.id.equals(id))).go();
      final page = await (_db.select(
        _db.pages,
      )..where((p) => p.url.equals(visit.url))).getSingleOrNull();
      if (page == null) return;
      if (page.visitCount <= 1) {
        await (_db.delete(
          _db.pages,
        )..where((p) => p.url.equals(visit.url))).go();
      } else {
        await (_db.update(_db.pages)..where((p) => p.url.equals(visit.url)))
            .write(PagesCompanion(visitCount: Value(page.visitCount - 1)));
      }
    });
    _changed();
  }

  @override
  Future<void> clearHistory() async {
    await _db.transaction(() async {
      await _db.delete(_db.visits).go();
      await _db.delete(_db.pages).go();
    });
    _changed();
  }

  HistoryPage _page(PageRow r) => HistoryPage(
    url: Uri.parse(r.url),
    title: r.title,
    visitCount: r.visitCount,
    lastVisitAt: r.lastVisitAt,
  );

  /// The candidates are the 200 most recent pages; frecency sorts them.
  @override
  Future<List<HistoryPage>> frequent(DateTime now, {int limit = 5}) async {
    final rows =
        await (_db.select(_db.pages)
              ..orderBy([(p) => OrderingTerm.desc(p.lastVisitAt)])
              ..limit(200))
            .get();
    final pages = rows.map(_page).toList()
      ..sort((a, b) => b.frecency(now).compareTo(a.frecency(now)));
    return pages.take(limit).toList();
  }

  @override
  Future<List<HistoryPage>> searchPages(
    String query,
    DateTime now, {
    int limit = 5,
  }) async {
    final like = '%${_escape(query)}%';
    final rows =
        await (_db.select(_db.pages)
              ..where(
                (p) =>
                    p.title.like(like, escapeChar: r'\') |
                    p.url.like(like, escapeChar: r'\'),
              )
              ..orderBy([(p) => OrderingTerm.desc(p.lastVisitAt)])
              ..limit(100))
            .get();
    final pages = rows.map(_page).toList()
      ..sort((a, b) => b.frecency(now).compareTo(a.frecency(now)));
    return pages.take(limit).toList();
  }

  ReadingItem _reading(ReadingRow r) => ReadingItem(
    id: r.id,
    url: Uri.parse(r.url),
    title: r.title,
    addedAt: r.addedAt,
    readFraction: r.readFraction,
    estimatedMinutes: r.estimatedMinutes,
    offlinePath: r.offlinePath,
  );

  @override
  Future<List<ReadingItem>> readingItems() async {
    final rows = await (_db.select(
      _db.readingItems,
    )..orderBy([(r) => OrderingTerm.desc(r.addedAt)])).get();
    return rows.map(_reading).toList();
  }

  @override
  Future<ReadingItem?> readingItem(Uri url) async {
    final row = await (_db.select(
      _db.readingItems,
    )..where((r) => r.url.equals(url.toString()))).getSingleOrNull();
    return row == null ? null : _reading(row);
  }

  @override
  Future<int> addReading(
    Uri url,
    String title,
    DateTime at, {
    int minutes = 0,
  }) async {
    final existing = await readingItem(url);
    if (existing != null) return existing.id;
    final id = await _db
        .into(_db.readingItems)
        .insert(
          ReadingItemsCompanion.insert(
            url: url.toString(),
            title: Value(title),
            addedAt: at,
            estimatedMinutes: Value(minutes),
          ),
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
    await (_db.update(
      _db.readingItems,
    )..where((r) => r.id.equals(item.id))).write(
      ReadingItemsCompanion(
        readFraction: readFraction == null
            ? const Value.absent()
            : Value(math.max(item.readFraction, readFraction)),
        offlinePath: offlinePath == null
            ? const Value.absent()
            : Value(offlinePath),
      ),
    );
    _changed();
  }

  @override
  Future<void> removeReading(int id) async {
    await (_db.delete(_db.readingItems)..where((r) => r.id.equals(id))).go();
    _changed();
  }

  @override
  Future<List<DownloadItem>> downloads() async {
    final rows = await (_db.select(
      _db.downloads,
    )..orderBy([(d) => OrderingTerm.desc(d.startedAt)])).get();
    return [
      for (final r in rows)
        DownloadItem(
          taskId: r.taskId,
          url: Uri.parse(r.url),
          fileName: r.fileName,
          mimeType: r.mimeType,
          totalBytes: r.totalBytes,
          receivedBytes: r.receivedBytes,
          status:
              DownloadStatus.values.asNameMap()[r.status] ??
              DownloadStatus.failed,
          startedAt: r.startedAt,
          finishedAt: r.finishedAt,
          savedUri: r.savedUri,
        ),
    ];
  }

  @override
  Future<void> putDownload(DownloadItem item) async {
    await _db
        .into(_db.downloads)
        .insertOnConflictUpdate(
          DownloadsCompanion.insert(
            taskId: item.taskId,
            url: item.url.toString(),
            fileName: item.fileName,
            mimeType: Value(item.mimeType),
            totalBytes: Value(item.totalBytes),
            receivedBytes: Value(item.receivedBytes),
            status: item.status.name,
            startedAt: item.startedAt,
            finishedAt: Value(item.finishedAt),
            savedUri: Value(item.savedUri),
          ),
        );
    _changed();
  }

  @override
  Future<void> removeDownload(String taskId) async {
    await (_db.delete(
      _db.downloads,
    )..where((d) => d.taskId.equals(taskId))).go();
    _changed();
  }

  @override
  Future<void> clearDownloads() async {
    await (_db.delete(_db.downloads)..where(
          (d) => d.status.isIn([
            DownloadStatus.done.name,
            DownloadStatus.failed.name,
            DownloadStatus.canceled.name,
          ]),
        ))
        .go();
    _changed();
  }

  @override
  Future<void> addBlocked(String host, int count, DateTime at) async {
    await _db.customInsert(
      'INSERT INTO tracker_days (day, host, blocked_count) VALUES (?, ?, ?) '
      'ON CONFLICT(day, host) DO UPDATE SET blocked_count = blocked_count + excluded.blocked_count',
      variables: [
        Variable.withString(dayKey(at)),
        Variable.withString(host),
        Variable.withInt(count),
      ],
      updates: {_db.trackerDays},
    );
    _changed();
  }

  @override
  Future<TrackerReport> trackerReport(DateTime now) async {
    final since = dayKey(now.subtract(const Duration(days: 14)));
    final rows = await (_db.select(
      _db.trackerDays,
    )..where((t) => t.day.isBiggerThanValue(since))).get();
    return reportFrom(rows.map((r) => (r.day, r.host, r.blockedCount)), now);
  }

  @override
  Future<bool?> permission(String origin, SitePermissionKind kind) async {
    final row =
        await (_db.select(
              _db.sitePermissions,
            )..where((p) => p.origin.equals(origin) & p.kind.equals(kind.name)))
            .getSingleOrNull();
    return row?.allowed;
  }

  @override
  Future<void> setPermission(
    String origin,
    SitePermissionKind kind,
    bool allowed,
  ) async {
    await _db
        .into(_db.sitePermissions)
        .insertOnConflictUpdate(
          SitePermissionsCompanion.insert(
            origin: origin,
            kind: kind.name,
            allowed: allowed,
          ),
        );
    _changed();
  }

  @override
  Future<List<SitePermission>> permissions() async {
    final rows = await (_db.select(
      _db.sitePermissions,
    )..orderBy([(p) => OrderingTerm.asc(p.origin)])).get();
    return [
      for (final r in rows)
        if (SitePermissionKind.values.asNameMap()[r.kind] case final kind?)
          SitePermission(r.origin, kind, allowed: r.allowed),
    ];
  }

  @override
  Future<void> removePermission(String origin, SitePermissionKind kind) async {
    await (_db.delete(
      _db.sitePermissions,
    )..where((p) => p.origin.equals(origin) & p.kind.equals(kind.name))).go();
    _changed();
  }

  @override
  Future<void> clearPermissions() async {
    await _db.delete(_db.sitePermissions).go();
    _changed();
  }
}
