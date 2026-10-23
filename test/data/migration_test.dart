import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/data/db/app_database.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/data/repositories/drift_library.dart';

void main() {
  test('a schema 1 database gains the library and keeps its tabs', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          // The tabs table as milestone 4 created it.
          raw.execute('''
            CREATE TABLE tabs (
              id TEXT NOT NULL PRIMARY KEY,
              url TEXT NULL,
              title TEXT NOT NULL DEFAULT '',
              page_color INTEGER NULL,
              opener_id TEXT NULL REFERENCES tabs (id) ON DELETE SET NULL,
              group_id TEXT NULL,
              group_name TEXT NULL,
              position INTEGER NOT NULL,
              created_at INTEGER NOT NULL,
              last_active_at INTEGER NOT NULL,
              scroll_y REAL NULL,
              thumbnail_path TEXT NULL
            )''');
          raw.execute(
            "INSERT INTO tabs (id, url, position, created_at, last_active_at) "
            "VALUES ('t1', 'https://a.example/', 0, 0, 0)",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);
    final tabs = await DriftTabsRepository(db).loadAll();
    expect(tabs.single.url, Uri.parse('https://a.example/'));
    final library = DriftLibrary(db);
    expect((await library.favourites()).length, defaultFavourites.length);
    await library.recordVisit(
      Uri.parse('https://a.example/'),
      'A',
      DateTime(2026),
    );
    expect((await library.visits()).single.title, 'A');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 2);
  });
}
