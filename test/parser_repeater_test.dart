import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/src/parser/character/predicate/char.dart';
import 'package:petitparser/src/parser/character/predicate/constant.dart';
import 'package:test/scaffolding.dart';

import 'utils/assertions.dart';
import 'utils/checks.dart';

void main() {
  group('greedy', () {
    expectParserInvariants(any().starGreedy(digit()));
    test('star', () {
      final parser = word().starGreedy(digit());
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      check(parser).parseFailure('ab', message: 'digit expected');
      check(parser).parseSuccess('1', result: <String>[], position: 0);
      check(parser).parseSuccess('a1', result: ['a'], position: 1);
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('12', result: ['1'], position: 1);
      check(parser).parseSuccess('a12', result: ['a', '1'], position: 2);
      check(parser).parseSuccess('ab12', result: ['a', 'b', '1'], position: 3);
      check(parser)
          .parseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4);
      check(parser).parseSuccess('123', result: ['1', '2'], position: 2);
      check(parser).parseSuccess('a123', result: ['a', '1', '2'], position: 3);
      check(parser)
          .parseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4);
      check(
        parser,
      ).parseSuccess('abc123', result: ['a', 'b', 'c', '1', '2'], position: 5);
    });
    test('plus', () {
      final parser = word().plusGreedy(digit());
      check(parser).parseFailure('', message: 'letter or digit expected');
      check(parser).parseFailure('a', position: 1, message: 'digit expected');
      check(parser).parseFailure('ab', position: 1, message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'digit expected');
      check(parser).parseSuccess('a1', result: ['a'], position: 1);
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('12', result: ['1'], position: 1);
      check(parser).parseSuccess('a12', result: ['a', '1'], position: 2);
      check(parser).parseSuccess('ab12', result: ['a', 'b', '1'], position: 3);
      check(parser)
          .parseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4);
      check(parser).parseSuccess('123', result: ['1', '2'], position: 2);
      check(parser).parseSuccess('a123', result: ['a', '1', '2'], position: 3);
      check(parser)
          .parseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4);
      check(
        parser,
      ).parseSuccess('abc123', result: ['a', 'b', 'c', '1', '2'], position: 5);
    });
    test('repeat', () {
      final parser = word().repeatGreedy(digit(), 2, 4);
      check(parser).parseFailure('', message: 'letter or digit expected');
      check(parser)
          .parseFailure('a', position: 1, message: 'letter or digit expected');
      check(parser).parseFailure('ab', position: 2, message: 'digit expected');
      check(parser).parseFailure('abc', position: 2, message: 'digit expected');
      check(parser)
          .parseFailure('abcd', position: 2, message: 'digit expected');
      check(parser)
          .parseFailure('abcde', position: 2, message: 'digit expected');
      check(parser)
          .parseFailure('1', position: 1, message: 'letter or digit expected');
      check(parser).parseFailure('a1', position: 2, message: 'digit expected');
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser)
          .parseSuccess('abcd1', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde1', position: 2, message: 'digit expected');
      check(parser).parseFailure('12', position: 2, message: 'digit expected');
      check(parser).parseSuccess('a12', result: ['a', '1'], position: 2);
      check(parser).parseSuccess('ab12', result: ['a', 'b', '1'], position: 3);
      check(parser)
          .parseSuccess('abc12', result: ['a', 'b', 'c', '1'], position: 4);
      check(parser)
          .parseSuccess('abcd12', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde12', position: 2, message: 'digit expected');
      check(parser).parseSuccess('123', result: ['1', '2'], position: 2);
      check(parser).parseSuccess('a123', result: ['a', '1', '2'], position: 3);
      check(parser)
          .parseSuccess('ab123', result: ['a', 'b', '1', '2'], position: 4);
      check(parser)
          .parseSuccess('abc123', result: ['a', 'b', 'c', '1'], position: 4);
      check(parser)
          .parseSuccess('abcd123', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde123', position: 2, message: 'digit expected');
    });
    test('repeat unbounded', () {
      final inputLetter = List.filled(100000, 'a');
      final inputDigit = List.filled(100000, '1');
      final parser = word().repeatGreedy(digit(), 2, unbounded);
      check(parser).parseSuccess(
        '${inputLetter.join()}1',
        result: inputLetter,
        position: inputLetter.length,
      );
      check(parser).parseSuccess(
        '${inputDigit.join()}1',
        result: inputDigit,
        position: inputDigit.length,
      );
    });
    test('infinite loop', () {
      final inner = epsilon(), limiter = failure<void>();
      check(() => inner.starGreedy(limiter).parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.starGreedy(limiter).fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plusGreedy(limiter).parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plusGreedy(limiter).fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
    }, skip: !hasAssertionsEnabled());
  });
  group('lazy', () {
    expectParserInvariants(any().starLazy(digit()));
    test('star', () {
      final parser = word().starLazy(digit());
      check(parser).parseFailure('');
      check(parser).parseFailure('a', position: 1, message: 'digit expected');
      check(parser).parseFailure('ab', position: 2, message: 'digit expected');
      check(parser).parseSuccess('1', result: <String>[], position: 0);
      check(parser).parseSuccess('a1', result: ['a'], position: 1);
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('12', result: <String>[], position: 0);
      check(parser).parseSuccess('a12', result: ['a'], position: 1);
      check(parser).parseSuccess('ab12', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc12', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('123', result: <String>[], position: 0);
      check(parser).parseSuccess('a123', result: ['a'], position: 1);
      check(parser).parseSuccess('ab123', result: ['a', 'b'], position: 2);
      check(parser)
          .parseSuccess('abc123', result: ['a', 'b', 'c'], position: 3);
    });
    test('plus', () {
      final parser = word().plusLazy(digit());
      check(parser).parseFailure('');
      check(parser).parseFailure('a', position: 1, message: 'digit expected');
      check(parser).parseFailure('ab', position: 2, message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'digit expected');
      check(parser).parseSuccess('a1', result: ['a'], position: 1);
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('12', result: ['1'], position: 1);
      check(parser).parseSuccess('a12', result: ['a'], position: 1);
      check(parser).parseSuccess('ab12', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc12', result: ['a', 'b', 'c'], position: 3);
      check(parser).parseSuccess('123', result: ['1'], position: 1);
      check(parser).parseSuccess('a123', result: ['a'], position: 1);
      check(parser).parseSuccess('ab123', result: ['a', 'b'], position: 2);
      check(parser)
          .parseSuccess('abc123', result: ['a', 'b', 'c'], position: 3);
    });
    test('repeat', () {
      final parser = word().repeatLazy(digit(), 2, 4);
      check(parser).parseFailure('', message: 'letter or digit expected');
      check(parser)
          .parseFailure('a', position: 1, message: 'letter or digit expected');
      check(parser).parseFailure('ab', position: 2, message: 'digit expected');
      check(parser).parseFailure('abc', position: 3, message: 'digit expected');
      check(parser)
          .parseFailure('abcd', position: 4, message: 'digit expected');
      check(parser)
          .parseFailure('abcde', position: 4, message: 'digit expected');
      check(parser)
          .parseFailure('1', position: 1, message: 'letter or digit expected');
      check(parser).parseFailure('a1', position: 2, message: 'digit expected');
      check(parser).parseSuccess('ab1', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc1', result: ['a', 'b', 'c'], position: 3);
      check(parser)
          .parseSuccess('abcd1', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde1', position: 4, message: 'digit expected');
      check(parser).parseFailure('12', position: 2, message: 'digit expected');
      check(parser).parseSuccess('a12', result: ['a', '1'], position: 2);
      check(parser).parseSuccess('ab12', result: ['a', 'b'], position: 2);
      check(parser).parseSuccess('abc12', result: ['a', 'b', 'c'], position: 3);
      check(parser)
          .parseSuccess('abcd12', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde12', position: 4, message: 'digit expected');
      check(parser).parseSuccess('123', result: ['1', '2'], position: 2);
      check(parser).parseSuccess('a123', result: ['a', '1'], position: 2);
      check(parser).parseSuccess('ab123', result: ['a', 'b'], position: 2);
      check(parser)
          .parseSuccess('abc123', result: ['a', 'b', 'c'], position: 3);
      check(parser)
          .parseSuccess('abcd123', result: ['a', 'b', 'c', 'd'], position: 4);
      check(parser)
          .parseFailure('abcde123', position: 4, message: 'digit expected');
    });
    test('repeat unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = word().repeatLazy(digit(), 2, unbounded);
      check(parser).parseSuccess(
        '${input.join()}1111',
        result: input,
        position: input.length,
      );
    });
    test('infinite loop', () {
      final inner = epsilon(), limiter = failure<void>();
      check(() => inner.starLazy(limiter).parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.starLazy(limiter).fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plusLazy(limiter).parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plusLazy(limiter).fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
    }, skip: !hasAssertionsEnabled());
  });
  group('possessive', () {
    expectParserInvariants(any().star());
    test('star', () {
      final parser = char('a').star();
      check(parser).parseSuccess('', result: <String>[]);
      check(parser).parseSuccess('a', result: ['a']);
      check(parser).parseSuccess('aa', result: ['a', 'a']);
      check(parser).parseSuccess('aaa', result: ['a', 'a', 'a']);
    });
    test('plus', () {
      final parser = char('a').plus();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseSuccess('a', result: ['a']);
      check(parser).parseSuccess('aa', result: ['a', 'a']);
      check(parser).parseSuccess('aaa', result: ['a', 'a', 'a']);
    });
    test('times', () {
      final parser = char('a').times(2);
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: ['a', 'a']);
      check(parser).parseSuccess('aaa', result: ['a', 'a'], position: 2);
    });
    test('repeat', () {
      final parser = char('a').repeat(2, 3);
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: ['a', 'a']);
      check(parser).parseSuccess('aaa', result: ['a', 'a', 'a']);
      check(parser).parseSuccess('aaaa', result: ['a', 'a', 'a'], position: 3);
    });
    test('repeat unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = char('a').repeat(2, unbounded);
      check(parser).parseSuccess(input.join(), result: input);
    });
    test('repeat erroneous', () {
      check(() => char('a').repeat(-1, 1))
          .throwsAssertionError(message: 'min must be at least 0, but got -1');
      check(() => char('a').repeat(2, 1))
          .throwsAssertionError(message: 'max must be at least 2, but got 1');
    }, skip: !hasAssertionsEnabled());
    test('times', () {
      final parser = char('a').times(2);
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: ['a', 'a']);
      check(parser).parseSuccess('aaa', result: ['a', 'a'], position: 2);
    });
    test('infinite loop', () {
      final inner = epsilon();
      check(() => inner.star().parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.star().fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plus().parse(''))
          .throwsAssertionError(message: '$inner must always consume');
      check(() => inner.plus().fastParseOn('', 0))
          .throwsAssertionError(message: '$inner must always consume');
    }, skip: !hasAssertionsEnabled());
  });
  group('string', () {
    expectParserInvariants(any().starString());
    test('star', () {
      final parser = char('a').starString();
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseSuccess('', result: '');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
    });
    test('plus', () {
      final parser = char('a').plusString();
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
    });
    test('times', () {
      final parser = char('a').timesString(2);
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aa', position: 2);
    });
    test('repeat', () {
      final parser = char('a').repeatString(2, 3);
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
      check(parser).parseSuccess('aaaa', result: 'aaa', position: 3);
    });
    test('repeat unbounded', () {
      final input = 'a' * 100000;
      final parser = char('a').repeatString(2, unbounded);
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseSuccess(input, result: input);
    });
    test('repeat erroneous', () {
      check(() => char('a').repeatString(-1, 1))
          .throwsAssertionError(message: 'min must be at least 0, but got -1');
      check(() => char('a').repeatString(2, 1))
          .throwsAssertionError(message: 'max must be at least 2, but got 1');
    }, skip: !hasAssertionsEnabled());
    test('times', () {
      final parser = char('a').timesString(2);
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<SingleCharPredicate>();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('a', position: 1, message: '"a" expected');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aa', position: 2);
    });
    test('any', () {
      final parser = any().plusString();
      check(parser)
          .isA<RepeatingCharacterParser>()
          .has((parser) => parser.predicate, 'predicate')
          .isA<ConstantCharPredicate>();
      check(parser).parseFailure('', message: 'input expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
    });
    test('any (unicode)', () {
      final parser = any(unicode: true).plusString();
      check(parser)
          .isA<FlattenParser>()
          .has((parser) => parser.delegate, 'delegate')
          .isA<PossessiveRepeatingParser<String>>();
      check(parser).parseFailure('', message: 'input expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
    });
    test('fallback', () {
      final parser = char('a').settable().plusString();
      check(parser)
          .isA<FlattenParser>()
          .has((parser) => parser.delegate, 'delegate')
          .isA<PossessiveRepeatingParser<String>>();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('aa', result: 'aa');
      check(parser).parseSuccess('aaa', result: 'aaa');
    });
  });
  group('separated', () {
    expectParserInvariants(digit().starSeparated(letter()));
    test('star', () {
      final parser = digit().starSeparated(letter());
      check(parser).parseSuccess('', result: isSeparatedList<String, String>());
      check(parser).parseSuccess(
        'a',
        result: isSeparatedList<String, String>(),
        position: 0,
      );
      check(parser).parseSuccess(
        '1',
        result: isSeparatedList<String, String>(elements: ['1']),
      );
      check(parser).parseSuccess(
        '1a',
        result: isSeparatedList<String, String>(elements: ['1']),
        position: 1,
      );
      check(parser).parseSuccess(
        '1a2',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
        position: 3,
      );
      check(parser).parseSuccess(
        '1a2b3',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3', '4'],
          separators: ['a', 'b', 'c'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c4d',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3', '4'],
          separators: ['a', 'b', 'c'],
        ),
        position: 7,
      );
    });
    test('plus', () {
      final parser = digit().plusSeparated(letter());
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      check(parser).parseSuccess(
        '1',
        result: isSeparatedList<String, String>(elements: ['1']),
      );
      check(parser).parseSuccess(
        '1a',
        result: isSeparatedList<String, String>(elements: ['1']),
        position: 1,
      );
      check(parser).parseSuccess(
        '1a2',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
        position: 3,
      );
      check(parser).parseSuccess(
        '1a2b3',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3', '4'],
          separators: ['a', 'b', 'c'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c4d',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3', '4'],
          separators: ['a', 'b', 'c'],
        ),
        position: 7,
      );
    });
    test('times', () {
      final parser = digit().timesSeparated(letter(), 3);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      check(parser).parseFailure('1', message: 'letter expected', position: 1);
      check(parser).parseFailure('1a', message: 'digit expected', position: 2);
      check(parser)
          .parseFailure('1a2', message: 'letter expected', position: 3);
      check(parser)
          .parseFailure('1a2b', message: 'digit expected', position: 4);
      check(parser).parseSuccess(
        '1a2b3',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4d',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
    });
    test('repeat', () {
      final parser = digit().repeatSeparated(letter(), 2, 3);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      check(parser).parseFailure('1', message: 'letter expected', position: 1);
      check(parser).parseFailure('1a', message: 'digit expected', position: 2);
      check(parser).parseSuccess(
        '1a2',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b',
        result: isSeparatedList<String, String>(
          elements: ['1', '2'],
          separators: ['a'],
        ),
        position: 3,
      );
      check(parser).parseSuccess(
        '1a2b3',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
      );
      check(parser).parseSuccess(
        '1a2b3c',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
      check(parser).parseSuccess(
        '1a2b3c4d',
        result: isSeparatedList<String, String>(
          elements: ['1', '2', '3'],
          separators: ['a', 'b'],
        ),
        position: 5,
      );
    });
    group('separated list', () {
      final empty = SeparatedList<String, String>([], []);
      final single = SeparatedList<String, String>(['1'], []);
      final double = SeparatedList<String, String>(['1', '2'], ['+']);
      final triple = SeparatedList<String, String>(['1', '2', '3'], ['+', '-']);
      final quadruple = SeparatedList<String, String>(
        ['1', '2', '3', '4'],
        ['+', '-', '*'],
      );
      final mixed = SeparatedList<int, String>([1, 2, 3], ['+', '-']);
      String combinator(String first, String separator, String second) =>
          '($first$separator$second)';
      test('elements', () {
        check(empty.elements).isEmpty();
        check(single.elements).deepEquals(['1']);
        check(double.elements).deepEquals(['1', '2']);
        check(triple.elements).deepEquals(['1', '2', '3']);
        check(quadruple.elements).deepEquals(['1', '2', '3', '4']);
        check(mixed.elements).deepEquals([1, 2, 3]);
      });
      test('separators', () {
        check(empty.separators).isEmpty();
        check(single.separators).isEmpty();
        check(double.separators).deepEquals(['+']);
        check(triple.separators).deepEquals(['+', '-']);
        check(quadruple.separators).deepEquals(['+', '-', '*']);
        check(mixed.separators).deepEquals(['+', '-']);
      });
      test('sequence', () {
        check(empty.sequential).isEmpty();
        check(single.sequential).deepEquals(['1']);
        check(double.sequential).deepEquals(['1', '+', '2']);
        check(triple.sequential).deepEquals(['1', '+', '2', '-', '3']);
        check(quadruple.sequential)
            .deepEquals(['1', '+', '2', '-', '3', '*', '4']);
        check(mixed.sequential).deepEquals([1, '+', 2, '-', 3]);
      });
      test('foldLeft', () {
        check(() => empty.foldLeft(combinator)).throws<StateError>();
        check(single.foldLeft(combinator)).equals('1');
        check(double.foldLeft(combinator)).equals('(1+2)');
        check(triple.foldLeft(combinator)).equals('((1+2)-3)');
        check(quadruple.foldLeft(combinator)).equals('(((1+2)-3)*4)');
      });
      test('foldRight', () {
        check(() => empty.foldRight(combinator)).throws<StateError>();
        check(single.foldRight(combinator)).equals('1');
        check(double.foldRight(combinator)).equals('(1+2)');
        check(triple.foldRight(combinator)).equals('(1+(2-3))');
        check(quadruple.foldRight(combinator)).equals('(1+(2-(3*4)))');
      });
      test('toString', () {
        check(empty.toString())
            .isCustomToString(rest: ['SeparatedList', '<String, String>()']);
        check(single.toString())
            .isCustomToString(rest: ['SeparatedList', '<String, String>(1)']);
        check(double.toString())
            .isCustomToString(rest: ['SeparatedList', '(1, +, 2)']);
        check(triple.toString())
            .isCustomToString(rest: ['SeparatedList', '(1, +, 2, -, 3)']);
        check(quadruple.toString())
            .isCustomToString(rest: ['SeparatedList', '(1, +, 2, -, 3, *, 4)']);
        check(mixed.toString())
            .isCustomToString(rest: ['SeparatedList', '(1, +, 2, -, 3)']);
      });
    });
  });
}
