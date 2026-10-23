import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../browser/tabs/tabs_notifier.dart';
import 'library.dart';

/// Overridden in `main` with the database; tests use [MemoryLibrary].
final libraryProvider = Provider<Library>(
  (ref) => throw UnimplementedError('libraryProvider not overridden'),
);

/// Counts writes to the library, so the lists below read again after one.
final libraryRevisionProvider = NotifierProvider<_Revision, int>(_Revision.new);

class _Revision extends Notifier<int> {
  @override
  int build() {
    final sub = ref.watch(libraryProvider).changes.listen((_) => state++);
    ref.onDispose(sub.cancel);
    return 0;
  }
}

FutureProvider<T> _read<T>(Future<T> Function(Library library, Ref ref) read) =>
    FutureProvider<T>((ref) {
      ref.watch(libraryRevisionProvider);
      return read(ref.watch(libraryProvider), ref);
    });

final favouritesProvider = _read((l, ref) => l.favourites());

final frequentProvider = _read(
  (l, ref) => l.frequent(ref.read(clockProvider)(), limit: 3),
);

final readingListProvider = _read((l, ref) => l.readingItems());

final foldersProvider = _read((l, ref) => l.folders());

final downloadsProvider = _read((l, ref) => l.downloads());

final trackerReportProvider = _read(
  (l, ref) => l.trackerReport(ref.read(clockProvider)()),
);

final sitePermissionsProvider = _read((l, ref) => l.permissions());

final bookmarksInProvider = FutureProvider.family<List<Bookmark>, int>((
  ref,
  folderId,
) {
  ref.watch(libraryRevisionProvider);
  return ref.watch(libraryProvider).bookmarksIn(folderId);
});

/// History, newest first, filtered by the library's search field.
final historyProvider = FutureProvider.family<List<HistoryVisit>, String>((
  ref,
  query,
) {
  ref.watch(libraryRevisionProvider);
  return ref.watch(libraryProvider).visits(query: query, limit: 400);
});

/// Whether [url] is bookmarked anywhere, for the menu's "Merken" tile.
final isBookmarkedProvider = FutureProvider.family<bool, Uri>((ref, url) async {
  ref.watch(libraryRevisionProvider);
  return (await ref.watch(libraryProvider).bookmarksOf(url)).isNotEmpty;
});

final isInReadingListProvider = FutureProvider.family<bool, Uri>((
  ref,
  url,
) async {
  ref.watch(libraryRevisionProvider);
  return await ref.watch(libraryProvider).readingItem(url) != null;
});
