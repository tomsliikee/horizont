import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/tabs/browser_tab.dart';
import 'package:horizont/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late DriftTabsRepository repository;
  final t0 = DateTime(2026, 10, 23, 12);

  BrowserTab tab(String id, {int position = 0, String? opener, DateTime? at}) =>
      BrowserTab(
        id: id,
        position: position,
        createdAt: at ?? t0,
        lastActiveAt: at ?? t0,
        openerId: opener,
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftTabsRepository(db);
  });
  tearDown(() => db.close());

  test('foreign keys are on', () async {
    final rows = await db.customSelect('PRAGMA foreign_keys').get();
    expect(rows.single.data.values.single, 1);
  });

  test('a tab survives the round trip with every field', () async {
    final full = BrowserTab(
      id: 'a',
      url: Uri.parse('https://example.com/x?y=1'),
      title: 'Example',
      pageColor: const Color(0xFF1F3A2D),
      groupId: 'g',
      groupName: 'Gruppe',
      position: 3,
      createdAt: t0,
      lastActiveAt: t0.add(const Duration(hours: 1)),
      scrollY: 812.5,
      thumbnailPath: '/thumbs/a.webp',
    );
    await repository.upsert(full);
    expect(await repository.loadAll(), [full]);
  });

  test('upsert replaces, loadAll orders by position', () async {
    await repository.upsertAll([tab('b', position: 1), tab('a')]);
    await repository.upsert(tab('b', position: 1).copyWith(title: 'B'));
    final all = await repository.loadAll();
    expect(all.map((t) => t.id), ['a', 'b']);
    expect(all.last.title, 'B');
  });

  test('deleting the opener clears it on the tabs it opened', () async {
    await repository.upsertAll([tab('a'), tab('b', position: 1, opener: 'a')]);
    await repository.delete('a');
    final all = await repository.loadAll();
    expect(all.map((t) => t.id), ['b']);
    expect(all.single.openerId, isNull);
  });

  test(
    'a batch with an opener and its child in any order is accepted',
    () async {
      final later = t0.add(const Duration(minutes: 1));
      await repository.upsertAll([
        tab('child', position: 1, opener: 'a', at: later),
        tab('a'),
      ]);
      expect((await repository.loadAll()).last.openerId, 'a');
    },
  );
}
