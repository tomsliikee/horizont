import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/address.dart';
import 'package:horizont/browser/search_engines.dart';

void main() {
  const google = SearchEngine.google;

  // input -> expected address; null means refused or empty.
  final cases = <String, String?>{
    '': null,
    '   ': null,
    'https://example.com/a?b=1': 'https://example.com/a?b=1',
    'http://example.com': 'http://example.com',
    'HTTPS://Example.com': 'https://example.com',
    'about:blank': 'about:blank',
    'example.com': 'https://example.com',
    'www.example.com/path?x=1#y': 'https://www.example.com/path?x=1#y',
    'example.com:8080/x': 'https://example.com:8080/x',
    'sub.example.co.uk': 'https://sub.example.co.uk',
    'localhost': 'http://localhost',
    'localhost:3000/app': 'http://localhost:3000/app',
    '192.168.0.1': 'http://192.168.0.1',
    '192.168.0.1:8080': 'http://192.168.0.1:8080',
    '[::1]:8080': 'http://[::1]:8080',
    'file:///etc/passwd': null,
    'javascript:alert(1)': null,
    'data:text/html,hi': null,
    'intent://x#Intent;end': null,
    'mailto:a@b.at': null,
    'wetter wien': 'https://www.google.com/search?q=wetter+wien',
    'example .com': 'https://www.google.com/search?q=example+.com',
    'what is dart?': 'https://www.google.com/search?q=what+is+dart%3F',
    'dart': 'https://www.google.com/search?q=dart',
  };

  for (final MapEntry(key: input, value: expected) in cases.entries) {
    test('"$input"', () {
      expect(resolveAddress(input, google)?.toString(), expected);
    });
  }

  test('each engine builds its own search address', () {
    final hosts = {
      for (final e in SearchEngine.values) e: e.searchUri('a b').host,
    };
    expect(hosts.values.toSet(), hasLength(SearchEngine.values.length));
    expect(
      SearchEngine.duckDuckGo.searchUri('a b').toString(),
      'https://duckduckgo.com/?q=a+b',
    );
  });
}
