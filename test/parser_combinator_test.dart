import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'generated/sequence_test.dart' as sequence_test;
import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('and', () {
    expectParserInvariants(any().and());
    test('default', () {
      final parser = char('a').and();
      expect(parser, isParseSuccess('a', result: 'a', position: 0));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(parser, isParseFailure('', message: '"a" expected'));
    });
  });
  group('choice', () {
    expectParserInvariants(any().or(word()));
    test('operator', () {
      final parser = char('a') | char('b');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('c', message: '"b" expected'));
      expect(parser, isParseFailure('', message: '"b" expected'));
    });
    test('converter', () {
      final parser = [char('a'), char('b')].toChoiceParser();
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('c', message: '"b" expected'));
      expect(parser, isParseFailure('', message: '"b" expected'));
    });
    test('two', () {
      final parser = char('a').or(char('b'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('c', message: '"b" expected'));
      expect(parser, isParseFailure('', message: '"b" expected'));
    });
    test('three', () {
      final parser = char('a').or(char('b')).or(char('c'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseFailure('d', message: '"c" expected'));
      expect(parser, isParseFailure('', message: '"c" expected'));
    });
    test('empty', () {
      expect(() => <Parser>[].toChoiceParser(), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
    group('types', () {
      test('same', () {
        final first = any();
        final second = any();
        expect(first, isA<Parser<String>>());
        expect(second, isA<Parser<String>>());
        expect([first, second].toChoiceParser(), isA<Parser<String>>());
        // TODO(renggli): https://github.com/dart-lang/language/issues/1557
        // expect(first | second, isA<Parser<String>>());
        // expect(first.or(second), isA<Parser<String>>());
      });
      test('different', () {
        final first = any().map(int.parse);
        final second = any().map(double.parse);
        expect(first, isA<Parser<int>>());
        expect(second, isA<Parser<double>>());
        expect([first, second].toChoiceParser(), isA<Parser<num>>());
        // TODO(renggli): https://github.com/dart-lang/language/issues/1557
        // expect(first | second, isA<Parser<num>>());
        // expect(first.or(second), isA<Parser<num>>());
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
        expect(defaultTwo.failureJoiner(failureA1, failureA0), failureA0);
        final customTwo = any().or(any(), failureJoiner: selectFarthest);
        expect(customTwo.failureJoiner(failureA1, failureA0), failureA1);
        final customCopy = customTwo.copy();
        expect(customCopy.failureJoiner(failureA1, failureA0), failureA1);
        final customThree =
            any().or(any(), failureJoiner: selectFarthest).or(any());
        expect(customThree.failureJoiner(failureA1, failureA0), failureA1);
      });
      test('select first', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectFirst);
        expect(selectFirst(failureA0, failureB0), failureA0);
        expect(selectFirst(failureB0, failureA0), failureB0);
        expect(parser, isParseSuccess('ab12', result: 'ab12'));
        expect(parser, isParseSuccess('ac13', result: 'ac13'));
        expect(parser, isParseSuccess('ad14', result: 'ad14'));
        expect(parser, isParseFailure('', message: 'any of "ab" expected'));
        expect(parser,
            isParseFailure('a', position: 1, message: 'any of "12" expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'any of "12" expected'));
        expect(parser,
            isParseFailure('ac', position: 1, message: 'any of "12" expected'));
        expect(parser,
            isParseFailure('ad', position: 1, message: 'any of "12" expected'));
      });
      test('select last', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectLast);
        expect(selectLast(failureA0, failureB0), failureB0);
        expect(selectLast(failureB0, failureA0), failureA0);
        expect(parser, isParseSuccess('ab12', result: 'ab12'));
        expect(parser, isParseSuccess('ac13', result: 'ac13'));
        expect(parser, isParseSuccess('ad14', result: 'ad14'));
        expect(parser, isParseFailure('', message: 'any of "ad" expected'));
        expect(parser,
            isParseFailure('a', position: 1, message: 'any of "14" expected'));
        expect(parser,
            isParseFailure('ab', position: 1, message: 'any of "14" expected'));
        expect(parser,
            isParseFailure('ac', position: 1, message: 'any of "14" expected'));
        expect(parser,
            isParseFailure('ad', position: 2, message: 'any of "14" expected'));
      });
      test('farthest failure', () {
        final parser = parsers.toChoiceParser(failureJoiner: selectFarthest);
        expect(selectFarthest(failureA0, failureB0), failureB0);
        expect(selectFarthest(failureA0, failureB1), failureB1);
        expect(selectFarthest(failureB0, failureA0), failureA0);
        expect(selectFarthest(failureB1, failureA0), failureB1);
        expect(parser, isParseSuccess('ab12', result: 'ab12'));
        expect(parser, isParseSuccess('ac13', result: 'ac13'));
        expect(parser, isParseSuccess('ad14', result: 'ad14'));
        expect(parser, isParseFailure('', message: 'any of "ad" expected'));
        expect(parser,
            isParseFailure('a', position: 1, message: 'any of "14" expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'any of "12" expected'));
        expect(parser,
            isParseFailure('ac', position: 2, message: 'any of "13" expected'));
        expect(parser,
            isParseFailure('ad', position: 2, message: 'any of "14" expected'));
      });
      test('farthest failure and joined', () {
        final parser =
            parsers.toChoiceParser(failureJoiner: selectFarthestJoined);
        expect(selectFarthestJoined(failureA0, failureB1), failureB1);
        expect(selectFarthestJoined(failureB1, failureA0), failureB1);
        expect(selectFarthestJoined(failureA0, failureB0).message, 'A0 OR B0');
        expect(selectFarthestJoined(failureB0, failureA0).message, 'B0 OR A0');
        expect(selectFarthestJoined(failureA1, failureB1).message, 'A1 OR B1');
        expect(selectFarthestJoined(failureB1, failureA1).message, 'B1 OR A1');
        expect(parser, isParseSuccess('ab12', result: 'ab12'));
        expect(parser, isParseSuccess('ac13', result: 'ac13'));
        expect(parser, isParseSuccess('ad14', result: 'ad14'));
        expect(
            parser,
            isParseFailure('',
                message: 'any of "ab" expected OR '
                    'any of "ac" expected OR any of "ad" expected'));
        expect(
            parser,
            isParseFailure('a',
                position: 1,
                message: 'any of "12" expected OR '
                    'any of "13" expected OR any of "14" expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'any of "12" expected'));
        expect(parser,
            isParseFailure('ac', position: 2, message: 'any of "13" expected'));
        expect(parser,
            isParseFailure('ad', position: 2, message: 'any of "14" expected'));
      });
    });
  });
  group('not', () {
    expectParserInvariants(any().not());
    test('default', () {
      final parser = char('a').not(message: 'not "a" expected');
      expect(parser, isParseFailure('a', message: 'not "a" expected'));
      expect(
          parser,
          isParseSuccess('b',
              result: isFailure(position: 0, message: '"a" expected'),
              position: 0));
      expect(
          parser,
          isParseSuccess('',
              result: isFailure(position: 0, message: '"a" expected'),
              position: 0));
    });
    test('neg', () {
      final parser = digit().neg(message: 'no digit expected');
      expect(parser, isParseFailure('1', message: 'no digit expected'));
      expect(parser, isParseFailure('9', message: 'no digit expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess(' ', result: ' '));
      expect(parser, isParseFailure('', message: 'input expected'));
    });
  });
  group('optional', () {
    expectParserInvariants(any().optional());
    test('without default', () {
      final parser = char('a').optional();
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: isNull, position: 0));
      expect(parser, isParseSuccess('', result: isNull));
    });
    test('with default', () {
      final parser = char('a').optionalWith('0');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: '0', position: 0));
      expect(parser, isParseSuccess('', result: '0'));
    });
  });
  group('sequence', () {
    expectParserInvariants(any().seq(word()));
    test('operator', () {
      final parser = char('a') & char('b');
      expect(parser, isParseSuccess('ab', result: ['a', 'b']));
      expect(parser, isParseFailure(''));
      expect(parser, isParseFailure('x'));
      expect(parser, isParseFailure('a', position: 1));
      expect(parser, isParseFailure('ax', position: 1));
    });
    test('converter', () {
      final parser = [char('a'), char('b')].toSequenceParser();
      expect(parser, isParseSuccess('ab', result: ['a', 'b']));
      expect(parser, isParseFailure(''));
      expect(parser, isParseFailure('x'));
      expect(parser, isParseFailure('a', position: 1));
      expect(parser, isParseFailure('ax', position: 1));
    });
    test('two', () {
      final parser = char('a').seq(char('b'));
      expect(parser, isParseSuccess('ab', result: ['a', 'b']));
      expect(parser, isParseFailure(''));
      expect(parser, isParseFailure('x'));
      expect(parser, isParseFailure('a', position: 1));
      expect(parser, isParseFailure('ax', position: 1));
    });
    test('three', () {
      final parser = char('a').seq(char('b')).seq(char('c'));
      expect(parser, isParseSuccess('abc', result: ['a', 'b', 'c']));
      expect(parser, isParseFailure(''));
      expect(parser, isParseFailure('x'));
      expect(parser, isParseFailure('a', position: 1));
      expect(parser, isParseFailure('ax', position: 1));
      expect(parser, isParseFailure('ab', position: 2));
      expect(parser, isParseFailure('abx', position: 2));
    });
  });
  group('sequence (typed)', sequence_test.main);
  group('settable', () {
    expectParserInvariants(any().settable());
    test('default', () {
      final inner = char('a');
      final parser = inner.settable();
      expect(parser.resolve(), inner);
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(parser, isParseFailure(''));
    });
    test('undefined', () {
      final parser = undefined<String>();
      expect(parser, isParseFailure('', message: 'undefined parser'));
      expect(parser, isParseFailure('a', message: 'undefined parser'));
      parser.set(char('a'));
      expect(parser, isParseSuccess('a', result: 'a'));
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
        expect(parser.children,
            [isA<EpsilonParser<void>>(), inner, isA<EpsilonParser<void>>()]);
        expect(parser, isParseSuccess('1', result: '1'));
        expect(parser, isParseSuccess('2', result: '2'));
        expect(parser, isParseFailure('', message: 'digit expected'));
      });
    });
    group('before', () {
      final parser = inner.skip(before: before);
      expectParserInvariants(parser);
      test('default', () {
        expect(parser.children, [before, inner, isA<EpsilonParser<void>>()]);
        expect(parser, isParseSuccess('<1', result: '1'));
        expect(parser, isParseSuccess('<2', result: '2'));
        expect(parser, isParseFailure('', message: '"<" expected'));
        expect(parser, isParseFailure('1', message: '"<" expected'));
        expect(parser,
            isParseFailure('<', message: 'digit expected', position: 1));
        expect(parser,
            isParseFailure('<a', message: 'digit expected', position: 1));
      });
    });
    group('after', () {
      final parser = inner.skip(after: after);
      expectParserInvariants(parser);
      test('default', () {
        expect(parser.children, [isA<EpsilonParser<void>>(), inner, after]);
        expect(parser, isParseSuccess('1>', result: '1'));
        expect(parser, isParseSuccess('2>', result: '2'));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(
            parser, isParseFailure('1', message: '">" expected', position: 1));
        expect(
            parser, isParseFailure('1!', message: '">" expected', position: 1));
        expect(parser, isParseFailure('>', message: 'digit expected'));
        expect(parser, isParseFailure('a>', message: 'digit expected'));
      });
    });
    group('before & after', () {
      final parser = inner.skip(before: before, after: after);
      expectParserInvariants(parser);
      test('default', () {
        expect(parser.children, [before, inner, after]);
        expect(parser, isParseSuccess('<1>', result: '1'));
        expect(parser, isParseSuccess('<2>', result: '2'));
        expect(parser, isParseFailure('', message: '"<" expected'));
        expect(parser, isParseFailure('1', message: '"<" expected'));
        expect(parser, isParseFailure('1>', message: '"<" expected'));
        expect(parser, isParseFailure('1!', message: '"<" expected'));
        expect(parser,
            isParseFailure('<', message: 'digit expected', position: 1));
        expect(
            parser, isParseFailure('<1', message: '">" expected', position: 2));
        expect(parser,
            isParseFailure('<1!', message: '">" expected', position: 2));
      });
    });
  });
}
