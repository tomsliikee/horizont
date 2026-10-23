import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/browser/downloads/file_name.dart';
import 'package:horizont/browser/search_engines.dart';

void main() {
  group('parseSuggestions', () {
    test('reads the OpenSearch array', () {
      expect(
        parseSuggestions('["wien",["wien wetter","wien museum","wien"]]'),
        ['wien wetter', 'wien museum', 'wien'],
      );
    });

    test('reads the object form and phrase entries', () {
      expect(
        parseSuggestions('{"query":"a","suggestions":["ab",{"phrase":"ac"}]}'),
        ['ab', 'ac'],
      );
    });

    test('drops duplicates, blanks, overlong entries, and caps the count', () {
      final long = 'x' * 300;
      expect(
        parseSuggestions('["q",["a","a"," ","$long","b","c","d","e","f","g"]]'),
        ['a', 'b', 'c', 'd', 'e', 'f'],
      );
    });

    test('anything else gives nothing', () {
      expect(parseSuggestions('not json'), isEmpty);
      expect(parseSuggestions('{"x":1}'), isEmpty);
      expect(parseSuggestions('[1]'), isEmpty);
    });
  });

  test('every engine has a suggestion endpoint with the query', () {
    for (final engine in SearchEngine.values) {
      final uri = engine.suggestUri('wien wetter');
      expect(uri.scheme, 'https', reason: engine.name);
      expect(uri.queryParameters.values, contains('wien wetter'));
    }
  });

  test('quick searches map to the verticals', () {
    final g = SearchEngine.google;
    expect(
      g.quickUri(QuickSearch.images, 'berg').queryParameters['tbm'],
      'isch',
    );
    expect(g.quickUri(QuickSearch.news, 'berg').queryParameters['tbm'], 'nws');
    expect(g.quickUri(QuickSearch.maps, 'wien').path, '/maps/search/wien');
    expect(
      g
          .quickUri(QuickSearch.weather, '', weatherWord: 'Wetter')
          .queryParameters['q'],
      'Wetter',
    );
    expect(
      SearchEngine.ecosia.quickUri(QuickSearch.maps, 'wien').host,
      'www.openstreetmap.org',
    );
    expect(
      SearchEngine.bing.quickUri(QuickSearch.images, 'x').path,
      '/images/search',
    );
  });

  group('downloadFileName', () {
    final url = Uri.parse('https://a.example/files/report.pdf?x=1');

    test('Content-Disposition first, the UTF-8 form before the plain one', () {
      expect(
        downloadFileName(
          url: url,
          contentDisposition: "attachment; filename=\"plain.pdf\"; filename*=UTF-8''K%C3%BCrbis%20Suppe.pdf",
        ),
        'Kürbis Suppe.pdf',
      );
      expect(
        downloadFileName(
          url: url,
          contentDisposition: 'attachment; filename="a b.zip"',
        ),
        'a b.zip',
      );
    });

    test('else the path, else download with an extension from the type', () {
      expect(downloadFileName(url: url), 'report.pdf');
      expect(
        downloadFileName(
          url: Uri.parse('https://a.example/'),
          mimeType: 'image/png',
        ),
        'download.png',
      );
      expect(
        downloadFileName(
          url: Uri.parse('blob:https://a.example/123'),
          mimeType: 'text/csv',
        ),
        'download.csv',
      );
    });

    test('characters a file system refuses are replaced; no hidden names', () {
      expect(
        downloadFileName(
          url: url,
          contentDisposition: 'filename="../a:b*?.txt"',
        ),
        '_a_b__.txt',
      );
      expect(
        downloadFileName(url: url, contentDisposition: 'filename=".bashrc"'),
        'bashrc',
      );
    });
  });
}
