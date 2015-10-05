library dart_test;

import 'package:test/test.dart';

import 'package:petitparser/test.dart';
import 'package:petitparser/dart.dart';

void main() {
  var definition = new DartGrammarDefinition();
  var dart = new DartGrammar();
  group('basic', () {
    test('structure', () {
      expect('library test;', accept(dart));
      expect('library test; void main() { }', accept(dart));
      expect('library test; void main() { print(2 + 3); }', accept(dart));
    });
  });
  group('expression', () {
    var expression = definition.build(start: definition.expression).end();
    test('literal numbers', () {
      expect('1', accept(expression));
      expect('1.2', accept(expression));
      expect('1.2e3', accept(expression));
      expect('1.2e-3', accept(expression));
      expect('-1.2e3', accept(expression));
      expect('-1.2e-3', accept(expression));
      expect('-1.2E-3', accept(expression));
    });
    test('literal objects', () {
      expect('true', accept(expression));
      expect('false', accept(expression));
      expect('null', accept(expression));
    });
    test('unary increment/decrement', () {
      expect('++a', accept(expression));
      expect('--a', accept(expression));
      expect('a++', accept(expression));
      expect('a--', accept(expression));
    });
    test('unary operators', () {
      expect('+a', accept(expression));
      expect('-a', accept(expression));
      expect('!a', accept(expression));
      expect('~a', accept(expression));
    });
    test('binary arithmetic operators', () {
      expect('a + b', accept(expression));
      expect('a - b', accept(expression));
      expect('a * b', accept(expression));
      expect('a / b', accept(expression));
      expect('a ~/ b', accept(expression));
      expect('a % b', accept(expression));
    });
    test('binary logical operators', () {
      expect('a & b', accept(expression));
      expect('a | b', accept(expression));
      expect('a ^ b', accept(expression));
      expect('a && b', accept(expression));
      expect('a || b', accept(expression));
    });
    test('binary conditional operators', () {
      expect('a > b', accept(expression));
      expect('a >= b', accept(expression));
      expect('a < b', accept(expression));
      expect('a <= b', accept(expression));
      expect('a == b', accept(expression));
      expect('a != b', accept(expression));
      expect('a === b', accept(expression));
      expect('a !== b', accept(expression));
    });
    test('binary shift operators', () {
      expect('a << b', accept(expression));
      expect('a >>> b', accept(expression));
      expect('a >> b', accept(expression));
    });
    test('ternary operator', () {
      expect('a ? b : c', accept(expression));
    });
    test('parenthesis', () {
      expect('(a + b)', accept(expression));
      expect('a * (b + c)', accept(expression));
      expect('(a * b) + c', accept(expression));
    });
    test('access', () {
      expect('a.b', accept(expression));
    });
    test('invoke', () {
      expect('a.b()', accept(expression));
      expect('a.b(c)', accept(expression));
      expect('a.b(c, d)', accept(expression));
      expect('a.b(c: d)', accept(expression));
      expect('a.b(c: d, e: f)', accept(expression));
    });
    test('assignment', () {
      expect('a = b', accept(expression));
      expect('a += b', accept(expression));
      expect('a -= b', accept(expression));
      expect('a *= b', accept(expression));
      expect('a /= b', accept(expression));
      expect('a %= b', accept(expression));
      expect('a ~/= b', accept(expression));
      expect('a <<= b', accept(expression));
      expect('a >>>= b', accept(expression));
      expect('a >>= b', accept(expression));
      expect('a &= b', accept(expression));
      expect('a ^= b', accept(expression));
      expect('a |= b', accept(expression));
    });
    test('indexed', () {
      expect('a[b]', accept(expression));
      expect('a[b] = c', accept(expression));
    });
  });
  group('whitespace', () {
    var whitespaces = definition.build(start: definition.HIDDEN).end();
    test('whitespace', () {
      expect(' ', accept(whitespaces));
      expect('\t', accept(whitespaces));
      expect('\n', accept(whitespaces));
      expect('\r', accept(whitespaces));
      expect('a', isNot(accept(whitespaces)));
    });
    test('single-line comment', () {
      expect('//', accept(whitespaces));
      expect('// foo', accept(whitespaces));
      expect('//\n', accept(whitespaces));
      expect('// foo\n', accept(whitespaces));
    });
    test('single-line documentation', () {
      expect('///', accept(whitespaces));
      expect('/// foo', accept(whitespaces));
      expect('/// \n', accept(whitespaces));
      expect('/// foo\n', accept(whitespaces));
    });
    test('multi-line comment', () {
      expect('/**/', accept(whitespaces));
      expect('/* foo */', accept(whitespaces));
      expect('/* foo \n bar */', accept(whitespaces));
      expect('/* foo ** bar */', accept(whitespaces));
      expect('/* foo * / bar */', accept(whitespaces));
    });
    test('multi-line documentation', () {
      expect('/***/', accept(whitespaces));
      expect('/*******/', accept(whitespaces));
      expect('/** foo */', accept(whitespaces));
      expect('/**\n *\n *\n */', accept(whitespaces));
    });
    test('multi-line nested', () {
      expect('/* outer /* nested */ */', accept(whitespaces));
      expect('/* outer /* nested /* deeply nested */ */ */', accept(whitespaces));
      expect('/* outer /* not closed */', isNot(accept(whitespaces)));
    });
    test('combined', () {
      expect('/**/', accept(whitespaces));
      expect(' /**/', accept(whitespaces));
      expect('/**/ ', accept(whitespaces));
      expect(' /**/ ', accept(whitespaces));
      expect('/**///', accept(whitespaces));
      expect('/**/ //', accept(whitespaces));
      expect(' /**/ //', accept(whitespaces));
    });
  });
  group('child parsers', () {
    var parser = definition.build(start: definition.STRING).end();
    test('singleLineString', () {
      expect("'hi'", accept(parser));
      expect('"hi"', accept(parser));
      expect('no quotes', isNot(accept(parser)));
      expect('"missing quote', isNot(accept(parser)));
      expect("'missing quote", isNot(accept(parser)));
    });
  });
  group('offical', () {
    test('identifier', () {
      var parser = definition.build(start: definition.identifier).end();
      expect('foo', accept(parser));
      expect('bar9', accept(parser));
      expect('dollar\$', accept(parser));
      expect('_foo', accept(parser));
      expect('_bar9', accept(parser));
      expect('_dollar\$', accept(parser));
      expect('\$', accept(parser));
      expect(' leadingSpace', accept(parser));
      expect('9', isNot(accept(parser)));
      expect('3foo', isNot(accept(parser)));
      expect('', isNot(accept(parser)));
    });
    test('numeric literal', () {
      var parser = definition.build(start: definition.literal).end();
      expect('0', accept(parser));
      expect('1984', accept(parser));
      expect(' 1984', accept(parser));
      expect('0xCAFE', accept(parser));
      expect('0XCAFE', accept(parser));
      expect('0xcafe', accept(parser));
      expect('0Xcafe', accept(parser));
      expect('0xCaFe', accept(parser));
      expect('0XCaFe', accept(parser));
      expect('3e4', accept(parser));
      expect('3e-4', accept(parser));
      expect('3E4', accept(parser));
      expect('3E-4', accept(parser));
      expect('3.14E4', accept(parser));
      expect('3.14E-4', accept(parser));
      expect('3.14', accept(parser));
      expect('3e--4', isNot(accept(parser)));
      expect('5.', isNot(accept(parser)));
      expect('CAFE', isNot(accept(parser)));
      expect('0xGHIJ', isNot(accept(parser)));
      expect('-', isNot(accept(parser)));
      expect('', isNot(accept(parser)));
    });
    test('boolean literal', () {
      var parser = definition.build(start: definition.literal).end();
      expect('true', accept(parser));
      expect('false', accept(parser));
      expect(' true', accept(parser));
      expect(' false', accept(parser));
    });
  });
}
