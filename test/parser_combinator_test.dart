import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import 'generated/sequence_test.dart' as sequence_test;
import 'utils/assertions.dart';
import 'utils/checks.dart';

void main() {
  group('and', () {
    expectParserInvariants(any().and());
    test('default', () {
      final parser = char('a').and();
      check(parser).parseSuccess('a', result: 'a', position: 0);
      check(parser).parseFailure('b', message: '"a" expected');
      check(parser).parseFailure('', message: '"a" expected');
    });
  });
  group('choice', () {
    expectParserInvariants(any().or(word()));
    test('operator', () {
      final parser = char('a') | char('b');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: 'b');
      check(parser).parseFailure('c', message: '"b" expected');
      check(parser).parseFailure('', message: '"b" expected');
    });
    test('converter', () {
      final parser = [char('a'), char('b')].toChoiceParser();
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: 'b');
      check(parser).parseFailure('c', message: '"b" expected');
      check(parser).parseFailure('', message: '"b" expected');
    });
    test('two', () {
      final parser = char('a').or(char('b'));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: 'b');
      check(parser).parseFailure('c', message: '"b" expected');
      check(parser).parseFailure('', message: '"b" expected');
    });
    test('three', () {
      final parser = char('a').or(char('b')).or(char('c'));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: 'b');
      check(parser).parseSuccess('c', result: 'c');
      check(parser).parseFailure('d', message: '"c" expected');
      check(parser).parseFailure('', message: '"c" expected');
    });
    test('empty', () {
      check(() => <Parser>[].toChoiceParser()).throwsAssertionError();
    }, skip: !hasAssertionsEnabled());
    group('types', () {
      test('same', () {
        final first = any();
        final second = any();
        check(first).isA<Parser<String>>();
        check(second).isA<Parser<String>>();
        check([first, second].toChoiceParser()).isA<Parser<String>>();
        // TODO(renggli): https://github.com/dart-lang/language/issues/1557
        // check(first | second).isA<Parser<String>>();
        // check(first.or(second)).isA<Parser<String>>();
      });
      test('different', () {
        final first = any().map(int.parse);
        final second = any().map(double.parse);
        check(first).isA<Parser<int>>();
        check(second).isA<Parser<double>>();
        check([first, second].toChoiceParser()).isA<Parser<num>>();
        // TODO(renggli): https://github.com/dart-lang/language/issues/1557
        // check(first | second).isA<Parser<num>>();
        // check(first.or(second)).isA<Parser<num>>();
      });
    });
    group('failure joining', () {
      const failureA0 = Failure('A0', 0, 'A0');
      const failureA1 = Failure('A1', 1, 'A1');
      const failureB0 = Failure('B0', 0, 'B0');
      const failureB1 = Failure('B1', 1, 'B1');
      final parsers = [
        anyOf('ab').plus() & anyOf('12').plus(),
        anyOf('ac').plus() & anyOf('13').plus(),
        anyOf('ad').plus() & anyOf('14').plus(),
      ].map((parser) => parser.flatten());
      test('construction', () {
        final defaultTwo = any().or(any());
        check(defaultTwo.failureJoiner(failureA1, failureA0)).equals(failureA0);
        final customTwo = any().or(any(), failureJoiner: selectFarthest);
        check(customTwo.failureJoiner(failureA1, failureA0)).equals(failureA1);
        final customCopy = customTwo.copy();
        check(customCopy.failureJoiner(failureA1, failureA0)).equals(failureA1);
        final customThree = any()
            .or(any(), failureJoiner: selectFarthest)
            .or(any());
        check(customThree.failureJoiner(failureA1, failureA0))
            .equals(failureA1);
      });
      test('select first', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectFirst);
        check(selectFirst(failureA0, failureB0)).equals(failureA0);
        check(selectFirst(failureB0, failureA0)).equals(failureB0);
        check(parser).parseSuccess('ab12', result: 'ab12');
        check(parser).parseSuccess('ac13', result: 'ac13');
        check(parser).parseSuccess('ad14', result: 'ad14');
        check(parser).parseFailure('', message: 'any of "ab" expected');
        check(parser)
            .parseFailure('a', position: 1, message: 'any of "12" expected');
        check(parser)
            .parseFailure('ab', position: 2, message: 'any of "12" expected');
        check(parser)
            .parseFailure('ac', position: 1, message: 'any of "12" expected');
        check(parser)
            .parseFailure('ad', position: 1, message: 'any of "12" expected');
      });
      test('select last', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectLast);
        check(selectLast(failureA0, failureB0)).equals(failureB0);
        check(selectLast(failureB0, failureA0)).equals(failureA0);
        check(parser).parseSuccess('ab12', result: 'ab12');
        check(parser).parseSuccess('ac13', result: 'ac13');
        check(parser).parseSuccess('ad14', result: 'ad14');
        check(parser).parseFailure('', message: 'any of "ad" expected');
        check(parser)
            .parseFailure('a', position: 1, message: 'any of "14" expected');
        check(parser)
            .parseFailure('ab', position: 1, message: 'any of "14" expected');
        check(parser)
            .parseFailure('ac', position: 1, message: 'any of "14" expected');
        check(parser)
            .parseFailure('ad', position: 2, message: 'any of "14" expected');
      });
      test('farthest failure', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectFarthest);
        check(selectFarthest(failureA0, failureB0)).equals(failureB0);
        check(selectFarthest(failureA0, failureB1)).equals(failureB1);
        check(selectFarthest(failureB0, failureA0)).equals(failureA0);
        check(selectFarthest(failureB1, failureA0)).equals(failureB1);
        check(parser).parseSuccess('ab12', result: 'ab12');
        check(parser).parseSuccess('ac13', result: 'ac13');
        check(parser).parseSuccess('ad14', result: 'ad14');
        check(parser).parseFailure('', message: 'any of "ad" expected');
        check(parser)
            .parseFailure('a', position: 1, message: 'any of "14" expected');
        check(parser)
            .parseFailure('ab', position: 2, message: 'any of "12" expected');
        check(parser)
            .parseFailure('ac', position: 2, message: 'any of "13" expected');
        check(parser)
            .parseFailure('ad', position: 2, message: 'any of "14" expected');
      });
      test('farthest failure and joined', () {
        final parser = parsers.toChoiceParser(
          failureJoiner: selectFarthestJoined,
        );
        check(selectFarthestJoined(failureA0, failureB1)).equals(failureB1);
        check(selectFarthestJoined(failureB1, failureA0)).equals(failureB1);
        check(selectFarthestJoined(failureA0, failureB0).message)
            .equals('A0 OR B0');
        check(selectFarthestJoined(failureB0, failureA0).message)
            .equals('B0 OR A0');
        check(selectFarthestJoined(failureA1, failureB1).message)
            .equals('A1 OR B1');
        check(selectFarthestJoined(failureB1, failureA1).message)
            .equals('B1 OR A1');
        check(parser).parseSuccess('ab12', result: 'ab12');
        check(parser).parseSuccess('ac13', result: 'ac13');
        check(parser).parseSuccess('ad14', result: 'ad14');
        check(parser).parseFailure(
          '',
          message:
              'any of "ab" expected OR '
              'any of "ac" expected OR any of "ad" expected',
        );
        check(parser).parseFailure(
          'a',
          position: 1,
          message:
              'any of "12" expected OR '
              'any of "13" expected OR any of "14" expected',
        );
        check(parser)
            .parseFailure('ab', position: 2, message: 'any of "12" expected');
        check(parser)
            .parseFailure('ac', position: 2, message: 'any of "13" expected');
        check(parser)
            .parseFailure('ad', position: 2, message: 'any of "14" expected');
      });
    });
  });
  group('not', () {
    expectParserInvariants(any().not());
    test('default', () {
      final parser = char('a').not(message: 'not "a" expected');
      check(parser).parseFailure('a', message: 'not "a" expected');
      check(parser).parseSuccess(
        'b',
        result: (Subject<dynamic> it) =>
            it.isA<Failure>().isFailure(position: 0, message: '"a" expected'),
        position: 0,
      );
      check(parser).parseSuccess(
        '',
        result: (Subject<dynamic> it) =>
            it.isA<Failure>().isFailure(position: 0, message: '"a" expected'),
        position: 0,
      );
    });
    test('neg', () {
      final parser = digit().neg(message: 'no digit expected');
      check(parser).parseFailure('1', message: 'no digit expected');
      check(parser).parseFailure('9', message: 'no digit expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess(' ', result: ' ');
      check(parser).parseFailure('', message: 'input expected');
    });
  });
  group('optional', () {
    expectParserInvariants(any().optional());
    test('without default', () {
      final parser = char('a').optional();
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: null, position: 0);
      check(parser).parseSuccess('', result: null);
    });
    test('with default', () {
      final parser = char('a').optionalWith('0');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('b', result: '0', position: 0);
      check(parser).parseSuccess('', result: '0');
    });
  });
  group('sequence', () {
    expectParserInvariants(any().seq(word()));
    test('operator', () {
      final parser = char('a') & char('b');
      check(parser).parseSuccess('ab', result: ['a', 'b']);
      check(parser).parseFailure('');
      check(parser).parseFailure('x');
      check(parser).parseFailure('a', position: 1);
      check(parser).parseFailure('ax', position: 1);
    });
    test('converter', () {
      final parser = [char('a'), char('b')].toSequenceParser();
      check(parser).parseSuccess('ab', result: ['a', 'b']);
      check(parser).parseFailure('');
      check(parser).parseFailure('x');
      check(parser).parseFailure('a', position: 1);
      check(parser).parseFailure('ax', position: 1);
    });
    test('two', () {
      final parser = char('a').seq(char('b'));
      check(parser).parseSuccess('ab', result: ['a', 'b']);
      check(parser).parseFailure('');
      check(parser).parseFailure('x');
      check(parser).parseFailure('a', position: 1);
      check(parser).parseFailure('ax', position: 1);
    });
    test('three', () {
      final parser = char('a').seq(char('b')).seq(char('c'));
      check(parser).parseSuccess('abc', result: ['a', 'b', 'c']);
      check(parser).parseFailure('');
      check(parser).parseFailure('x');
      check(parser).parseFailure('a', position: 1);
      check(parser).parseFailure('ax', position: 1);
      check(parser).parseFailure('ab', position: 2);
      check(parser).parseFailure('abx', position: 2);
    });
  });
  group('sequence (typed)', sequence_test.main);
  group('settable', () {
    expectParserInvariants(any().settable());
    test('default', () {
      final inner = char('a');
      final parser = inner.settable();
      check(parser.resolve()).equals(inner);
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseFailure('b', message: '"a" expected');
      check(parser).parseFailure('');
    });
    test('undefined', () {
      final parser = undefined<String>();
      check(parser).parseFailure('', message: 'undefined parser');
      check(parser).parseFailure('a', message: 'undefined parser');
      parser.set(char('a'));
      check(parser).parseSuccess('a', result: 'a');
    });
  });
  group('skip', () {
    final inner = digit();
    final before = char('<');
    final after = char('>');
    group('none', () {
      final parser = inner.skip();
      expectParserInvariants(parser);
      test('default', () {
        check(parser.children).matchesInOrder([
          (it) => it.isA<EpsilonParser<void>>(),
          (it) => it.equals(inner),
          (it) => it.isA<EpsilonParser<void>>(),
        ]);
        check(parser).parseSuccess('1', result: '1');
        check(parser).parseSuccess('2', result: '2');
        check(parser).parseFailure('', message: 'digit expected');
      });
    });
    group('before', () {
      final parser = inner.skip(before: before);
      expectParserInvariants(parser);
      test('default', () {
        check(parser.children).matchesInOrder([
          (it) => it.equals(before),
          (it) => it.equals(inner),
          (it) => it.isA<EpsilonParser<void>>(),
        ]);
        check(parser).parseSuccess('<1', result: '1');
        check(parser).parseSuccess('<2', result: '2');
        check(parser).parseFailure('', message: '"<" expected');
        check(parser).parseFailure('1', message: '"<" expected');
        check(parser).parseFailure('<', message: 'digit expected', position: 1);
        check(parser)
            .parseFailure('<a', message: 'digit expected', position: 1);
      });
    });
    group('after', () {
      final parser = inner.skip(after: after);
      expectParserInvariants(parser);
      test('default', () {
        check(parser.children).matchesInOrder([
          (it) => it.isA<EpsilonParser<void>>(),
          (it) => it.equals(inner),
          (it) => it.equals(after),
        ]);
        check(parser).parseSuccess('1>', result: '1');
        check(parser).parseSuccess('2>', result: '2');
        check(parser).parseFailure('', message: 'digit expected');
        check(parser).parseFailure('1', message: '">" expected', position: 1);
        check(parser).parseFailure('1!', message: '">" expected', position: 1);
        check(parser).parseFailure('>', message: 'digit expected');
        check(parser).parseFailure('a>', message: 'digit expected');
      });
    });
    group('before & after', () {
      final parser = inner.skip(before: before, after: after);
      expectParserInvariants(parser);
      test('default', () {
        check(parser.children).deepEquals([before, inner, after]);
        check(parser).parseSuccess('<1>', result: '1');
        check(parser).parseSuccess('<2>', result: '2');
        check(parser).parseFailure('', message: '"<" expected');
        check(parser).parseFailure('1', message: '"<" expected');
        check(parser).parseFailure('1>', message: '"<" expected');
        check(parser).parseFailure('1!', message: '"<" expected');
        check(parser).parseFailure('<', message: 'digit expected', position: 1);
        check(parser).parseFailure('<1', message: '">" expected', position: 2);
        check(parser).parseFailure('<1!', message: '">" expected', position: 2);
      });
    });
  });
}
