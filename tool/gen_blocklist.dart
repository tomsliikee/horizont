// Reduces the EasyPrivacy list (`tool/data/easyprivacy.txt`) to the plain
// domain rules the request blocker uses: one domain per line in
// `assets/blocklist/easyprivacy_domains.txt`. Rules with options other than
// `$third-party`, paths or wildcards are left out; domains with an exception
// rule (`@@||domain^`) are left out too. Run by hand after updating the list:
//
//   dart run tool/gen_blocklist.dart
import 'dart:io';

final _rule = RegExp(r'^\|\|([a-z0-9.-]+)\^(\$third-party)?$');
final _exception = RegExp(r'^@@\|\|([a-z0-9.-]+)\^');

void main() {
  final lines = File('tool/data/easyprivacy.txt').readAsLinesSync();
  final blocked = <String>{};
  final allowed = <String>{};
  for (final line in lines) {
    final rule = _rule.firstMatch(line);
    if (rule != null) blocked.add(rule.group(1)!);
    final exception = _exception.firstMatch(line);
    if (exception != null) allowed.add(exception.group(1)!);
  }
  final domains = blocked.difference(allowed).where((d) => d.contains('.')).toList()..sort();
  File('assets/blocklist/easyprivacy_domains.txt').writeAsStringSync('${domains.join('\n')}\n');
  stdout.writeln('${domains.length} domains');
}
