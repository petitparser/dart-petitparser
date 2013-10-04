// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library dart_test;

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/dart.dart';
import 'package:unittest/unittest.dart';

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
      var parser = dart['NUMBER'].end();
      expect(parser.accept('1234'), isTrue);
      expect(parser.accept('1.4'), isTrue);
      expect(parser.accept('12.34'), isTrue);
      expect(parser.accept('123.2e34'), isTrue);
      expect(parser.accept('kevin'), isFalse);
      expect(parser.accept('9a'), isFalse);
      expect(parser.accept('9 0'), isFalse);
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
  group('gilad', () {
    test('identifier', () {
      var parser = dart['identifier'].end();
      expect(parser.accept('foo'), isTrue);
      expect(parser.accept('bar9'), isTrue);
      expect(parser.accept('dollar\$'), isTrue);
      expect(parser.accept('_foo'), isTrue);
      expect(parser.accept('_bar9'), isTrue);
      expect(parser.accept('_dollar\$'), isTrue);
      expect(parser.accept('\$'), isTrue);
      expect(parser.accept(' leadingSpace'), isTrue);
      expect(parser.accept('9'), isFalse);
      expect(parser.accept('3foo'), isFalse);
      expect(parser.accept(''), isFalse);
    });
    test('numeric literal', () {
      var parser = dart['numericLiteral'].end();
      expect(parser.accept('0'), isTrue);
      expect(parser.accept('1984'), isTrue);
      expect(parser.accept('-1984'), isTrue);
      expect(parser.accept('0xCAFE'), isTrue);
      expect(parser.accept('0XCAFE'), isTrue);
      expect(parser.accept('0xcafe'), isTrue);
      expect(parser.accept('0Xcafe'), isTrue);
      expect(parser.accept('0xCaFe'), isTrue);
      expect(parser.accept('0XCaFe'), isTrue);
      expect(parser.accept('3e4'), isTrue);
      expect(parser.accept('3e-4'), isTrue);
      expect(parser.accept('-3e4'), isTrue);
      expect(parser.accept('-3e-4'), isTrue);
      expect(parser.accept('3E4'), isTrue);
      expect(parser.accept('3E-4'), isTrue);
      expect(parser.accept('-3E4'), isTrue);
      expect(parser.accept('-3E-4'), isTrue);
      expect(parser.accept('-3.14E4'), isTrue);
      expect(parser.accept('-3.14E-4'), isTrue);
      expect(parser.accept('-3.14'), isTrue);
      expect(parser.accept('3.14'), isTrue);
      expect(parser.accept('-3e--4'), isFalse);
      expect(parser.accept('5.'), isFalse);
      expect(parser.accept('-0xCAFE'), isFalse);
      expect(parser.accept('-0XCAFE'), isFalse);
      expect(parser.accept('CAFE'), isFalse);
      expect(parser.accept('0xGHIJ'), isFalse);
      expect(parser.accept('-'), isFalse);
      expect(parser.accept(''), isFalse);
    });
    test('boolean literal', () {
      var parser = dart['booleanLiteral'].end();
      expect(parser.accept('true'), isTrue);
      expect(parser.accept('false'), isTrue);
      expect(parser.accept(' true'), isTrue);
      expect(parser.accept(' false'), isTrue);
      expect(parser.accept('9'), isFalse);
      expect(parser.accept('"foo"'), isFalse);
      expect(parser.accept("'foo'"), isFalse);
      expect(parser.accept('TRUE'), isFalse);
      expect(parser.accept('FALSE'), isFalse);
      expect(parser.accept('null'), isFalse);
      expect(parser.accept('0xCAFE'), isFalse);
    });
  });
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
