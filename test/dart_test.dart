// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library dart_test;

import 'package:petitparser/dart.dart';
import 'package:unittest/unittest.dart';

void main() {
  var dart = new DartParser();
  test('basic parsing', () {
    expect(dart.accept('library test;'), isTrue);
    expect(dart.accept('library test; void main() { }'), isTrue);
    expect(dart.accept('library test; void main() { print(2 + 3); }'), isTrue);
  });
}
