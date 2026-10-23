import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/ui/buttons.dart';

void main() {
  test('HIcons holds the 64 distinct icons of the prototype', () {
    expect(HIcons.all, hasLength(64));
    final points = {for (final icon in HIcons.all) icon.codePoint};
    expect(points, hasLength(64));
  });
}
