import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../browser/address.dart';
import '../../browser/search_engines.dart';
import '../../data/library.dart';

/// What a row of the search screen opens.
sealed class SearchSuggestion {
  const SearchSuggestion();

  /// The address it opens with [engine].
  Uri uri(SearchEngine engine);
}

/// Typed text that is an address.
class AddressSuggestion extends SearchSuggestion {
  const AddressSuggestion(this.address);
  final Uri address;

  @override
  Uri uri(SearchEngine engine) => address;
}

/// A search with the engine.
class QuerySuggestion extends SearchSuggestion {
  const QuerySuggestion(this.query);
  final String query;

  @override
  Uri uri(SearchEngine engine) => engine.searchUri(query);
}

class HistorySuggestion extends SearchSuggestion {
  const HistorySuggestion(this.page);
  final HistoryPage page;

  @override
  Uri uri(SearchEngine engine) => page.url;
}

class BookmarkSuggestion extends SearchSuggestion {
  const BookmarkSuggestion(this.bookmark, this.folder);
  final Bookmark bookmark;
  final String folder;

  @override
  Uri uri(SearchEngine engine) => bookmark.url;
}

class ReadingSuggestion extends SearchSuggestion {
  const ReadingSuggestion(this.item);
  final ReadingItem item;

  @override
  Uri uri(SearchEngine engine) => item.url;
}

/// Everything the search screen shows for one input.
@immutable
class SearchResults {
  const SearchResults({
    this.input = '',
    this.topHit,
    this.local = const [],
    this.remote = const [],
  });
  final String input;
  final SearchSuggestion? topHit;

  /// From history, bookmarks and the reading list (PLAN 4.2: local first).
  final List<SearchSuggestion> local;

  /// From the engine.
  final List<QuerySuggestion> remote;
}

/// Asks an engine for suggestions over `dart:io` (PLAN 4.2). Replaced in
/// tests with recorded answers.
typedef SuggestionFetcher = Future<List<String>> Function(
  SearchEngine engine,
  String query,
);

Future<List<String>> fetchSuggestions(SearchEngine engine, String query) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 2)
    ..userAgent = 'Horizont';
  try {
    final request = await client.getUrl(engine.suggestUri(query));
    final response = await request.close().timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) return const [];
    // Engines answer in UTF-8 or Latin-1; malformed bytes are tolerated.
    final body = await response
        .transform(const Utf8Decoder(allowMalformed: true))
        .join()
        .timeout(const Duration(seconds: 3));
    return parseSuggestions(body);
  } on Object {
    return const [];
  } finally {
    client.close(force: true);
  }
}

/// Turns typing into [SearchResults]: local matches within the same frame's
/// work, engine suggestions 150 ms after the last keystroke, a request that
/// is overtaken dropped (PLAN 4.2).
class SearchModel extends ValueNotifier<SearchResults> {
  SearchModel({
    required this.library,
    required this.engine,
    required this.remoteAllowed,
    required this.now,
    this.fetch = fetchSuggestions,
    this.debounce = const Duration(milliseconds: 150),
  }) : super(const SearchResults());

  final Library library;
  final SearchEngine engine;

  /// Off in private mode and when the setting is off.
  final bool remoteAllowed;
  final DateTime Function() now;
  final SuggestionFetcher fetch;
  final Duration debounce;

  Timer? _timer;
  var _generation = 0;
  List<BookmarkFolder> _folders = const [];

  Future<void> update(String input) async {
    final text = input.trim();
    final generation = ++_generation;
    _timer?.cancel();
    if (text.isEmpty) {
      value = const SearchResults();
      return;
    }
    final local = await _local(text);
    if (generation != _generation) return;
    final address = _addressOf(text);
    final topHit = address != null
        ? AddressSuggestion(address)
        : local.isNotEmpty && _strong(local.first, text)
        ? local.first
        : null;
    value = SearchResults(
      input: text,
      topHit: topHit,
      local: [
        for (final s in local)
          if (!identical(s, topHit)) s,
      ].take(3).toList(),
      remote: value.input.isNotEmpty ? value.remote : const [],
    );
    if (!remoteAllowed) return;
    _timer = Timer(debounce, () async {
      final remote = await fetch(engine, text);
      if (generation != _generation) return;
      value = SearchResults(
        input: value.input,
        topHit: value.topHit,
        local: value.local,
        remote: [
          for (final s in remote)
            if (s.toLowerCase() != text.toLowerCase()) QuerySuggestion(s),
        ].take(5).toList(),
      );
    });
  }

  /// Typed text that is an address, not a search.
  Uri? _addressOf(String text) {
    if (text.contains(' ')) return null;
    final uri = resolveAddress(text, engine);
    if (uri == null || uri == engine.searchUri(text)) return null;
    return uri;
  }

  /// A local match good enough to be the top hit: the text starts a word of
  /// its title or its host.
  static bool _strong(SearchSuggestion s, String text) {
    final q = text.toLowerCase();
    final (title, url) = switch (s) {
      HistorySuggestion(:final page) => (page.title, page.url),
      BookmarkSuggestion(:final bookmark) => (bookmark.title, bookmark.url),
      ReadingSuggestion(:final item) => (item.title, item.url),
      _ => ('', Uri()),
    };
    final host = url.host.startsWith('www.') ? url.host.substring(4) : url.host;
    if (host.startsWith(q)) return true;
    return title
        .toLowerCase()
        .split(RegExp(r'[\s\-–—·|:]+'))
        .any((word) => word.startsWith(q));
  }

  Future<List<SearchSuggestion>> _local(String text) async {
    final q = text.toLowerCase();
    if (_folders.isEmpty) _folders = await library.folders();
    final results = await Future.wait([
      library.readingItems(),
      library.searchBookmarks(text, limit: 6),
      library.searchPages(text, now(), limit: 6),
    ]);
    final reading = (results[0] as List<ReadingItem>).where(
      (r) =>
          r.title.toLowerCase().contains(q) ||
          r.url.toString().toLowerCase().contains(q),
    );
    final scored = <(double, SearchSuggestion)>[];
    final seen = <String>{};
    void add(double score, Uri url, SearchSuggestion s) {
      final key = url.toString();
      if (!seen.add(key)) return;
      scored.add((score + (_strong(s, text) ? 1000 : 0), s));
    }

    for (final r in reading) {
      add(450, r.url, ReadingSuggestion(r));
    }
    for (final b in results[1] as List<Bookmark>) {
      final folder = _folders.where((f) => f.id == b.folderId).firstOrNull;
      add(500, b.url, BookmarkSuggestion(b, folder?.name ?? ''));
    }
    for (final p in results[2] as List<HistoryPage>) {
      add(
        p.frecency(now()).clamp(0, 900).toDouble(),
        p.url,
        HistorySuggestion(p),
      );
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final (_, s) in scored) s];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _generation++;
    super.dispose();
  }
}
