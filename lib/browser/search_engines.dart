import 'dart:convert';

/// The quick search chips of the search screen (`P:203`–`P:209`).
enum QuickSearch { images, maps, news, weather }

/// The search engines of the settings (PLAN 1.5), with their suggestion
/// endpoints (PLAN 4.2) and the vertical searches behind the quick chips.
enum SearchEngine {
  google('Google', 'www.google.com', '/search'),
  ecosia('Ecosia', 'www.ecosia.org', '/search'),
  duckDuckGo('DuckDuckGo', 'duckduckgo.com', '/'),
  startpage('Startpage', 'www.startpage.com', '/do/search'),
  bing('Bing', 'www.bing.com', '/search');

  const SearchEngine(this.label, this._host, this._path);

  final String label;
  final String _host;
  final String _path;

  String get letter => label[0];

  /// The results page for [query].
  Uri searchUri(String query) => Uri.https(_host, _path, {'q': query});

  /// Where typing is sent for suggestions. Each answers in the OpenSearch
  /// format (`["query", ["suggestion", ...]]`).
  Uri suggestUri(String query) => switch (this) {
    google => Uri.https('suggestqueries.google.com', '/complete/search', {
      'client': 'firefox',
      'q': query,
    }),
    ecosia => Uri.https('ac.ecosia.org', '/autocomplete', {
      'q': query,
      'type': 'list',
    }),
    duckDuckGo => Uri.https('duckduckgo.com', '/ac/', {
      'q': query,
      'type': 'list',
    }),
    startpage => Uri.https('www.startpage.com', '/suggestions', {
      'q': query,
      'format': 'opensearch',
    }),
    bing => Uri.https('api.bing.com', '/osjson.aspx', {'query': query}),
  };

  /// The vertical search for a quick chip. Engines without maps use
  /// OpenStreetMap; the weather is an ordinary search.
  Uri quickUri(
    QuickSearch kind,
    String query, {
    String weatherWord = 'Wetter',
  }) {
    final q = query.trim();
    Uri osm() => Uri.https('www.openstreetmap.org', '/search', {'query': q});
    return switch ((this, kind)) {
      (_, QuickSearch.weather) => searchUri(
        q.isEmpty ? weatherWord : '$weatherWord $q',
      ),
      (google, QuickSearch.images) => Uri.https(_host, _path, {
        'q': q,
        'tbm': 'isch',
      }),
      (google, QuickSearch.news) => Uri.https(_host, _path, {
        'q': q,
        'tbm': 'nws',
      }),
      (google, QuickSearch.maps) => Uri.https(_host, '/maps/search/$q'),
      (bing, QuickSearch.images) => Uri.https(_host, '/images/search', {
        'q': q,
      }),
      (bing, QuickSearch.news) => Uri.https(_host, '/news/search', {'q': q}),
      (bing, QuickSearch.maps) => Uri.https(_host, '/maps', {'q': q}),
      (duckDuckGo, QuickSearch.images) => Uri.https(_host, _path, {
        'q': q,
        'ia': 'images',
        'iax': 'images',
      }),
      (duckDuckGo, QuickSearch.news) => Uri.https(_host, _path, {
        'q': q,
        'ia': 'news',
        'iar': 'news',
      }),
      (duckDuckGo, QuickSearch.maps) => Uri.https(_host, _path, {
        'q': q,
        'ia': 'maps',
        'iaxm': 'maps',
      }),
      (ecosia, QuickSearch.images) => Uri.https(_host, '/images', {'q': q}),
      (ecosia, QuickSearch.news) => Uri.https(_host, '/news', {'q': q}),
      (startpage, QuickSearch.images) => Uri.https(_host, _path, {
        'q': q,
        'cat': 'images',
      }),
      (startpage, QuickSearch.news) => Uri.https(_host, _path, {
        'q': q,
        'cat': 'news',
      }),
      (_, QuickSearch.maps) => osm(),
    };
  }
}

/// The suggestions in an engine's answer, at most [limit]. Understands the
/// OpenSearch array and the `{"suggestions": [...]}` object some engines send;
/// anything else gives none.
List<String> parseSuggestions(String body, {int limit = 6}) {
  final Object? json;
  try {
    json = jsonDecode(body);
  } on FormatException {
    return const [];
  }
  Iterable<Object?> raw = const [];
  if (json is List && json.length >= 2 && json[1] is List) {
    raw = json[1] as List;
  } else if (json is Map && json['suggestions'] is List) {
    raw = json['suggestions'] as List;
  }
  final out = <String>[];
  for (final item in raw) {
    final text = switch (item) {
      final String s => s,
      {'phrase': final String s} => s,
      {'value': final String s} => s,
      _ => null,
    };
    if (text == null) continue;
    final t = text.trim();
    if (t.isEmpty || t.length > 200 || out.contains(t)) continue;
    out.add(t);
    if (out.length == limit) break;
  }
  return out;
}
