import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../browser/tabs/browser_tab.dart';
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

@DriftDatabase(tables: [Tabs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The database file in the app's private storage, on its own isolate.
  AppDatabase.open() : super(driftDatabase(name: 'horizont'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // One step per schema version goes here; each gets a test.
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
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
