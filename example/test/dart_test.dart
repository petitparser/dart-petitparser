library petitparser.example.test.dart_test;

import 'package:example/dart.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

Function accept(Parser parser) => (input) => parser.parse(input).isSuccess;

void main() {
  final grammar = DartGrammarDefinition();
  group('directives', () {
    final directives = grammar.build(start: grammar.start).end();
    test('hashbang', () {
      expect('#!/bin/dart\n', accept(directives));
    });
    test('library', () {
      expect('library a;', accept(directives));
      expect('library a.b;', accept(directives));
      expect('library a.b.c_d;', accept(directives));
    });
    test('part of', () {
      expect('part of a;', accept(directives));
      expect('part of a.b;', accept(directives));
      expect('part of a.b.c_d;', accept(directives));
    });
    test('part', () {
      expect('part "abc";', accept(directives));
    });
    test('import', () {
      expect('import "abc";', accept(directives));
      expect('import "abc" deferred;', accept(directives));
      expect('import "abc" as a;', accept(directives));
      expect('import "abc" deferred as a;', accept(directives));
      expect('import "abc" show a;', accept(directives));
      expect('import "abc" deferred show a, b;', accept(directives));
      expect('import "abc" hide a;', accept(directives));
      expect('import "abc" deferred hide a, b;', accept(directives));
    });
    test('export', () {
      expect('export "abc";', accept(directives));
      expect('export "abc" show a;', accept(directives));
      expect('export "abc" show a, b;', accept(directives));
      expect('export "abc" hide a;', accept(directives));
      expect('export "abc" hide a, b;', accept(directives));
    });
    test('full', () {
      expect('library test;', accept(directives));
      expect('library test; void main() { }', accept(directives));
      expect('library test; void main() { print(2 + 3); }', accept(directives));
    });
  });
  group('expression', () {
    final expression = grammar.build(start: grammar.expression).end();
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
    test('literal array', () {
      expect('[]', accept(expression));
      expect('[a]', accept(expression));
      expect('[a, b]', accept(expression));
      expect('[a, b, c]', accept(expression));
    });
    test('literal map', () {
      expect('{}', accept(expression));
      expect('{"a": b}', accept(expression));
      expect('{"a": b, "c": d}', accept(expression));
      expect('{"a": b, "c": d, "e": f}', accept(expression));
    });
    test('literal (nested)', () {
      expect('[1, true, [1], {"a": b}]', accept(expression));
      expect(
          '{"a": 1, "b": true, "c": [1], "d": {"a": b}}', accept(expression));
    });
    test('conditional', () {
      expect('a ? b : c', accept(expression));
      expect('a ? b ? c : d : c', accept(expression));
    });
    test('relational', () {
      expect('a is b', accept(expression));
      expect('a is !b', accept(expression));
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
    test('parenthesis', () {
      expect('(a + b)', accept(expression));
      expect('a * (b + c)', accept(expression));
      expect('(a * b) + c', accept(expression));
    });
    test('access', () {
      expect('a.b', accept(expression));
      expect('a.b.c', accept(expression));
    });
    test('indexed', () {
      expect('a[b]', accept(expression));
      expect('a[b] = c', accept(expression));
      expect('a[b][c]', accept(expression));
      expect('a[b][c] = d', accept(expression));
    });
    test('invoke', () {
      expect('a()', accept(expression));
      expect('a(b)', accept(expression));
      expect('a(b, c)', accept(expression));
      expect('a(b: c)', accept(expression));
      expect('a(b: c, d: e)', accept(expression));
    });
    test('invoke (double)', () {
      expect('a()()', accept(expression));
      expect('a(b)(b)', accept(expression));
      expect('a(b, c)(b, c)', accept(expression));
      expect('a(b: c)(b: c)', accept(expression));
      expect('a(b: c, d: e)(b: c, d: e)', accept(expression));
    });
    test('constructor', () {
      expect('new a()', accept(expression));
      expect('const a()', accept(expression));
      expect('new a<b>()', accept(expression));
      expect('const a<b>()', accept(expression));
      expect('new a.b()', accept(expression));
      expect('const a.b()', accept(expression));
    });
    test('function (expression)', () {
      expect('() => a', accept(expression));
      expect('a() => b', accept(expression));
      expect('a () => b', accept(expression));
      expect('a b() => c', accept(expression));
      expect('a (b) => c', accept(expression));
      expect('a b(c) => d', accept(expression));
    });
    test('function (block)', () {
      expect('() {}', accept(expression));
      expect('a() {}', accept(expression));
      expect('a () {}', accept(expression));
      expect('a b() {}', accept(expression));
      expect('a (b) {}', accept(expression));
      expect('a b(c) {}', accept(expression));
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
  });
  group('statement', () {
    final statement = grammar.build(start: grammar.statement).end();
    test('label', () {
      expect('a: {}', accept(statement));
      expect('a: b: {}', accept(statement));
      expect('a: b: c: {}', accept(statement));
    });
    test('block', () {
      expect('{}', accept(statement));
      expect('{{}}', accept(statement));
    });
    test('declaration', () {
      expect('var a;', accept(statement));
      expect('final a;', accept(statement));
    });
    test('declaration (initialized)', () {
      expect('var a = b;', accept(statement));
      expect('final a = b;', accept(statement));
    });
    test('declaration (typed)', () {
      expect('a b;', accept(statement));
      expect('final a b;', accept(statement));
    });
    test('declaration (typed, initialized)', () {
      expect('a b = c;', accept(statement));
      expect('final a b = c;', accept(statement));
    });
    test('while', () {
      expect('while (a) {}', accept(statement));
    });
    test('do', () {
      expect('do {} while (b);', accept(statement));
    });
    test('for', () {
      expect('for (;;) {}', accept(statement));
      expect('for (var a = b; c; d++) {}', accept(statement));
      expect('for (var a = b, c = d; e; f++) {}', accept(statement));
      expect('for (a in b) {}', accept(statement));
    });
    test('if', () {
      expect('if (a) {}', accept(statement));
      expect('if (a) {} else {}', accept(statement));
      expect('if (a) {} else if (b) {}', accept(statement));
      expect('if (a) {} else if (b) {} else {}', accept(statement));
    });
    test('switch', () {
      expect('switch (a) {}', accept(statement));
      expect('switch (a) { case b: {} }', accept(statement));
      expect('switch (a) { case b: {} case d: {}}', accept(statement));
      expect('switch (a) { case b: {} default: {}}', accept(statement));
    });
    test('try', () {
      expect('try {} finally {}', accept(statement));
      expect('try {} catch (a b) {}', accept(statement));
      expect('try {} catch (a b, c d) {}', accept(statement));
      expect('try {} catch (a b) {} finally {}', accept(statement));
      expect('try {} catch (a b, c d) {} finally {}', accept(statement));
      expect('try {} catch (a b) {} catch (c d) {}', accept(statement));
      expect(
          'try {} catch (a b) {} catch (c d) {} finally {}', accept(statement));
    });
    test('break', () {
      expect('break;', accept(statement));
      expect('break a;', accept(statement));
    });
    test('continue', () {
      expect('continue;', accept(statement));
      expect('continue a;', accept(statement));
    });
    test('return', () {
      expect('return;', accept(statement));
      expect('return b;', accept(statement));
    });
    test('throw', () {
      expect('throw;', accept(statement));
      expect('throw b;', accept(statement));
    });
    test('expression', () {
      expect('a;', accept(statement));
      expect('a + b;', accept(statement));
    });
    test('assert', () {
      expect('assert(a);', accept(statement));
    });
    test('invokation', () {
      expect('a();', accept(statement));
      expect('a(b);', accept(statement));
      expect('a(b, c);', accept(statement));
      expect('a(b, c, d);', accept(statement));
    });
    test('invokation (named)', () {
      expect('a(b: c);', accept(statement));
      expect('a(b: c, d: e);', accept(statement));
      expect('a(b: c, d: e, f: g);', accept(statement));
    });
  });
  group('member', () {
    final member = grammar.build(start: grammar.classMemberDefinition).end();
    test('function', () {
      expect('a() {}', accept(member));
      expect('a b() {}', accept(member));
    });
    test('function (abstract)', () {
      expect('abstract a();', accept(member));
      expect('abstract a b();', accept(member));
    });
    test('function (static)', () {
      expect('static a() {}', accept(member));
      expect('static a b() {}', accept(member));
    });
    test('function (expression)', () {
      expect('a() => b;', accept(member));
      expect('a b() => c;', accept(member));
    });
    test('function arguments (plain)', () {
      expect('a() {}', accept(member));
      expect('a(b) {}', accept(member));
      expect('a(b, c) {}', accept(member));
      expect('a(b, c, d) {}', accept(member));
    });
    test('function arguments (optional)', () {
      expect('a([b]) {}', accept(member));
      expect('a([b, c]) {}', accept(member));
      expect('a(b, [c, d]) {}', accept(member));
      expect('a(b, c, [d, e]) {}', accept(member));
    });
    test('function arguments (optional, defaults)', () {
      expect('a([b = c]) {}', accept(member));
      expect('a([b = c, d = e]) {}', accept(member));
      expect('a(b, [c = d, e = f]) {}', accept(member));
      expect('a(b, c, [d = e, f = g]) {}', accept(member));
    });
    test('function arguments (named)', () {
      expect('a({b}) {}', accept(member));
      expect('a({b, c}) {}', accept(member));
      expect('a(b, {c, d}) {}', accept(member));
      expect('a(b, c, {d, e}) {}', accept(member));
    });
    test('function arguments (named, defaults)', () {
      expect('a({b: c}) {}', accept(member));
      expect('a({b: c, d: e}) {}', accept(member));
      expect('a(b, {c: d, e: f}) {}', accept(member));
      expect('a(b, c, {d: e, f: g}) {}', accept(member));
    });
    test('constructor', () {
      expect('A();', accept(member));
      expect('A() {}', accept(member));
      expect('A() : super();', accept(member));
      expect('A() : super() {}', accept(member));
      expect('A() : super(), a = b;', accept(member));
      expect('A() : super(), a = b {}', accept(member));
      expect('A() : super(), a = b, c = d;', accept(member));
      expect('A() : super(), a = b, c = d {}', accept(member));
    });
    test('constructor (field)', () {
      expect('A(this.a);', accept(member));
      expect('A(this.a) {}', accept(member));
      expect('A(this.a, this.b);', accept(member));
      expect('A(this.a, this.b) {}', accept(member));
    });
    test('constructor (const)', () {
      expect('const A();', accept(member));
      expect('const A._();', accept(member));
    });
    test('constructor (named)', () {
      expect('A._() {}', accept(member));
      expect('A._() : super();', accept(member));
      expect('A._() : super() {}', accept(member));
      expect('A._() : super(), a = b;', accept(member));
      expect('A._() : super(), a = b {}', accept(member));
      expect('A._() : super(), a = b, c = d;', accept(member));
      expect('A._() : super(), a = b, c = d {}', accept(member));
    });
    test('constructor (factory)', () {
      expect('factory A() {}', accept(member));
    });
    test('constructor (factory, named)', () {
      expect('factory A._() {}', accept(member));
    });
  });
  group('definition', () {
    final definition = grammar.build(start: grammar.topLevelDefinition).end();
    test('class', () {
      expect('class A {}', accept(definition));
      expect('class A extends B {}', accept(definition));
      expect('class A implements B {}', accept(definition));
      expect('class A implements B, C {}', accept(definition));
      expect('class A extends B implements C {}', accept(definition));
      expect('class A extends B implements C, D {}', accept(definition));
    });
    test('class (typed)', () {
      expect('class A<T> {}', accept(definition));
      expect('class A<T> extends B<T> {}', accept(definition));
      expect('class A<T> implements B<T> {}', accept(definition));
      expect('class A<T> implements B<T>, C<T> {}', accept(definition));
      expect('class A<T> extends B<T> implements C<T> {}', accept(definition));
      expect('class A<T> extends B<T> implements C<T>, D<T> {}',
          accept(definition));
    });
    test('class (abstract)', () {
      expect('abstract class A {}', accept(definition));
      expect('abstract class A extends B {}', accept(definition));
      expect('abstract class A implements B {}', accept(definition));
      expect('abstract class A implements B, C {}', accept(definition));
      expect('abstract class A extends B implements C {}', accept(definition));
      expect(
          'abstract class A extends B implements C, D {}', accept(definition));
    });
    test('typedef', () {
      expect('typedef a b();', accept(definition));
      expect('typedef a b(c);', accept(definition));
      expect('typedef a b(c d);', accept(definition));
    });
    test('typedef (typed)', () {
      expect('typedef a b<T>();', accept(definition));
      expect('typedef a b<T>(c);', accept(definition));
      expect('typedef a b<T>(c d);', accept(definition));
    });
    test('final', () {
      expect('final a = 0;', accept(definition));
      expect('final a b = 0;', accept(definition));
    });
    test('const', () {
      expect('const a = 0;', accept(definition));
      expect('const a b = 0;', accept(definition));
    });
  });
  group('whitespace', () {
    final whitespaces = grammar.build(start: grammar.HIDDEN).end();
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
      expect(
          '/* outer /* nested /* deeply nested */ */ */', accept(whitespaces));
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
    final parser = grammar.build(start: grammar.STRING).end();
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
      final parser = grammar.build(start: grammar.identifier).end();
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
      final parser = grammar.build(start: grammar.literal).end();
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
      final parser = grammar.build(start: grammar.literal).end();
      expect('true', accept(parser));
      expect('false', accept(parser));
      expect(' true', accept(parser));
      expect(' false', accept(parser));
    });
  });
}
