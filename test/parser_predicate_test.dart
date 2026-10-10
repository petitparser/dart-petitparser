import 'dart:typed_data';

import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/src/parser/character/predicate/char.dart';
import 'package:petitparser/src/parser/character/predicate/constant.dart';
import 'package:petitparser/src/parser/character/predicate/lookup.dart';
import 'package:petitparser/src/parser/character/predicate/range.dart';
import 'package:test/scaffolding.dart';

import 'utils/assertions.dart';
import 'utils/checks.dart';

void main() {
  group('character', () {
    const predicate = ConstantCharPredicate.any;
    test('single character', () {
      final parser = SingleCharacterParser.internal(
        predicate,
        'single character',
      );
      for (var code = 0; code < 0xffff; code++) {
        final char = String.fromCharCode(code);
        check(parser).parseSuccess(char, result: char);
      }
    });
    test('any single character', () {
      final parser = AnySingleCharacterParser.internal(
        predicate,
        'any single character',
      );
      for (var code = 0; code < 0xffff; code++) {
        final char = String.fromCharCode(code);
        check(parser).parseSuccess(char, result: char);
      }
    });
    test('unicode character', () {
      final parser = UnicodeCharacterParser.internal(
        predicate,
        'unicode character',
      );
      for (var code = 0; code < 0x10ffff; code++) {
        final char = String.fromCharCode(code);
        check(parser).parseSuccess(char, result: char);
      }
    });
    test('any unicode character', () {
      final parser = AnyUnicodeCharacterParser.internal(
        predicate,
        'any unicode character',
      );
      for (var code = 0; code < 0x10ffff; code++) {
        final char = String.fromCharCode(code);
        check(parser).parseSuccess(char, result: char);
      }
    });
  });
  group('pattern', () {
    expectParserInvariants(PatternParser('42', 'number expected'));
    test('string', () {
      final parser = PatternParser('42', 'number expected');
      check(parser).parseSuccess(
        '42',
        result: (Subject<Match> it) =>
            it.isPatternMatch('42', start: 0, end: 2),
      );
      check(parser).parseFailure('4', message: 'number expected');
      check(parser).parseFailure('43', message: 'number expected');
    });
    test('regexp', () {
      final parser = PatternParser(RegExp(r'\d+'), 'digits expected');
      check(parser).parseSuccess(
        '1',
        result: (Subject<Match> it) => it.isPatternMatch('1', start: 0, end: 1),
      );
      check(parser).parseSuccess(
        '12',
        result: (Subject<Match> it) =>
            it.isPatternMatch('12', start: 0, end: 2),
      );
      check(parser).parseSuccess(
        '123',
        result: (Subject<Match> it) =>
            it.isPatternMatch('123', start: 0, end: 3),
      );
      check(parser).parseSuccess(
        '1a',
        result: (Subject<Match> it) => it.isPatternMatch('1', start: 0, end: 1),
        position: 1,
      );
      check(parser).parseFailure('');
      check(parser).parseFailure('a');
      check(parser).parseFailure('a1');
    });
    test('regexp groups', () {
      final parser = PatternParser(
        RegExp(r'(\d+)\s*,\s*(\d+)'),
        'pair expected',
      );
      check(parser).parseSuccess(
        '1,2',
        result: (Subject<Match> it) =>
            it.isPatternMatch('1,2', groups: ['1', '2']),
      );
      check(parser).parseSuccess(
        '1, 2',
        result: (Subject<Match> it) =>
            it.isPatternMatch('1, 2', groups: ['1', '2']),
      );
      check(parser).parseSuccess(
        '1 ,2',
        result: (Subject<Match> it) =>
            it.isPatternMatch('1 ,2', groups: ['1', '2']),
      );
      check(parser).parseSuccess(
        '1 , 2',
        result: (Subject<Match> it) =>
            it.isPatternMatch('1 , 2', groups: ['1', '2']),
      );
      check(parser).parseSuccess(
        '12,3',
        result: (Subject<Match> it) =>
            it.isPatternMatch('12,3', groups: ['12', '3']),
      );
      check(parser).parseSuccess(
        '12, 3',
        result: (Subject<Match> it) =>
            it.isPatternMatch('12, 3', groups: ['12', '3']),
      );
      check(parser).parseSuccess(
        '12 ,3',
        result: (Subject<Match> it) =>
            it.isPatternMatch('12 ,3', groups: ['12', '3']),
      );
    });
  });
  group('string', () {
    expectParserInvariants(string('foo'));
    test('default', () {
      final parser = string('foo');
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseFailure('', message: '"foo" expected');
      check(parser).parseFailure('f', message: '"foo" expected');
      check(parser).parseFailure('fo', message: '"foo" expected');
      check(parser).parseFailure('Foo', message: '"foo" expected');
    });
    test('message', () {
      final parser = string('foo', message: 'special expected');
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseFailure('', message: 'special expected');
      check(parser).parseFailure('f', message: 'special expected');
      check(parser).parseFailure('fo', message: 'special expected');
      check(parser).parseFailure('Foo', message: 'special expected');
    });
  });
  group('string (ignore-case)', () {
    expectParserInvariants(string('foo', ignoreCase: true));
    test('default', () {
      final parser = string('foo', ignoreCase: true);
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseSuccess('FOO', result: 'FOO');
      check(parser).parseSuccess('fOo', result: 'fOo');
      check(parser)
          .parseFailure('', message: '"foo" (case-insensitive) expected');
      check(parser)
          .parseFailure('f', message: '"foo" (case-insensitive) expected');
      check(parser)
          .parseFailure('fo', message: '"foo" (case-insensitive) expected');
      check(parser)
          .parseFailure('foc', message: '"foo" (case-insensitive) expected');
    });
    test('message', () {
      final parser = string('foo', message: 'special expected');
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseFailure('', message: 'special expected');
      check(parser).parseFailure('f', message: 'special expected');
      check(parser).parseFailure('fo', message: 'special expected');
      check(parser).parseFailure('Foc', message: 'special expected');
    });
  });
  group('predicate', () {
    final parser = predicate(3, (value) => value == 'foo', 'foo expected');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('foo', result: 'foo');
    });
    test('failure (predicate)', () {
      check(parser).parseFailure('bar', message: 'foo expected');
    });
    test('failure (length)', () {
      check(parser).parseFailure('fo', message: 'foo expected');
    });
  });
  group('convert', () {
    test('empty', () {
      final parser = ''.toParser();
      check(parser).isA<EpsilonParser<String>>();
      check(parser).parseSuccess('', result: '');
    });
    test('single char', () {
      final parser = 'a'.toParser();
      check(parser)
          .isA<SingleCharacterParser>()
          .isCharacterParser(predicate: const SingleCharPredicate(97));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseFailure('A', message: '"a" expected');
    });
    test('single char (message)', () {
      final parser = 'a'.toParser(message: 'first letter');
      check(parser)
          .isA<SingleCharacterParser>()
          .isCharacterParser(predicate: const SingleCharPredicate(97));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseFailure('A', message: 'first letter');
    });
    test('single char (case-insensitive)', () {
      final parser = 'a'.toParser(ignoreCase: true);
      check(parser).isA<SingleCharacterParser>().isCharacterParser(
        predicate: LookupCharPredicate(65, 97, Uint32List.fromList([1, 1])),
      );
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('A', result: 'A');
      check(parser)
          .parseFailure('b', message: '"a" (case-insensitive) expected');
    });
    test('single char (unicode)', () {
      final parser = '🂓'.toParser(unicode: true);
      check(parser)
          .isA<UnicodeCharacterParser>()
          .isCharacterParser(predicate: const SingleCharPredicate(127123));
      check(parser).parseSuccess('🂓', result: '🂓');
      check(parser).parseFailure('b', message: '"🂓" expected');
    });
    test('pattern', () {
      final parser = 'a-z'.toParser(isPattern: true);
      check(parser)
          .isA<SingleCharacterParser>()
          .isCharacterParser(predicate: const RangeCharPredicate(97, 122));
      check(parser).parseSuccess('x', result: 'x');
      check(parser).parseFailure('X', message: '[a-z] expected');
    });
    test('pattern (message)', () {
      final parser = 'a-z'.toParser(
        isPattern: true,
        message: 'letter expected',
      );
      check(parser)
          .isA<SingleCharacterParser>()
          .isCharacterParser(predicate: const RangeCharPredicate(97, 122));
      check(parser).parseSuccess('x', result: 'x');
      check(parser).parseFailure('1', message: 'letter expected');
    });
    test('pattern (case-insensitive)', () {
      final parser = 'a-z'.toParser(isPattern: true, ignoreCase: true);
      check(parser).isA<SingleCharacterParser>().isCharacterParser(
        predicate: LookupCharPredicate(
          65,
          122,
          Uint32List.fromList([67108863, 67108863]),
        ),
      );
      check(parser).parseSuccess('x', result: 'x');
      check(parser).parseSuccess('X', result: 'X');
      check(parser)
          .parseFailure('1', message: '[a-z] (case-insensitive) expected');
    });
    test('pattern (unicode)', () {
      final parser = '🂡-🂪'.toParser(isPattern: true, unicode: true);
      check(parser).isA<UnicodeCharacterParser>().isCharacterParser(
        predicate: const RangeCharPredicate(127137, 127146),
      );
      check(parser).parseSuccess('🂡', result: '🂡');
      check(parser).parseSuccess('🂧', result: '🂧');
      check(parser).parseFailure('🂓', message: '[🂡-🂪] expected');
    });
    test('string', () {
      final parser = 'foo'.toParser();
      check(parser).isA<StringParser>();
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseFailure('Foo', message: '"foo" expected');
    });
    test('string (message)', () {
      final parser = 'foo'.toParser(message: 'special expected');
      check(parser).isA<StringParser>();
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseFailure('bar', message: 'special expected');
    });
    test('string (case-insensitive)', () {
      final parser = 'foo'.toParser(ignoreCase: true);
      check(parser).isA<StringIgnoreCaseParser>();
      check(parser).parseSuccess('foo', result: 'foo');
      check(parser).parseSuccess('Foo', result: 'Foo');
      check(parser)
          .parseFailure('bar', message: '"foo" (case-insensitive) expected');
    });
  });
}
