import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../browser/tabs/browser_tab.dart';
import '../library.dart' show defaultFavourites;
import '../repositories/tabs_repository.dart';

part 'app_database.g.dart';

/// Normal tabs (PLAN 1.5). `opener_id` is set null when the opener goes.
class Tabs extends Table {
  TextColumn get id => text()();
  TextColumn get url => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get pageColor => integer().nullable()();
  TextColumn get openerId =>
      text().nullable().references(Tabs, #id, onDelete: KeyAction.setNull)();
  TextColumn get groupId => text().nullable()();
  TextColumn get groupName => text().nullable()();
  IntColumn get position => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastActiveAt => dateTime()();
  RealColumn get scrollY => real().nullable()();
  TextColumn get thumbnailPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FolderRow')
class BookmarkFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  TextColumn get tone => text().withDefault(const Constant('neutral'))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorites => boolean().withDefault(const Constant(false))();
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().references(BookmarkFolders, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// One row per page load (not in private mode).
@DataClassName('VisitRow')
class Visits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get visitedAt => dateTime()();
}

/// One row per address: counts for frecency (PLAN 1.5).
@DataClassName('PageRow')
class Pages extends Table {
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get visitCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastVisitAt => dateTime()();

  @override
  Set<Column> get primaryKey => {url};
}

@DataClassName('ReadingRow')
class ReadingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text().unique()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get addedAt => dateTime()();
  RealColumn get readFraction => real().withDefault(const Constant(0))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(0))();
  TextColumn get offlinePath => text().nullable()();
}

@DataClassName('DownloadRow')
class Downloads extends Table {
  TextColumn get taskId => text()();
  TextColumn get url => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text().withDefault(const Constant(''))();
  IntColumn get totalBytes => integer().nullable()();
  IntColumn get receivedBytes => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get savedUri => text().nullable()();

  @override
  Set<Column> get primaryKey => {taskId};
}

/// Trackers blocked per local day and page host.
@DataClassName('TrackerDayRow')
class TrackerDays extends Table {
  TextColumn get day => text()();
  TextColumn get host => text()();
  IntColumn get blockedCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day, host};
}

@DataClassName('PermissionRow')
class SitePermissions extends Table {
  TextColumn get origin => text()();
  TextColumn get kind => text()();
  BoolColumn get allowed => boolean()();

  @override
  Set<Column> get primaryKey => {origin, kind};
}

@DriftDatabase(
  tables: [
    Tabs,
    BookmarkFolders,
    Bookmarks,
    Visits,
    Pages,
    ReadingItems,
    Downloads,
    TrackerDays,
    SitePermissions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The database file in the app's private storage, on its own isolate.
  AppDatabase.open() : super(driftDatabase(name: 'horizont'));

  /// 1: tabs (M4). 2: library, downloads, trackers, permissions (M6).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedFavourites();
    },
    // One step per schema version; each gets a test.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(bookmarkFolders);
        await m.createTable(bookmarks);
        await m.createTable(visits);
        await m.createTable(pages);
        await m.createTable(readingItems);
        await m.createTable(downloads);
        await m.createTable(trackerDays);
        await m.createTable(sitePermissions);
        await m.createIndex(
          Index('visits_at', 'CREATE INDEX visits_at ON visits (visited_at)'),
        );
        await _seedFavourites();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await customStatement(
          'CREATE INDEX IF NOT EXISTS visits_at ON visits (visited_at)',
        );
      }
    },
  );

  /// The favourites folder with the default favourites.
  Future<void> _seedFavourites() async {
    final folder = await into(bookmarkFolders).insert(
      BookmarkFoldersCompanion.insert(
        name: 'Favoriten',
        icon: const Value('star'),
        tone: const Value('primary'),
        isFavorites: const Value(true),
      ),
    );
    var i = 0;
    for (final (title, url) in defaultFavourites) {
      await into(bookmarks).insert(
        BookmarksCompanion.insert(
          folderId: folder,
          url: url,
          title: Value(title),
          position: Value(i++),
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

class DriftTabsRepository implements TabsRepository {
  DriftTabsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<BrowserTab>> loadAll() async {
    final rows = await (_db.select(
      _db.tabs,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> upsert(BrowserTab tab) =>
      _db.into(_db.tabs).insertOnConflictUpdate(_toCompanion(tab));

  @override
  Future<void> upsertAll(List<BrowserTab> tabs) => _db.batch((batch) {
    // Openers first, so the foreign key finds them.
    final ordered = [...tabs]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    batch.insertAllOnConflictUpdate(_db.tabs, ordered.map(_toCompanion));
  });

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.tabs)..where((t) => t.id.equals(id))).go();

  static BrowserTab _fromRow(Tab row) => BrowserTab(
    id: row.id,
    url: row.url == null ? null : Uri.tryParse(row.url!),
    title: row.title,
    pageColor: row.pageColor == null ? null : Color(row.pageColor!),
    openerId: row.openerId,
    groupId: row.groupId,
    groupName: row.groupName,
    position: row.position,
    createdAt: row.createdAt,
    lastActiveAt: row.lastActiveAt,
    scrollY: row.scrollY,
    thumbnailPath: row.thumbnailPath,
  );

  static TabsCompanion _toCompanion(BrowserTab tab) => TabsCompanion(
    id: Value(tab.id),
    url: Value(tab.url?.toString()),
    title: Value(tab.title),
    pageColor: Value(tab.pageColor?.toARGB32()),
    openerId: Value(tab.openerId),
    groupId: Value(tab.groupId),
    groupName: Value(tab.groupName),
    position: Value(tab.position),
    createdAt: Value(tab.createdAt),
    lastActiveAt: Value(tab.lastActiveAt),
    scrollY: Value(tab.scrollY),
    thumbnailPath: Value(tab.thumbnailPath),
  );
}
