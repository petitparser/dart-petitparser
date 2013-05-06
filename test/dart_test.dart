// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library dart_test;

import 'dart:io';
import 'dart:async';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/dart.dart';
import 'package:unittest/unittest.dart';

void generateTests(String title, String path) {
  group(title, () {
    var dart = new DartGrammar();
    new Directory(path)
      .listSync(recursive: true, followLinks: false)
      .where((file) => file is File && file.path.endsWith('.dart'))
      .forEach((file) {
        test(file.path, () {
          var result = dart.parse(file.readAsStringSync());
          if (result.isFailure) {
            fail(result.toString());
          }
        });
      });
  });
}

void main() {
  var dart = new DartGrammar();
  test('basic files', () {
    expect(dart.accept('library test;'), isTrue);
    expect(dart.accept('library test; void main() { }'), isTrue);
    expect(dart.accept('library test; void main() { print(2 + 3); }'), isTrue);
  });
  test('basic whitespace', () {
    expect(dart.accept('library test;'), isTrue);
    expect(dart.accept('  library test;'), isTrue);
    expect(dart.accept('library test;  '), isTrue);
    expect(dart.accept('library  test ;'), isTrue);
  });
  test('single line comment', () {
    expect(dart.accept('library test;'), isTrue);
    expect(dart.accept('library// foo\ntest;'), isTrue);
    expect(dart.accept('library test // foo \n;'), isTrue);
    expect(dart.accept('library test; // foo'), isTrue);
  });
  test('multi line comment', () {
    expect(dart.accept('/* foo */ library test;'), isTrue);
    expect(dart.accept('library /* foo */ test;'), isTrue);
    expect(dart.accept('library test; /* foo */'), isTrue);
  });
  group('child parsers', () {
    test('NUMBER', () {
      var numParser = dart['NUMBER'].plus().end();
      expect(numParser.accept('1234'), isTrue);
      expect(numParser.accept('1.4'), isTrue);
      expect(numParser.accept('12.34'), isTrue);
      expect(numParser.accept('123.2e34'), isTrue);

      expect(numParser.accept('kevin'), isFalse);
      expect(numParser.accept('9a'), isFalse);
      expect(numParser.accept('9 0'), isFalse);
    });
    test('stringContentDQ', () {
      var parser = dart['stringContentDQ'];

      var validExamples = const ["'hi'", 'hello', ' whitespace '];
      for(var example in validExamples) {
        _testValid(parser, example);
      }
    });
    test('singleLineString', () {
      var parser = dart['singleLineString'];
      var validExamples = const ["'hi'", '"hi"', r"r'$'"];
      for(var example in validExamples) {
        _testValid(parser, example);
      }

      ['no quotes', '"missing quote', "'missing quote"].forEach((v) {
        _testInvalid(parser, v);
      });
    });

  });
  // generateTests('Dart SDK Sources', '/Applications/Dart/dart-sdk');
  // generateTests('PetitParser Sources', '.');
}

void _testInvalid(Parser parser, String value) {
  parser = parser.plus().flatten().end();
  var result = parser.parse(value);
  expect(result.isFailure, isTrue, reason: 'Expected failure for value $value');
}

void _testValid(Parser parser, String value) {
  parser = parser.plus().flatten().end();
  var result = parser.parse(value);
  if(result.isFailure) {
    fail(result.message);
  } else {
    expect(result.value, value);
  }
}
