import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('any', () {
    expectParserInvariants(any());
    test('default', () {
      final parser = any();
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('', message: 'input expected'));
    });
  });
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
    test('convert empty', () {
      final parser = ''.toParser();
      expect(parser, isParseSuccess('', result: ''));
    });
    test('convert single char', () {
      final parser = 'a'.toParser();
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('A', message: '"a" expected'));
    });
    test('convert single char (case-insensitive)', () {
      final parser = 'a'.toParser(ignoreCase: true);
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser,
          isParseFailure('b', message: '"a" (case-insensitive) expected'));
    });
    test('convert pattern', () {
      final parser = 'a-z'.toParser(isPattern: true);
      expect(parser, isParseSuccess('x', result: 'x'));
      expect(parser, isParseFailure('X', message: '[a-z] expected'));
    });
    test('convert pattern (case-insensitive)', () {
      final parser = 'a-z'.toParser(isPattern: true, ignoreCase: true);
      expect(parser, isParseSuccess('x', result: 'x'));
      expect(parser, isParseSuccess('X', result: 'X'));
      expect(parser,
          isParseFailure('1', message: '[a-z] (case-insensitive) expected'));
    });
    test('convert multiple chars', () {
      final parser = 'foo'.toParser();
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseFailure('Foo', message: '"foo" expected'));
    });
    test('convert multiple chars (case-insensitive)', () {
      final parser = 'foo'.toParser(ignoreCase: true);
      expect(parser, isParseSuccess('foo', result: 'foo'));
      expect(parser, isParseSuccess('Foo', result: 'Foo'));
      expect(parser,
          isParseFailure('bar', message: '"foo" (case-insensitive) expected'));
    });
  });
  group('stringIgnoreCase', () {
    expectParserInvariants(string('foo', ignoreCase: true));
    test('default', () {
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
}
