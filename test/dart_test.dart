// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library dart_test;

import 'dart:io';
import 'dart:async';

import 'package:petitparser/dart.dart';
import 'package:unittest/unittest.dart';

void generateTests(String title, String path) {
  group(title, () {
    new Directory(path)
      .listSync(recursive: true, followLinks: false)
      .where((file) => file is File && file.path.endsWith('.dart'))
      .forEach((file) {
        test(file.path, () {
          var result = _dart.parse(file.readAsStringSync());
          if (result.isFailure) fail(result.toString());
        });
      });
  });
}

final _dart = new DartGrammar();

void main() {
  test('basic files', () {
    expect(_dart.accept('library test;'), isTrue);
    expect(_dart.accept('library test; void main() { }'), isTrue);
    expect(_dart.accept('library test; void main() { print(2 + 3); }'), isTrue);
  });
  test('basic whitespace', () {
    expect(_dart.accept('library test;'), isTrue);
    expect(_dart.accept('  library test;'), isTrue);
    expect(_dart.accept('library test;  '), isTrue);
    expect(_dart.accept('library  test ;'), isTrue);
  });
  test('single line comment', () {
    expect(_dart.accept('library test;'), isTrue);
    expect(_dart.accept('library// foo\ntest;'), isTrue);
    expect(_dart.accept('library test // foo \n;'), isTrue);
    expect(_dart.accept('library test; // foo'), isTrue);
  });
  test('multi line comment', () {
    expect(_dart.accept('/* foo */ library test;'), isTrue);
    expect(_dart.accept('library /* foo */ test;'), isTrue);
    expect(_dart.accept('library test; /* foo */'), isTrue);
  });
  // generateTests('Dart SDK Sources', '/Applications/Dart/dart-sdk');
  generateTests('PetitParser Sources', '.');
}
