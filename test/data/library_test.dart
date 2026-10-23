import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/web_engine.dart' show SitePermissionKind;
import 'package:horizont/data/db/app_database.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/data/repositories/drift_library.dart';

/// The same behaviour is asked of the database and of the memory library.
void main() {
  final now = DateTime(2026, 10, 23, 12);
  final kinds = <String, Library Function()>{
    'memory': MemoryLibrary.new,
    'database': () => DriftLibrary(AppDatabase(NativeDatabase.memory())),
  };

  for (final MapEntry(key: name, value: make) in kinds.entries) {
    group(name, () {
      late Library l;
      setUp(() => l = make());

      test('starts with the favourites folder and its favourites', () async {
        final folders = await l.folders();
        expect(folders.first.isFavorites, isTrue);
        expect(folders.first.count, defaultFavourites.length);
        expect((await l.favourites()).first.title, 'Wikipedia');
      });

      test('a deleted folder takes its bookmarks; favourites stay', () async {
        final id = await l.createFolder('Reisen');
        await l.addBookmark(id, Uri.parse('https://a.example/'), 'A');
        expect(
          (await l.bookmarksOf(Uri.parse('https://a.example/'))).length,
          1,
        );
        await l.deleteFolder(id);
        expect(await l.bookmarksOf(Uri.parse('https://a.example/')), isEmpty);
        final fav = (await l.folders()).first;
        await l.deleteFolder(fav.id);
        expect((await l.folders()).first.isFavorites, isTrue);
      });

      test('frecency puts often and recently visited pages first', () async {
        final a = Uri.parse('https://a.example/');
        final b = Uri.parse('https://b.example/');
        final old = now.subtract(const Duration(days: 60));
        for (var i = 0; i < 3; i++) {
          await l.recordVisit(a, 'A', old);
        }
        await l.recordVisit(b, 'B', now);
        await l.recordVisit(b, 'B', now);
        final pages = await l.frequent(now);
        // 2 visits × 100 beat 3 visits × 30.
        expect(pages.map((p) => p.url), [b, a]);
        expect(pages.first.visitCount, 2);
      });

      test('visits are newest first, searchable, and can be cleared', () async {
        await l.recordVisit(Uri.parse('https://a.example/'), 'Wien', now);
        await l.recordVisit(
          Uri.parse('https://b.example/'),
          'Graz',
          now.add(const Duration(minutes: 1)),
        );
        expect((await l.visits()).map((v) => v.title), ['Graz', 'Wien']);
        expect((await l.visits(query: 'wie')).single.title, 'Wien');
        await l.updateTitle(Uri.parse('https://a.example/'), 'Wien – Stadt');
        expect((await l.visits(query: 'stadt')).single.title, 'Wien – Stadt');
        await l.clearHistory();
        expect(await l.visits(), isEmpty);
        expect(await l.frequent(now), isEmpty);
      });

      test('reading progress only goes forward', () async {
        final url = Uri.parse('https://a.example/article');
        await l.addReading(url, 'A', now, minutes: 8);
        await l.addReading(url, 'A again', now);
        expect((await l.readingItems()).length, 1);
        await l.updateReading(url, readFraction: 0.6);
        await l.updateReading(url, readFraction: 0.2, offlinePath: '/x.mht');
        final item = (await l.readingItem(url))!;
        expect(item.readFraction, 0.6);
        expect(item.offlinePath, '/x.mht');
        expect(item.state, ReadingState.half);
        expect(item.estimatedMinutes, 8);
      });

      test('clearing the download list keeps what still runs', () async {
        DownloadItem d(String id, DownloadStatus s) => DownloadItem(
          taskId: id,
          url: Uri.parse('https://a.example/$id'),
          fileName: '$id.pdf',
          status: s,
          startedAt: now,
        );
        await l.putDownload(d('a', DownloadStatus.done));
        await l.putDownload(d('b', DownloadStatus.running));
        await l.putDownload(d('c', DownloadStatus.failed));
        await l.clearDownloads();
        expect((await l.downloads()).map((x) => x.taskId), ['b']);
      });

      test(
        'the tracker report compares this week with the one before',
        () async {
          await l.addBlocked('a.example', 5, now);
          await l.addBlocked('a.example', 2, now);
          await l.addBlocked(
            'b.example',
            1,
            now.subtract(const Duration(days: 6)),
          );
          await l.addBlocked(
            'c.example',
            4,
            now.subtract(const Duration(days: 8)),
          );
          await l.addBlocked(
            'd.example',
            9,
            now.subtract(const Duration(days: 20)),
          );
          final r = await l.trackerReport(now);
          expect(r.week, 8);
          expect(r.sites, 2);
          expect(r.lastWeek, 4);
          expect(r.change, 4);
        },
      );

      test('site permissions are kept per origin and kind', () async {
        const o = 'https://meet.example';
        expect(await l.permission(o, SitePermissionKind.camera), isNull);
        await l.setPermission(o, SitePermissionKind.camera, true);
        await l.setPermission(o, SitePermissionKind.location, false);
        expect(await l.permission(o, SitePermissionKind.camera), isTrue);
        expect(await l.permission(o, SitePermissionKind.location), isFalse);
        expect((await l.permissions()).length, 2);
        await l.clearPermissions();
        expect(await l.permissions(), isEmpty);
      });

      test('writes are announced', () async {
        var changes = 0;
        final sub = l.changes.listen((_) => changes++);
        await l.recordVisit(Uri.parse('https://a.example/'), 'A', now);
        await Future<void>.delayed(Duration.zero);
        expect(changes, greaterThan(0));
        await sub.cancel();
      });
    });
  }

  test('the report counts days by local date across midnight', () {
    final late = DateTime(2026, 10, 23, 23, 59);
    final early = DateTime(2026, 10, 24, 0, 1);
    expect(dayKey(late), '2026-10-23');
    expect(dayKey(early), '2026-10-24');
    final r = reportFrom([
      ('2026-10-17', 'a', 1),
      ('2026-10-16', 'a', 2),
    ], early);
    // Today is the 24th: the 18th to the 24th are this week.
    expect(r.week, 0);
    expect(r.lastWeek, 3);
  });
}
