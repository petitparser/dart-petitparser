import 'dart:typed_data';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/src/parser/character/predicates/char.dart';
import 'package:petitparser/src/parser/character/predicates/lookup.dart';
import 'package:petitparser/src/parser/character/predicates/range.dart';
import 'package:petitparser/src/parser/predicate/single_character.dart';
import 'package:petitparser/src/parser/predicate/unicode_character.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('pattern', () {
    expectParserInvariants(PatternParser('42', 'number expected'));
    test('string', () {
      final parser = PatternParser('42', 'number expected');
      expect(parser,
          isParseSuccess('42', result: isPatternMatch('42', start: 0, end: 2)));
      expect(parser, isParseFailure('4', message: 'number expected'));
      expect(parser, isParseFailure('43', message: 'number expected'));
    });
    test('regexp', () {
      final parser = PatternParser(RegExp(r'\d+'), 'digits expected');
      expect(
        parser,
        isParseSuccess('1', result: isPatternMatch('1', start: 0, end: 1)),
      );
      expect(
        parser,
        isParseSuccess('12', result: isPatternMatch('12', start: 0, end: 2)),
      );
      expect(
        parser,
        isParseSuccess('123', result: isPatternMatch('123', start: 0, end: 3)),
      );
      expect(
        parser,
        isParseSuccess('1a',
            result: isPatternMatch('1', start: 0, end: 1), position: 1),
      );
      expect(parser, isParseFailure(''));
      expect(parser, isParseFailure('a'));
      expect(parser, isParseFailure('a1'));
    });
    test('regexp groups', () {
      final parser =
          PatternParser(RegExp(r'(\d+)\s*,\s*(\d+)'), 'pair expected');
      expect(
        parser,
        isParseSuccess('1,2',
            result: isPatternMatch('1,2', groups: ['1', '2'])),
      );
      expect(
        parser,
        isParseSuccess('1, 2',
            result: isPatternMatch('1, 2', groups: ['1', '2'])),
      );
      expect(
        parser,
        isParseSuccess('1 ,2',
            result: isPatternMatch('1 ,2', groups: ['1', '2'])),
      );
      expect(
        parser,
        isParseSuccess('1 , 2',
            result: isPatternMatch('1 , 2', groups: ['1', '2'])),
      );
      expect(
        parser,
        isParseSuccess('12,3',
            result: isPatternMatch('12,3', groups: ['12', '3'])),
      );
      expect(
        parser,
        isParseSuccess('12, 3',
            result: isPatternMatch('12, 3', groups: ['12', '3'])),
      );
      expect(
        parser,
        isParseSuccess('12 ,3',
            result: isPatternMatch('12 ,3', groups: ['12', '3'])),
      );
    });
  });
  group('string', () {
    expectParserInvariants(string('foo'));
    test('default', () {
      final parser = string('foo');
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseFailure('', message: '"foo" expected'));
      expect(parser, isParseFailure('f', message: '"foo" expected'));
      expect(parser, isParseFailure('fo', message: '"foo" expected'));
      expect(parser, isParseFailure('Foo', message: '"foo" expected'));
    });
    test('message', () {
      final parser = string('foo', message: 'special expected');
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseFailure('', message: 'special expected'));
      expect(parser, isParseFailure('f', message: 'special expected'));
      expect(parser, isParseFailure('fo', message: 'special expected'));
      expect(parser, isParseFailure('Foo', message: 'special expected'));
    });
    test('ignore-case', () {
      final parser = string('foo', ignoreCase: true);
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseSuccess('FOO', result: 'FOO'));
      expect(parser, isParseSuccess('fOo', result: 'fOo'));
      expect(parser,
          isParseFailure('', message: '"foo" (case-insensitive) expected'));
      expect(parser,
          isParseFailure('f', message: '"foo" (case-insensitive) expected'));
      expect(parser,
          isParseFailure('Fo', message: '"foo" (case-insensitive) expected'));
    });
  });
  group('convert', () {
    test('empty', () {
      final parser = ''.toParser();
      expect(parser, isA<EpsilonParser<String>>());
      expect(parser, isParseSuccess('', result: ''));
    });
    test('single char', () {
      final parser = 'a'.toParser();
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate: const SingleCharPredicate(97)));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('A', message: '"a" expected'));
    });
    test('single char (message)', () {
      final parser = 'a'.toParser(message: 'first letter');
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate: const SingleCharPredicate(97)));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('A', message: 'first letter'));
    });
    test('single char (case-insensitive)', () {
      final parser = 'a'.toParser(ignoreCase: true);
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate:
                  LookupCharPredicate(65, 97, Uint32List.fromList([1, 1]))));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser,
          isParseFailure('b', message: '"a" (case-insensitive) expected'));
    });
    test('single char (unicode)', () {
      final parser = '🂓'.toParser(unicode: true);
      expect(
          parser,
          isCharacterParser<UnicodeCharacterParser>(
              predicate: const SingleCharPredicate(127123)));
      expect(parser, isParseSuccess('🂓', result: '🂓'));
      expect(parser, isParseFailure('b', message: '"🂓" expected'));
    });
    test('pattern', () {
      final parser = 'a-z'.toParser(isPattern: true);
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate: const RangeCharPredicate(97, 122)));
      expect(parser, isParseSuccess('x', result: 'x'));
      expect(parser, isParseFailure('X', message: '[a-z] expected'));
    });
    test('pattern (message)', () {
      final parser =
          'a-z'.toParser(isPattern: true, message: 'letter expected');
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate: const RangeCharPredicate(97, 122)));
      expect(parser, isParseSuccess('x', result: 'x'));
      expect(parser, isParseFailure('1', message: 'letter expected'));
    });
    test('pattern (case-insensitive)', () {
      final parser = 'a-z'.toParser(isPattern: true, ignoreCase: true);
      expect(
          parser,
          isCharacterParser<SingleCharacterParser>(
              predicate: LookupCharPredicate(
                  65, 122, Uint32List.fromList([67108863, 67108863]))));
      expect(parser, isParseSuccess('x', result: 'x'));
      expect(parser, isParseSuccess('X', result: 'X'));
      expect(parser,
          isParseFailure('1', message: '[a-z] (case-insensitive) expected'));
    });
    test('pattern (unicode)', () {
      final parser = '🂡-🂪'.toParser(isPattern: true, unicode: true);
      expect(
          parser,
          isCharacterParser<UnicodeCharacterParser>(
              predicate: const RangeCharPredicate(127137, 127146)));
      expect(parser, isParseSuccess('🂡', result: '🂡'));
      expect(parser, isParseSuccess('🂧', result: '🂧'));
      expect(parser, isParseFailure('🂓', message: '[🂡-🂪] expected'));
    });
    test('string', () {
      final parser = 'foo'.toParser();
      expect(parser, isA<PredicateParser>());
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseFailure('Foo', message: '"foo" expected'));
    });
    test('string (message)', () {
      final parser = 'foo'.toParser(message: 'special expected');
      expect(parser, isA<PredicateParser>());
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseFailure('bar', message: 'special expected'));
    });
    test('string (case-insensitive)', () {
      final parser = 'foo'.toParser(ignoreCase: true);
      expect(parser, isA<PredicateParser>());
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseSuccess('Foo', result: 'Foo'));
      expect(parser,
          isParseFailure('bar', message: '"foo" (case-insensitive) expected'));
    });
  });
}
