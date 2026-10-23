import 'search_engines.dart';

final _scheme = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*):');
final _authority = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');
final _hostLike = RegExp(
  r'^(?:localhost|(?:\d{1,3}\.){3}\d{1,3}|\[[0-9a-fA-F:.]+\]|'
  r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,})'
  r'(?::\d{1,5})?(?:[/?#]\S*)?$',
);
final _local = RegExp(r'^(?:localhost|(?:\d{1,3}\.){3}\d{1,3}|\[)');

/// Turns what was typed into the address to load, or null where nothing may
/// be loaded (empty input, or a scheme the address bar refuses).
///
/// - `http:`, `https:` and `about:` are taken as typed.
/// - Anything else with a scheme (`file:`, `javascript:`, `data:`, `intent:`)
///   is refused: pages and the user's typing alike must not reach local files
///   or run script from the address bar.
/// - Text that looks like a host, with optional port and path, gets
///   `https://`; local hosts and IP literals get `http://`, because a
///   development server rarely has a certificate.
/// - Everything else is searched with [engine].
Uri? resolveAddress(String input, SearchEngine engine) {
  final text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains(' ')) {
    final scheme = _scheme.firstMatch(text)?.group(1)?.toLowerCase();
    // `host:8080` also looks like a scheme; a real URL has `://`.
    final isUrl = _authority.hasMatch(text) || scheme == 'about';
    if (isUrl || (scheme != null && !_hostLike.hasMatch(text))) {
      if (scheme == 'http' || scheme == 'https' || scheme == 'about') {
        return Uri.tryParse(text);
      }
      return null;
    }
    if (_hostLike.hasMatch(text)) {
      final prefix = _local.hasMatch(text) ? 'http' : 'https';
      return Uri.tryParse('$prefix://$text');
    }
  }
  return engine.searchUri(text);
}
