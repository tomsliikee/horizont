/// The search engines of the settings (PLAN 1.5). Suggestion endpoints join
/// them in milestone 5.
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

  /// The results page for [query].
  Uri searchUri(String query) => Uri.https(_host, _path, {'q': query});
}
