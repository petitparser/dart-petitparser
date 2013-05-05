// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library dart_test;

import 'dart:io';
import 'dart:async';

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
    test('singleLineString', () {
      var slsParser = dart['singleLineString'].plus().end();
      var validExamples = const ["'hi'", '"hi"'];
      for(var example in validExamples) {
        var result = slsParser.parse(example);
        if(result.isFailure) {
          fail(result.message);
        }
      }
    });

  });
  // generateTests('Dart SDK Sources', '/Applications/Dart/dart-sdk');
  // generateTests('PetitParser Sources', '.');
}
