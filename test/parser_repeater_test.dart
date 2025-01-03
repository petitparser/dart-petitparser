import 'package:petitparser/petitparser.dart';
import 'package:petitparser/src/parser/character/predicates/char.dart';
import 'package:petitparser/src/parser/character/predicates/constant.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('greedy', () {
    expectParserInvariants(any().starGreedy(digit()));
    test('star', () {
      final parser = word().starGreedy(digit());
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
      expect(parser, isParseFailure('ab', message: 'digit expected'));
      expect(parser, isParseSuccess('1', result: isEmpty, position: 0));
      expect(parser, isParseSuccess('a1', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('12', result: ['1'], position: 1));
      expect(parser, isParseSuccess('a12', result: ['a', '1'], position: 2));
      expect(
          parser, isParseSuccess('ab12', result: ['a', 'b', '1'], position: 3));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4));
      expect(parser, isParseSuccess('123', result: ['1', '2'], position: 2));
      expect(
          parser, isParseSuccess('a123', result: ['a', '1', '2'], position: 3));
      expect(parser,
          isParseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4));
      expect(
          parser,
          isParseSuccess('abc123',
              result: ['a', 'b', 'c', '1', '2'], position: 5));
    });
    test('plus', () {
      final parser = word().plusGreedy(digit());
      expect(parser, isParseFailure('', message: 'letter or digit expected'));
      expect(
          parser, isParseFailure('a', position: 1, message: 'digit expected'));
      expect(
          parser, isParseFailure('ab', position: 1, message: 'digit expected'));
      expect(
          parser, isParseFailure('1', position: 1, message: 'digit expected'));
      expect(parser, isParseSuccess('a1', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('12', result: ['1'], position: 1));
      expect(parser, isParseSuccess('a12', result: ['a', '1'], position: 2));
      expect(
          parser, isParseSuccess('ab12', result: ['a', 'b', '1'], position: 3));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4));
      expect(parser, isParseSuccess('123', result: ['1', '2'], position: 2));
      expect(
          parser, isParseSuccess('a123', result: ['a', '1', '2'], position: 3));
      expect(parser,
          isParseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4));
      expect(
          parser,
          isParseSuccess('abc123',
              result: ['a', 'b', 'c', '1', '2'], position: 5));
    });
    test('repeat', () {
      final parser = word().repeatGreedy(digit(), 2, 4);
      expect(parser, isParseFailure('', message: 'letter or digit expected'));
      expect(
          parser,
          isParseFailure('a',
              position: 1, message: 'letter or digit expected'));
      expect(
          parser, isParseFailure('ab', position: 2, message: 'digit expected'));
      expect(parser,
          isParseFailure('abc', position: 2, message: 'digit expected'));
      expect(parser,
          isParseFailure('abcd', position: 2, message: 'digit expected'));
      expect(parser,
          isParseFailure('abcde', position: 2, message: 'digit expected'));
      expect(
          parser,
          isParseFailure('1',
              position: 1, message: 'letter or digit expected'));
      expect(
          parser, isParseFailure('a1', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser,
          isParseSuccess('abcd1', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde1', position: 2, message: 'digit expected'));
      expect(
          parser, isParseFailure('12', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('a12', result: ['a', '1'], position: 2));
      expect(
          parser, isParseSuccess('ab12', result: ['a', 'b', '1'], position: 3));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4));
      expect(parser,
          isParseSuccess('abcd12', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde12', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('123', result: ['1', '2'], position: 2));
      expect(
          parser, isParseSuccess('a123', result: ['a', '1', '2'], position: 3));
      expect(parser,
          isParseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4));
      expect(parser,
          isParseSuccess('abc123', result: ['a', 'b', 'c', '1'], position: 4));
      expect(parser,
          isParseSuccess('abcd123', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde123', position: 2, message: 'digit expected'));
    });
    test('repeat unbounded', () {
      final inputLetter = List.filled(100000, 'a');
      final inputDigit = List.filled(100000, '1');
      final parser = word().repeatGreedy(digit(), 2, unbounded);
      expect(
          parser,
          isParseSuccess('${inputLetter.join()}1',
              result: inputLetter, position: inputLetter.length));
      expect(
          parser,
          isParseSuccess('${inputDigit.join()}1',
              result: inputDigit, position: inputDigit.length));
    });
    test('infinite loop', () {
      final inner = epsilon(), limiter = failure<void>();
      expect(
          () => inner.starGreedy(limiter).parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.starGreedy(limiter).fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plusGreedy(limiter).parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plusGreedy(limiter).fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
    }, skip: !hasAssertionsEnabled());
  });
  group('lazy', () {
    expectParserInvariants(any().starLazy(digit()));
    test('star', () {
      final parser = word().starLazy(digit());
      expect(parser, isParseFailure(''));
      expect(
          parser, isParseFailure('a', position: 1, message: 'digit expected'));
      expect(
          parser, isParseFailure('ab', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('1', result: isEmpty, position: 0));
      expect(parser, isParseSuccess('a1', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('12', result: isEmpty, position: 0));
      expect(parser, isParseSuccess('a12', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab12', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('123', result: isEmpty, position: 0));
      expect(parser, isParseSuccess('a123', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab123', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc123', result: ['a', 'b', 'c'], position: 3));
    });
    test('plus', () {
      final parser = word().plusLazy(digit());
      expect(parser, isParseFailure(''));
      expect(
          parser, isParseFailure('a', position: 1, message: 'digit expected'));
      expect(
          parser, isParseFailure('ab', position: 2, message: 'digit expected'));
      expect(
          parser, isParseFailure('1', position: 1, message: 'digit expected'));
      expect(parser, isParseSuccess('a1', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('12', result: ['1'], position: 1));
      expect(parser, isParseSuccess('a12', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab12', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c'], position: 3));
      expect(parser, isParseSuccess('123', result: ['1'], position: 1));
      expect(parser, isParseSuccess('a123', result: ['a'], position: 1));
      expect(parser, isParseSuccess('ab123', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc123', result: ['a', 'b', 'c'], position: 3));
    });
    test('repeat', () {
      final parser = word().repeatLazy(digit(), 2, 4);
      expect(parser, isParseFailure('', message: 'letter or digit expected'));
      expect(
          parser,
          isParseFailure('a',
              position: 1, message: 'letter or digit expected'));
      expect(
          parser, isParseFailure('ab', position: 2, message: 'digit expected'));
      expect(parser,
          isParseFailure('abc', position: 3, message: 'digit expected'));
      expect(parser,
          isParseFailure('abcd', position: 4, message: 'digit expected'));
      expect(parser,
          isParseFailure('abcde', position: 4, message: 'digit expected'));
      expect(
          parser,
          isParseFailure('1',
              position: 1, message: 'letter or digit expected'));
      expect(
          parser, isParseFailure('a1', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('ab1', result: ['a', 'b'], position: 2));
      expect(
          parser, isParseSuccess('abc1', result: ['a', 'b', 'c'], position: 3));
      expect(parser,
          isParseSuccess('abcd1', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde1', position: 4, message: 'digit expected'));
      expect(
          parser, isParseFailure('12', position: 2, message: 'digit expected'));
      expect(parser, isParseSuccess('a12', result: ['a', '1'], position: 2));
      expect(parser, isParseSuccess('ab12', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc12', result: ['a', 'b', 'c'], position: 3));
      expect(parser,
          isParseSuccess('abcd12', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde12', position: 4, message: 'digit expected'));
      expect(parser, isParseSuccess('123', result: ['1', '2'], position: 2));
      expect(parser, isParseSuccess('a123', result: ['a', '1'], position: 2));
      expect(parser, isParseSuccess('ab123', result: ['a', 'b'], position: 2));
      expect(parser,
          isParseSuccess('abc123', result: ['a', 'b', 'c'], position: 3));
      expect(parser,
          isParseSuccess('abcd123', result: ['a', 'b', 'c', 'd'], position: 4));
      expect(parser,
          isParseFailure('abcde123', position: 4, message: 'digit expected'));
    });
    test('repeat unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = word().repeatLazy(digit(), 2, unbounded);
      expect(
          parser,
          isParseSuccess('${input.join()}1111',
              result: input, position: input.length));
    });
    test('infinite loop', () {
      final inner = epsilon(), limiter = failure<void>();
      expect(
          () => inner.starLazy(limiter).parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.starLazy(limiter).fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plusLazy(limiter).parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plusLazy(limiter).fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
    }, skip: !hasAssertionsEnabled());
  });
  group('possessive', () {
    expectParserInvariants(any().star());
    test('star', () {
      final parser = char('a').star();
      expect(parser, isParseSuccess('', result: isEmpty));
      expect(parser, isParseSuccess('a', result: ['a']));
      expect(parser, isParseSuccess('aa', result: ['a', 'a']));
      expect(parser, isParseSuccess('aaa', result: ['a', 'a', 'a']));
    });
    test('plus', () {
      final parser = char('a').plus();
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseSuccess('a', result: ['a']));
      expect(parser, isParseSuccess('aa', result: ['a', 'a']));
      expect(parser, isParseSuccess('aaa', result: ['a', 'a', 'a']));
    });
    test('times', () {
      final parser = char('a').times(2);
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: ['a', 'a']));
      expect(parser, isParseSuccess('aaa', result: ['a', 'a'], position: 2));
    });
    test('repeat', () {
      final parser = char('a').repeat(2, 3);
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: ['a', 'a']));
      expect(parser, isParseSuccess('aaa', result: ['a', 'a', 'a']));
      expect(
          parser, isParseSuccess('aaaa', result: ['a', 'a', 'a'], position: 3));
    });
    test('repeat unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = char('a').repeat(2, unbounded);
      expect(parser, isParseSuccess(input.join(), result: input));
    });
    test('repeat erroneous', () {
      expect(
          () => char('a').repeat(-1, 1),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'min must be at least 0, but got -1')));
      expect(
          () => char('a').repeat(2, 1),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'max must be at least 2, but got 1')));
    }, skip: !hasAssertionsEnabled());
    test('times', () {
      final parser = char('a').times(2);
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: ['a', 'a']));
      expect(parser, isParseSuccess('aaa', result: ['a', 'a'], position: 2));
    });
    test('infinite loop', () {
      final inner = epsilon();
      expect(
          () => inner.star().parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.star().fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plus().parse(''),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
      expect(
          () => inner.plus().fastParseOn('', 0),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', '$inner must always consume')));
    }, skip: !hasAssertionsEnabled());
  });
  group('string', () {
    expectParserInvariants(any().starString());
    test('star', () {
      final parser = char('a').starString();
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseSuccess('', result: ''));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
    });
    test('plus', () {
      final parser = char('a').plusString();
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
    });
    test('times', () {
      final parser = char('a').timesString(2);
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aa', position: 2));
    });
    test('repeat', () {
      final parser = char('a').repeatString(2, 3);
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
      expect(parser, isParseSuccess('aaaa', result: 'aaa', position: 3));
    });
    test('repeat unbounded', () {
      final input = 'a' * 100000;
      final parser = char('a').repeatString(2, unbounded);
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseSuccess(input, result: input));
    });
    test('repeat erroneous', () {
      expect(
          () => char('a').repeatString(-1, 1),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'min must be at least 0, but got -1')));
      expect(
          () => char('a').repeatString(2, 1),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'max must be at least 2, but got 1')));
    }, skip: !hasAssertionsEnabled());
    test('times', () {
      final parser = char('a').timesString(2);
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<SingleCharPredicate>()));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('a', position: 1, message: '"a" expected'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aa', position: 2));
    });
    test('any', () {
      final parser = any().plusString();
      expect(
          parser,
          isA<RepeatingCharacterParser>().having((parser) => parser.predicate,
              'predicate', isA<ConstantCharPredicate>()));
      expect(parser, isParseFailure('', message: 'input expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
    });
    test('any (unicode)', () {
      final parser = any(unicode: true).plusString();
      expect(
          parser,
          isA<FlattenParser>().having((parser) => parser.delegate, 'delegate',
              isA<PossessiveRepeatingParser<String>>()));
      expect(parser, isParseFailure('', message: 'input expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
    });
    test('fallback', () {
      final parser = char('a').settable().plusString();
      expect(
          parser,
          isA<FlattenParser>().having((parser) => parser.delegate, 'delegate',
              isA<PossessiveRepeatingParser<String>>()));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('aa', result: 'aa'));
      expect(parser, isParseSuccess('aaa', result: 'aaa'));
    });
  });
  group('separated', () {
    expectParserInvariants(digit().starSeparated(letter()));
    test('star', () {
      final parser = digit().starSeparated(letter());
      expect(parser,
          isParseSuccess('', result: isSeparatedList<String, String>()));
      expect(
          parser,
          isParseSuccess('a',
              result: isSeparatedList<String, String>(), position: 0));
      expect(
          parser,
          isParseSuccess('1',
              result: isSeparatedList<String, String>(elements: ['1'])));
      expect(
          parser,
          isParseSuccess('1a',
              result: isSeparatedList<String, String>(elements: ['1']),
              position: 1));
      expect(
          parser,
          isParseSuccess('1a2',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a'])));
      expect(
          parser,
          isParseSuccess('1a2b',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a']),
              position: 3));
      expect(
          parser,
          isParseSuccess('1a2b3',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b'])));
      expect(
          parser,
          isParseSuccess('1a2b3c',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3', '4'],
                  separators: ['a', 'b', 'c'])));
      expect(
          parser,
          isParseSuccess('1a2b3c4d',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3', '4'], separators: ['a', 'b', 'c']),
              position: 7));
    });
    test('plus', () {
      final parser = digit().plusSeparated(letter());
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
      expect(
          parser,
          isParseSuccess('1',
              result: isSeparatedList<String, String>(elements: ['1'])));
      expect(
          parser,
          isParseSuccess('1a',
              result: isSeparatedList<String, String>(elements: ['1']),
              position: 1));
      expect(
          parser,
          isParseSuccess('1a2',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a'])));
      expect(
          parser,
          isParseSuccess('1a2b',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a']),
              position: 3));
      expect(
          parser,
          isParseSuccess('1a2b3',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b'])));
      expect(
          parser,
          isParseSuccess('1a2b3c',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3', '4'],
                  separators: ['a', 'b', 'c'])));
      expect(
          parser,
          isParseSuccess('1a2b3c4d',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3', '4'], separators: ['a', 'b', 'c']),
              position: 7));
    });
    test('times', () {
      final parser = digit().timesSeparated(letter(), 3);
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
      expect(
          parser, isParseFailure('1', message: 'letter expected', position: 1));
      expect(
          parser, isParseFailure('1a', message: 'digit expected', position: 2));
      expect(parser,
          isParseFailure('1a2', message: 'letter expected', position: 3));
      expect(parser,
          isParseFailure('1a2b', message: 'digit expected', position: 4));
      expect(
          parser,
          isParseSuccess('1a2b3',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b'])));
      expect(
          parser,
          isParseSuccess('1a2b3c',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4d',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
    });
    test('repeat', () {
      final parser = digit().repeatSeparated(letter(), 2, 3);
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
      expect(
          parser, isParseFailure('1', message: 'letter expected', position: 1));
      expect(
          parser, isParseFailure('1a', message: 'digit expected', position: 2));
      expect(
          parser,
          isParseSuccess('1a2',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a'])));
      expect(
          parser,
          isParseSuccess('1a2b',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2'], separators: ['a']),
              position: 3));
      expect(
          parser,
          isParseSuccess('1a2b3',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b'])));
      expect(
          parser,
          isParseSuccess('1a2b3c',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
      expect(
          parser,
          isParseSuccess('1a2b3c4d',
              result: isSeparatedList<String, String>(
                  elements: ['1', '2', '3'], separators: ['a', 'b']),
              position: 5));
    });
    group('separated list', () {
      final empty = SeparatedList<String, String>([], []);
      final single = SeparatedList<String, String>(['1'], []);
      final double = SeparatedList<String, String>(['1', '2'], ['+']);
      final triple = SeparatedList<String, String>(['1', '2', '3'], ['+', '-']);
      final quadruple =
          SeparatedList<String, String>(['1', '2', '3', '4'], ['+', '-', '*']);
      final mixed = SeparatedList<int, String>([1, 2, 3], ['+', '-']);
      String combinator(String first, String separator, String second) =>
          '($first$separator$second)';
      test('elements', () {
        expect(empty.elements, isEmpty);
        expect(single.elements, ['1']);
        expect(double.elements, ['1', '2']);
        expect(triple.elements, ['1', '2', '3']);
        expect(quadruple.elements, ['1', '2', '3', '4']);
        expect(mixed.elements, [1, 2, 3]);
      });
      test('separators', () {
        expect(empty.separators, isEmpty);
        expect(single.separators, isEmpty);
        expect(double.separators, ['+']);
        expect(triple.separators, ['+', '-']);
        expect(quadruple.separators, ['+', '-', '*']);
        expect(mixed.separators, ['+', '-']);
      });
      test('sequence', () {
        expect(empty.sequential, isEmpty);
        expect(single.sequential, ['1']);
        expect(double.sequential, ['1', '+', '2']);
        expect(triple.sequential, ['1', '+', '2', '-', '3']);
        expect(quadruple.sequential, ['1', '+', '2', '-', '3', '*', '4']);
        expect(mixed.sequential, [1, '+', 2, '-', 3]);
      });
      test('foldLeft', () {
        expect(() => empty.foldLeft(combinator), throwsStateError);
        expect(single.foldLeft(combinator), '1');
        expect(double.foldLeft(combinator), '(1+2)');
        expect(triple.foldLeft(combinator), '((1+2)-3)');
        expect(quadruple.foldLeft(combinator), '(((1+2)-3)*4)');
      });
      test('foldRight', () {
        expect(() => empty.foldRight(combinator), throwsStateError);
        expect(single.foldRight(combinator), '1');
        expect(double.foldRight(combinator), '(1+2)');
        expect(triple.foldRight(combinator), '(1+(2-3))');
        expect(quadruple.foldRight(combinator), '(1+(2-(3*4)))');
      });
      test('toString', () {
        expect(empty.toString(),
            stringContainsInOrder(['SeparatedList', '<String, String>()']));
        expect(single.toString(),
            stringContainsInOrder(['SeparatedList', '<String, String>(1)']));
        expect(double.toString(),
            stringContainsInOrder(['SeparatedList', '(1, +, 2)']));
        expect(triple.toString(),
            stringContainsInOrder(['SeparatedList', '(1, +, 2, -, 3)']));
        expect(quadruple.toString(),
            stringContainsInOrder(['SeparatedList', '(1, +, 2, -, 3, *, 4)']));
        expect(mixed.toString(),
            stringContainsInOrder(['SeparatedList', '(1, +, 2, -, 3)']));
      });
    });
  });
}
