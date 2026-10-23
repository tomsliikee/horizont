import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/search_engines.dart';
import 'package:horizont/data/library.dart';
import 'package:horizont/features/search/search_model.dart';

void main() {
  final now = DateTime(2026, 10, 23, 12);

  SearchModel model(
    Library library, {
    bool remote = true,
    List<String> Function(String q)? answers,
    List<String>? asked,
  }) => SearchModel(
    library: library,
    engine: SearchEngine.google,
    remoteAllowed: remote,
    now: () => now,
    fetch: (engine, q) async {
      asked?.add(q);
      return answers?.call(q) ?? const [];
    },
  );

  test('an address is the top hit', () async {
    final m = model(MemoryLibrary(seed: false));
    await m.update('orf.at');
    expect(m.value.topHit, isA<AddressSuggestion>());
    expect(
      m.value.topHit!.uri(SearchEngine.google),
      Uri.parse('https://orf.at'),
    );
  });

  test('a page whose title starts with the text is the top hit', () async {
    final library = MemoryLibrary(seed: false);
    await library.recordVisit(
      Uri.parse('https://bergzeit.example/herbst'),
      'Herbst am Schafberg',
      now,
    );
    final m = model(library, remote: false);
    await m.update('schaf');
    expect(m.value.topHit, isA<HistorySuggestion>());
    await m.update('afberg');
    // Inside a word is a match, but not a top hit.
    expect(m.value.topHit, isNull);
    expect(m.value.local, hasLength(1));
  });

  test('bookmarks and the reading list are found too', () async {
    final library = MemoryLibrary();
    await library.addReading(
      Uri.parse('https://m3.example/expressive'),
      'Material Expressive',
      now,
    );
    final m = model(library, remote: false);
    await m.update('wiki');
    expect(m.value.topHit, isA<BookmarkSuggestion>());
    await m.update('expressive');
    expect(m.value.topHit, isA<ReadingSuggestion>());
  });

  test(
    'the engine is asked once typing pauses, and late answers are dropped',
    () async {
      final asked = <String>[];
      final m = model(
        MemoryLibrary(seed: false),
        asked: asked,
        answers: (q) => ['$q wetter', '$q museum'],
      );
      await m.update('w');
      await m.update('wi');
      await m.update('wie');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(asked, ['wie']);
      expect(m.value.remote.map((s) => s.query), ['wie wetter', 'wie museum']);
    },
  );

  test('private mode and the setting off ask no engine', () async {
    final asked = <String>[];
    final m = model(MemoryLibrary(seed: false), remote: false, asked: asked);
    await m.update('wien');
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(asked, isEmpty);
  });
}
