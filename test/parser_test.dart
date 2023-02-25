import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'generated/sequence_test.dart' as sequence_test;
import 'utils/assertions.dart';
import 'utils/matchers.dart';

TypeMatcher<SeparatedList<R, S>> isSeparatedList<R, S>({
  List<R> elements = const [],
  List<S> separators = const [],
}) =>
    isA<SeparatedList<R, S>>()
        .having((list) => list.elements, 'elements', elements)
        .having((list) => list.separators, 'separators', separators);

void main() {
  group('action', () {
    group('cast', () {
      expectParserInvariants(any().cast<String>());
      test('default', () {
        final parser = digit().map(int.parse).cast<num>();
        expect(parser, isParseSuccess('1', 1));
        expect(parser, isParseFailure('a', message: 'digit expected'));
      });
    });
    group('castList', () {
      expectParserInvariants(any().star().castList<String>());
      test('default', () {
        final parser = digit().map(int.parse).repeat(3).castList<num>();
        expect(parser, isParseSuccess('123', <num>[1, 2, 3]));
        expect(parser,
            isParseFailure('abc', position: 0, message: 'digit expected'));
      });
    });
    group('callCC', () {
      expectParserInvariants(
          any().callCC((continuation, context) => continuation(context)));
      test('delegation', () {
        final parser =
            digit().callCC((continuation, context) => continuation(context));
        expect(parser, isParseSuccess('1', '1'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
      });
      test('diversion', () {
        final parser = digit()
            .callCC((continuation, context) => letter().parseOn(context));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseFailure('1', message: 'letter expected'));
      });
      test('resume', () {
        final continuations = <ContinuationFunction>[];
        final results = <Result>[];
        final parser = digit().callCC((continuation, context) {
          continuations.add(continuation);
          results.add(context.toResult());
          // we have to return something for now
          context.failure('Abort');
        });
        // execute the parser twice to collect the continuations
        expect(parser.parse('1').isSuccess, isFalse);
        expect(parser.parse('a').isSuccess, isFalse);
        // later we can execute the captured continuations
        final context11 = results[0].toContext();
        continuations[0](context11);
        expect(context11.toResult(), isSuccess());
        final context12 = results[1].toContext();
        continuations[1](context12);
        expect(context12.toResult(), isFailure());
        // of course the continuations can be resumed multiple times
        final context21 = results[0].toContext();
        continuations[0](context21);
        expect(context21.toResult(), isSuccess());
        final context22 = results[1].toContext();
        continuations[1](context22);
        expect(context22.toResult(), isFailure());
      });
      test('success', () {
        final parser = digit()
            .callCC((continuation, context) => context.success('success'));
        expect(parser, isParseSuccess('1', 'success', position: 0));
        expect(parser, isParseSuccess('a', 'success', position: 0));
      });
      test('failure', () {
        final parser = digit()
            .callCC((continuation, context) => context.failure('failure'));
        expect(parser, isParseFailure('1', message: 'failure'));
        expect(parser, isParseFailure('a', message: 'failure'));
      });
    });
    group('flatten', () {
      expectParserInvariants(any().flatten());
      test('default', () {
        final parser = digit().repeat(2, unbounded).flatten();
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'digit expected'));
        expect(parser,
            isParseFailure('1a', position: 1, message: 'digit expected'));
        expect(parser, isParseSuccess('12', '12'));
        expect(parser, isParseSuccess('123', '123'));
        expect(parser, isParseSuccess('1234', '1234'));
      });
      test('with message', () {
        final parser = digit().repeat(2, unbounded).flatten('gimme a number');
        expect(parser, isParseFailure('', message: 'gimme a number'));
        expect(parser, isParseFailure('a', message: 'gimme a number'));
        expect(parser, isParseFailure('1', message: 'gimme a number'));
        expect(parser, isParseFailure('1a', message: 'gimme a number'));
        expect(parser, isParseSuccess('12', '12'));
        expect(parser, isParseSuccess('123', '123'));
        expect(parser, isParseSuccess('1234', '1234'));
      });

      test('nested', () {
        final parser =
            digit().star().flatten().plusSeparated(char(',')).flatten();
        expect(parser, isParseSuccess('1', '1'));
        expect(parser, isParseSuccess('1,12', '1,12'));
        expect(parser, isParseSuccess('1,12,123', '1,12,123'));
      });
    });
    group('where', () {
      expectParserInvariants(any().where((value) => true));
      test('default', () {
        final parser = any().where((value) => value == '*');
        expect(parser, isParseSuccess('*', '*'));
        expect(parser, isParseFailure('', message: 'input expected'));
        expect(parser, isParseFailure('!', message: 'unexpected "!"'));
      });
      test('with message', () {
        final parser = digit().plus().flatten().map(int.parse).where(
            (value) => value % 7 == 0,
            message: 'value not divisible by 7');
        expect(parser, isParseSuccess('7', 7));
        expect(parser, isParseSuccess('14', 14));
        expect(parser, isParseSuccess('861', 861));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(
            parser, isParseFailure('865', message: 'value not divisible by 7'));
      });
      test('with message builder', () {
        final parser = digit().plus().flatten().map(int.parse).where(
            (value) => value % 7 == 0,
            messageBuilder: (value) => '"$value" not divisible by 7');
        expect(parser, isParseSuccess('7', 7));
        expect(parser, isParseSuccess('14', 14));
        expect(parser, isParseSuccess('861', 861));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(
            parser, isParseFailure('865', message: '"865" not divisible by 7'));
      });
    });
    group('map', () {
      expectParserInvariants(any().map((a) => a));
      test('default', () {
        final parser =
            digit().map((each) => each.codeUnitAt(0) - '0'.codeUnitAt(0));
        expect(parser, isParseSuccess('1', 1));
        expect(parser, isParseSuccess('4', 4));
        expect(parser, isParseSuccess('9', 9));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
      });
    });
    group('permute', () {
      expectParserInvariants(any().star().permute([-1, 1]));
      test('from start', () {
        final parser = digit().seq(letter()).permute([1, 0]);
        expect(parser, isParseSuccess('1a', ['a', '1']));
        expect(parser, isParseSuccess('2b', ['b', '2']));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'letter expected'));
        expect(parser,
            isParseFailure('12', position: 1, message: 'letter expected'));
      });
      test('from end', () {
        final parser = digit().seq(letter()).permute([-1, 0]);
        expect(parser, isParseSuccess('1a', ['a', '1']));
        expect(parser, isParseSuccess('2b', ['b', '2']));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'letter expected'));
        expect(parser,
            isParseFailure('12', position: 1, message: 'letter expected'));
      });
      test('repeated', () {
        final parser = digit().seq(letter()).permute([1, 1]);
        expect(parser, isParseSuccess('1a', ['a', 'a']));
        expect(parser, isParseSuccess('2b', ['b', 'b']));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'letter expected'));
        expect(parser,
            isParseFailure('12', position: 1, message: 'letter expected'));
      });
    });
    group('pick', () {
      expectParserInvariants(any().star().pick(-1));
      test('from start', () {
        final parser = digit().seq(letter()).pick(1);
        expect(parser, isParseSuccess('1a', 'a'));
        expect(parser, isParseSuccess('2b', 'b'));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'letter expected'));
        expect(parser,
            isParseFailure('12', position: 1, message: 'letter expected'));
      });
      test('from end', () {
        final parser = digit().seq(letter()).pick(-1);
        expect(parser, isParseSuccess('1a', 'a'));
        expect(parser, isParseSuccess('2b', 'b'));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'letter expected'));
        expect(parser,
            isParseFailure('12', position: 1, message: 'letter expected'));
      });
    });
    group('token', () {
      expectParserInvariants(any().token());
      test('default', () {
        final parser = digit().plus().token();
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        final token = parser.parse('123').value;
        expect(token.value, ['1', '2', '3']);
        expect(token.buffer, '123');
        expect(token.start, 0);
        expect(token.stop, 3);
        expect(token.input, '123');
        expect(token.length, 3);
        expect(token.line, 1);
        expect(token.column, 1);
        expect(token.toString(), 'Token[1:1]: [1, 2, 3]');
      });
      const buffer = '1\r12\r\n123\n1234';
      final parser = any().map((value) => value.codeUnitAt(0)).token().star();
      final result = parser.parse(buffer).value;
      test('value', () {
        final expected = [
          49,
          13,
          49,
          50,
          13,
          10,
          49,
          50,
          51,
          10,
          49,
          50,
          51,
          52
        ];
        expect(result.map((token) => token.value), expected);
      });
      test('buffer', () {
        final expected = List.filled(buffer.length, buffer);
        expect(result.map((token) => token.buffer), expected);
      });
      test('start', () {
        final expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
        expect(result.map((token) => token.start), expected);
      });
      test('stop', () {
        final expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
        expect(result.map((token) => token.stop), expected);
      });
      test('length', () {
        final expected = List.filled(buffer.length, 1);
        expect(result.map((token) => token.length), expected);
      });
      test('line', () {
        final expected = [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4];
        expect(result.map((token) => token.line), expected);
      });
      test('column', () {
        final expected = [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4];
        expect(result.map((token) => token.column), expected);
      });
      test('input', () {
        final expected = [
          '1',
          '\r',
          '1',
          '2',
          '\r',
          '\n',
          '1',
          '2',
          '3',
          '\n',
          '1',
          '2',
          '3',
          '4'
        ];
        expect(result.map((token) => token.input), expected);
      });
      test('map', () {
        final expected = [
          '49',
          '13',
          '49',
          '50',
          '13',
          '10',
          '49',
          '50',
          '51',
          '10',
          '49',
          '50',
          '51',
          '52'
        ];
        expect(
            result
                .map((token) => token.map((value) => value.toString()))
                .map((token) => token.value),
            expected);
      });
      group('join', () {
        test('normal', () {
          final joined = Token.join(result);
          expect(
              joined,
              isA<Token<List<int>>>()
                  .having((token) => token.value, 'value',
                      [49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52])
                  .having((token) => token.buffer, 'buffer', buffer)
                  .having((token) => token.start, 'start', 0)
                  .having((token) => token.stop, 'stop', buffer.length));
        });
        test('reverse order', () {
          final joined = Token.join(result.reversed);
          expect(
              joined,
              isA<Token<List<int>>>()
                  .having((token) => token.value, 'value',
                      [52, 51, 50, 49, 10, 51, 50, 49, 10, 13, 50, 49, 13, 49])
                  .having((token) => token.buffer, 'buffer', buffer)
                  .having((token) => token.start, 'start', 0)
                  .having((token) => token.stop, 'stop', buffer.length));
        });
        test('empty', () {
          expect(() => Token.join([]), throwsArgumentError);
        });
        test('different buffer', () {
          const token = [Token(12, '12', 0, 2), Token(32, '32', 0, 2)];
          expect(() => Token.join(token), throwsArgumentError);
        });
      });
      test('unique', () {
        expect({...result}.length, result.length);
      });
      test('equals', () {
        for (var i = 0; i < result.length; i++) {
          for (var j = 0; j < result.length; j++) {
            final condition = i == j ? isTrue : isFalse;
            expect(result[i] == result[j], condition);
            expect(result[i].hashCode == result[j].hashCode, condition);
          }
        }
      });
    });
    group('trim', () {
      expectParserInvariants(any().trim(char('a'), char('b')));
      test('default', () {
        final parser = char('a').trim();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess(' a', 'a'));
        expect(parser, isParseSuccess('a ', 'a'));
        expect(parser, isParseSuccess(' a ', 'a'));
        expect(parser, isParseSuccess('  a', 'a'));
        expect(parser, isParseSuccess('a  ', 'a'));
        expect(parser, isParseSuccess('  a  ', 'a'));
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(
            parser, isParseFailure(' b', position: 1, message: '"a" expected'));
        expect(parser,
            isParseFailure('  b', position: 2, message: '"a" expected'));
      });
      test('custom both', () {
        final parser = char('a').trim(char('*'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('*a', 'a'));
        expect(parser, isParseSuccess('a*', 'a'));
        expect(parser, isParseSuccess('*a*', 'a'));
        expect(parser, isParseSuccess('**a', 'a'));
        expect(parser, isParseSuccess('a**', 'a'));
        expect(parser, isParseSuccess('**a**', 'a'));
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(
            parser, isParseFailure('*b', position: 1, message: '"a" expected'));
        expect(parser,
            isParseFailure('**b', position: 2, message: '"a" expected'));
      });
      test('custom left and right', () {
        final parser = char('a').trim(char('*'), char('#'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('*a', 'a'));
        expect(parser, isParseSuccess('a#', 'a'));
        expect(parser, isParseSuccess('*a#', 'a'));
        expect(parser, isParseSuccess('**a', 'a'));
        expect(parser, isParseSuccess('a##', 'a'));
        expect(parser, isParseSuccess('**a##', 'a'));
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(
            parser, isParseFailure('*b', position: 1, message: '"a" expected'));
        expect(parser,
            isParseFailure('**b', position: 2, message: '"a" expected'));
        expect(
            parser, isParseFailure('#a', position: 0, message: '"a" expected'));
        expect(parser, isParseSuccess('a*', 'a', position: 1));
      });
    });
  });
  group('character', () {
    group('anyOf', () {
      final parser = anyOf('uncopyrightable');
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('g', 'g'));
        expect(parser, isParseSuccess('h', 'h'));
        expect(parser, isParseSuccess('i', 'i'));
        expect(parser, isParseSuccess('o', 'o'));
        expect(parser, isParseSuccess('p', 'p'));
        expect(parser, isParseSuccess('r', 'r'));
        expect(parser, isParseSuccess('t', 't'));
        expect(parser, isParseSuccess('y', 'y'));
        expect(parser,
            isParseFailure('x', message: 'any of "uncopyrightable" expected'));
      });
    });
    group('noneOf', () {
      final parser = noneOf('uncopyrightable');
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('x', 'x'));
        expect(parser,
            isParseFailure('c', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('g', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('h', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('i', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('o', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('p', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('r', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('t', message: 'none of "uncopyrightable" expected'));
        expect(parser,
            isParseFailure('y', message: 'none of "uncopyrightable" expected'));
      });
    });
    group('char', () {
      expectParserInvariants(char('a'));
      test('with string', () {
        final parser = char('a');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(parser, isParseFailure('', message: '"a" expected'));
      });
      test('with message', () {
        final parser = char('a', 'lowercase a');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseFailure('b', message: 'lowercase a'));
        expect(parser, isParseFailure('', message: 'lowercase a'));
      });
      test('char invalid', () {
        expect(() => char('ab'), throwsA(isAssertionError));
      }, skip: !hasAssertionsEnabled());
      <String, String>{
        '\\x00': '\x00',
        '\\b': '\b',
        '\\t': '\t',
        '\\n': '\n',
        '\\v': '\v',
        '\\f': '\f',
        '\\r': '\r',
        '\\"': '"',
        "\\'": "'",
        '\\\\': '\\',
        '☠': '\u2620',
        ' ': ' ',
      }.forEach((key, value) {
        test('char("$key")', () {
          final parser = char(value);
          expect(parser, isParseSuccess(value, value));
          expect(parser, isParseFailure('a', message: '"$key" expected'));
        });
      });
    });
    group('charIgnoringCase', () {
      expectParserInvariants(charIgnoringCase('a'));
      test('with lowercase string', () {
        final parser = charIgnoringCase('a');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser,
            isParseFailure('b', message: '"a" (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '"a" (case-insensitive) expected'));
      });
      test('with uppercase string', () {
        final parser = charIgnoringCase('A');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser,
            isParseFailure('b', message: '"A" (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '"A" (case-insensitive) expected'));
      });
      test('with custom message', () {
        final parser = charIgnoringCase('a', 'upper or lower');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser, isParseFailure('b', message: 'upper or lower'));
        expect(parser, isParseFailure('', message: 'upper or lower'));
      });
      test('with single char', () {
        final parser = charIgnoringCase('1');
        expect(parser, isParseSuccess('1', '1'));
        expect(parser,
            isParseFailure('a', message: '"1" (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '"1" (case-insensitive) expected'));
      });
      test('char invalid', () {
        expect(() => charIgnoringCase('ab'), throwsA(isAssertionError));
      }, skip: !hasAssertionsEnabled());
    });
    group('digit', () {
      final parser = digit();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('1', '1'));
        expect(parser, isParseSuccess('9', '9'));
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
      });
    });
    group('letter', () {
      final parser = letter();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('X', 'X'));
        expect(parser, isParseFailure('', message: 'letter expected'));
        expect(parser, isParseFailure('0', message: 'letter expected'));
      });
    });
    group('lowercase', () {
      final parser = lowercase();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('z', 'z'));
        expect(
            parser, isParseFailure('', message: 'lowercase letter expected'));
        expect(
            parser, isParseFailure('A', message: 'lowercase letter expected'));
        expect(
            parser, isParseFailure('0', message: 'lowercase letter expected'));
      });
    });
    group('pattern', () {
      expectParserInvariants(pattern('^ad-f'));
      test('with single', () {
        final parser = pattern('abc');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseFailure('d', message: '[abc] expected'));
        expect(parser, isParseFailure('', message: '[abc] expected'));
      });
      test('with range', () {
        final parser = pattern('a-c');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseFailure('d', message: '[a-c] expected'));
        expect(parser, isParseFailure('', message: '[a-c] expected'));
      });
      test('with overlapping range', () {
        final parser = pattern('b-da-c');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseFailure('e', message: '[b-da-c] expected'));
        expect(parser, isParseFailure('', message: '[b-da-c] expected'));
      });
      test('with adjacent range', () {
        final parser = pattern('c-ea-c');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseSuccess('e', 'e'));
        expect(parser, isParseFailure('f', message: '[c-ea-c] expected'));
        expect(parser, isParseFailure('', message: '[c-ea-c] expected'));
      });
      test('with prefix range', () {
        final parser = pattern('a-ea-c');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseSuccess('e', 'e'));
        expect(parser, isParseFailure('f', message: '[a-ea-c] expected'));
        expect(parser, isParseFailure('', message: '[a-ea-c] expected'));
      });
      test('with postfix range', () {
        final parser = pattern('a-ec-e');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseSuccess('e', 'e'));
        expect(parser, isParseFailure('f', message: '[a-ec-e] expected'));
        expect(parser, isParseFailure('', message: '[a-ec-e] expected'));
      });
      test('with repeated range', () {
        final parser = pattern('a-ea-e');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseSuccess('e', 'e'));
        expect(parser, isParseFailure('f', message: '[a-ea-e] expected'));
        expect(parser, isParseFailure('', message: '[a-ea-e] expected'));
      });
      test('with composed range', () {
        final parser = pattern('ac-df-');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseSuccess('f', 'f'));
        expect(parser, isParseSuccess('-', '-'));
        expect(parser, isParseFailure('b', message: '[ac-df-] expected'));
        expect(parser, isParseFailure('e', message: '[ac-df-] expected'));
        expect(parser, isParseFailure('g', message: '[ac-df-] expected'));
        expect(parser, isParseFailure('', message: '[ac-df-] expected'));
      });
      test('with negated single', () {
        final parser = pattern('^a');
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('a', message: '[^a] expected'));
        expect(parser, isParseFailure('', message: '[^a] expected'));
      });
      test('with negated range', () {
        final parser = pattern('^a-c');
        expect(parser, isParseSuccess('d', 'd'));
        expect(parser, isParseFailure('a', message: '[^a-c] expected'));
        expect(parser, isParseFailure('b', message: '[^a-c] expected'));
        expect(parser, isParseFailure('c', message: '[^a-c] expected'));
        expect(parser, isParseFailure('', message: '[^a-c] expected'));
      });
      test('with negate but without range', () {
        final parser = pattern('^a-');
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('a', message: '[^a-] expected'));
        expect(parser, isParseFailure('-', message: '[^a-] expected'));
        expect(parser, isParseFailure('', message: '[^a-] expected'));
      });
      test('with error', () {
        expect(() => pattern('c-a'), throwsA(isAssertionError));
      }, skip: !hasAssertionsEnabled());
      group('ignore case', () {
        expectParserInvariants(patternIgnoreCase('^ad-f'));
        test('with single', () {
          final parser = patternIgnoreCase('abc');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(
              parser,
              isParseFailure('d',
                  message: '[abc] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('D',
                  message: '[abc] (case-insensitive) expected'));
          expect(parser,
              isParseFailure('', message: '[abc] (case-insensitive) expected'));
        });
        test('with range', () {
          final parser = patternIgnoreCase('a-c');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(
              parser,
              isParseFailure('d',
                  message: '[a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('D',
                  message: '[a-c] (case-insensitive) expected'));
          expect(parser,
              isParseFailure('', message: '[a-c] (case-insensitive) expected'));
        });
        test('with overlapping range', () {
          final parser = patternIgnoreCase('b-da-c');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(
              parser,
              isParseFailure('e',
                  message: '[b-da-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('E',
                  message: '[b-da-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[b-da-c] (case-insensitive) expected'));
        });
        test('with adjacent range', () {
          final parser = patternIgnoreCase('c-ea-c');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(parser, isParseSuccess('e', 'e'));
          expect(parser, isParseSuccess('E', 'E'));
          expect(
              parser,
              isParseFailure('f',
                  message: '[c-ea-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('F',
                  message: '[c-ea-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[c-ea-c] (case-insensitive) expected'));
        });
        test('with prefix range', () {
          final parser = patternIgnoreCase('a-ea-c');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(parser, isParseSuccess('e', 'e'));
          expect(parser, isParseSuccess('E', 'E'));
          expect(
              parser,
              isParseFailure('f',
                  message: '[a-ea-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[a-ea-c] (case-insensitive) expected'));
        });
        test('with postfix range', () {
          final parser = patternIgnoreCase('a-ec-e');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(parser, isParseSuccess('e', 'e'));
          expect(parser, isParseSuccess('E', 'E'));
          expect(
              parser,
              isParseFailure('f',
                  message: '[a-ec-e] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[a-ec-e] (case-insensitive) expected'));
        });
        test('with repeated range', () {
          final parser = patternIgnoreCase('a-ea-e');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(parser, isParseSuccess('e', 'e'));
          expect(parser, isParseSuccess('E', 'E'));
          expect(
              parser,
              isParseFailure('f',
                  message: '[a-ea-e] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[a-ea-e] (case-insensitive) expected'));
        });
        test('with composed range', () {
          final parser = patternIgnoreCase('ac-df-');
          expect(parser, isParseSuccess('a', 'a'));
          expect(parser, isParseSuccess('A', 'A'));
          expect(parser, isParseSuccess('c', 'c'));
          expect(parser, isParseSuccess('C', 'C'));
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(parser, isParseSuccess('f', 'f'));
          expect(parser, isParseSuccess('F', 'F'));
          expect(parser, isParseSuccess('-', '-'));
          expect(
              parser,
              isParseFailure('b',
                  message: '[ac-df-] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('e',
                  message: '[ac-df-] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('g',
                  message: '[ac-df-] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[ac-df-] (case-insensitive) expected'));
        });
        test('with negated single', () {
          final parser = patternIgnoreCase('^a');
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(parser,
              isParseFailure('a', message: '[^a] (case-insensitive) expected'));
          expect(parser,
              isParseFailure('A', message: '[^a] (case-insensitive) expected'));
          expect(parser,
              isParseFailure('', message: '[^a] (case-insensitive) expected'));
        });
        test('with negated range', () {
          final parser = patternIgnoreCase('^a-c');
          expect(parser, isParseSuccess('d', 'd'));
          expect(parser, isParseSuccess('D', 'D'));
          expect(
              parser,
              isParseFailure('a',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('A',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('b',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('B',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('c',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('C',
                  message: '[^a-c] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('',
                  message: '[^a-c] (case-insensitive) expected'));
        });
        test('with negate but without range', () {
          final parser = patternIgnoreCase('^a-');
          expect(parser, isParseSuccess('b', 'b'));
          expect(parser, isParseSuccess('B', 'B'));
          expect(
              parser,
              isParseFailure('a',
                  message: '[^a-] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('A',
                  message: '[^a-] (case-insensitive) expected'));
          expect(
              parser,
              isParseFailure('-',
                  message: '[^a-] (case-insensitive) expected'));
          expect(parser,
              isParseFailure('', message: '[^a-] (case-insensitive) expected'));
        });
        test('with error', () {
          expect(() => patternIgnoreCase('c-a'), throwsA(isAssertionError));
        }, skip: !hasAssertionsEnabled());
      });
      // T
      // group('large ranges', () {
      //   final parser = pattern('\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff');
      //   expectParserInvariants(parser);
      //   test('mathematical symbols', () {
      //     expect(parser, isParseSuccess('∉', '∉'));
      //     expect(parser, isParseSuccess('⟃', '⟃'));
      //     expect(parser, isParseSuccess('⦻', '⦻'));
      //     expect(
      //         parser,
      //         isParseFailure('a',
      //             message:
      //                 '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected'));
      //     expect(
      //         parser,
      //         isParseFailure('',
      //             message:
      //                 '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected'));
      //   });
      // });
      // group('without anything', () {
      //   final parser = pattern('');
      //   expectParserInvariants(parser);
      //   test('test', () {
      //     for (var i = 0; i <= 0xffff; i++) {
      //       final character = String.fromCharCode(i);
      //       expect(parser, isParseFailure(character, message: '[] expected'));
      //     }
      //   });
      // });
      // group('with everything', () {
      //   final parser = pattern('\x00-\uffff');
      //   expectParserInvariants(parser);
      //   test('test', () {
      //     for (var i = 0; i <= 0xffff; i++) {
      //       final character = String.fromCharCode(i);
      //       expect(parser, isParseSuccess(character, character));
      //     }
      //   });
      // });
    });
    group('range', () {
      final parser = range('e', 'o');
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('e', 'e'));
        expect(parser, isParseSuccess('i', 'i'));
        expect(parser, isParseSuccess('o', 'o'));
        expect(parser, isParseFailure('p', message: '[e-o] expected'));
        expect(parser, isParseFailure('d', message: '[e-o] expected'));
        expect(parser, isParseFailure('', message: '[e-o] expected'));
      });
      test('invalid', () {
        expect(() => range('o', 'e'), throwsA(isAssertionError));
      }, skip: !hasAssertionsEnabled());
    });
    group('uppercase', () {
      final parser = uppercase();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser, isParseSuccess('Z', 'Z'));
        expect(
            parser, isParseFailure('a', message: 'uppercase letter expected'));
        expect(
            parser, isParseFailure('0', message: 'uppercase letter expected'));
        expect(
            parser, isParseFailure('', message: 'uppercase letter expected'));
      });
    });
    group('whitespace', () {
      final parser = whitespace();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess(' ', ' '));
        expect(parser, isParseSuccess('\t', '\t'));
        expect(parser, isParseSuccess('\r', '\r'));
        expect(parser, isParseSuccess('\f', '\f'));
        expect(parser, isParseFailure('z', message: 'whitespace expected'));
        expect(parser, isParseFailure('', message: 'whitespace expected'));
      });
      test('unicode', () {
        final whitespace = {
          9,
          10,
          11,
          12,
          13,
          32,
          133,
          160,
          5760,
          8192,
          8193,
          8194,
          8195,
          8196,
          8197,
          8198,
          8199,
          8200,
          8201,
          8202,
          8232,
          8233,
          8239,
          8287,
          12288,
          65279
        };
        for (var i = 0; i < 65536; i++) {
          var character = String.fromCharCode(i);
          expect(
              parser,
              whitespace.contains(i)
                  ? isParseSuccess(character, character)
                  : isParseFailure(character));
        }
      });
    });
    group('word', () {
      final parser = word();
      expectParserInvariants(parser);
      test('default', () {
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('z', 'z'));
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser, isParseSuccess('Z', 'Z'));
        expect(parser, isParseSuccess('0', '0'));
        expect(parser, isParseSuccess('9', '9'));
        expect(parser, isParseSuccess('_', '_'));
        expect(
            parser, isParseFailure('-', message: 'letter or digit expected'));
        expect(parser, isParseFailure(''));
      });
    });
  });
  group('combinator', () {
    group('and', () {
      expectParserInvariants(any().and());
      test('default', () {
        final parser = char('a').and();
        expect(parser, isParseSuccess('a', 'a', position: 0));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(parser, isParseFailure('', message: '"a" expected'));
      });
    });
    group('choice', () {
      expectParserInvariants(any().or(word()));
      test('operator', () {
        final parser = char('a') | char('b');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('c', message: '"b" expected'));
        expect(parser, isParseFailure('', message: '"b" expected'));
      });
      test('converter', () {
        final parser = [char('a'), char('b')].toChoiceParser();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('c', message: '"b" expected'));
        expect(parser, isParseFailure('', message: '"b" expected'));
      });
      test('two', () {
        final parser = char('a').or(char('b'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('c', message: '"b" expected'));
        expect(parser, isParseFailure('', message: '"b" expected'));
      });
      test('three', () {
        final parser = char('a').or(char('b')).or(char('c'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseSuccess('c', 'c'));
        expect(parser, isParseFailure('d', message: '"c" expected'));
        expect(parser, isParseFailure('', message: '"c" expected'));
      });
      test('cut', () {
        final parser = [
          seq3(char('a'), cut(), char('1')),
          seq3(char('b'), cut(), char('2')),
        ].toChoiceParser().flatten();
        expect(parser, isParseSuccess('a1', 'a1'));
        expect(parser, isParseSuccess('b2', 'b2'));
        expect(
            parser, isParseFailure('a2', message: '"1" expected', position: 1));
        expect(
            parser, isParseFailure('b1', message: '"2" expected', position: 1));
        expect(
            parser, isParseFailure('c', message: '"b" expected', position: 0));
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
          expect(ChoiceParser([first, second]), isA<Parser<String>>());
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
          expect(ChoiceParser([first, second]), isA<Parser<num>>());
          expect([first, second].toChoiceParser(), isA<Parser<num>>());
          // TODO(renggli): https://github.com/dart-lang/language/issues/1557
          // expect(first | second, isA<Parser<num>>());
          // expect(first.or(second), isA<Parser<num>>());
        });
      });
    });
    group('not', () {
      expectParserInvariants(any().not());
      test('default', () {
        final parser = char('a').not('not "a" expected');
        expect(parser, isParseFailure('a', message: 'not "a" expected'));
        expect(
            parser,
            isParseSuccess('b', isFailure(position: 0, message: '"a" expected'),
                position: 0));
        expect(
            parser,
            isParseSuccess('', isFailure(position: 0, message: '"a" expected'),
                position: 0));
      });
      test('neg', () {
        final parser = digit().neg('no digit expected');
        expect(parser, isParseFailure('1', message: 'no digit expected'));
        expect(parser, isParseFailure('9', message: 'no digit expected'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess(' ', ' '));
        expect(parser, isParseFailure('', message: 'input expected'));
      });
    });
    group('optional', () {
      expectParserInvariants(any().optional());
      test('without default', () {
        final parser = char('a').optional();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', isNull, position: 0));
        expect(parser, isParseSuccess('', isNull));
      });
      test('with default', () {
        final parser = char('a').optionalWith('0');
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', '0', position: 0));
        expect(parser, isParseSuccess('', '0'));
      });
      test('cut', () {
        final parser = seq3(char('a'), cut(), char('1')).optional().flatten();
        expect(parser, isParseSuccess('', ''));
        expect(parser, isParseSuccess('a1', 'a1'));
        expect(
            parser, isParseFailure('a2', message: '"1" expected', position: 1));
        expect(parser, isParseSuccess('b', '', position: 0));
      });
    });
    group('sequence', () {
      expectParserInvariants(any().seq(word()));
      test('operator', () {
        final parser = char('a') & char('b');
        expect(parser, isParseSuccess('ab', ['a', 'b']));
        expect(parser, isParseFailure(''));
        expect(parser, isParseFailure('x'));
        expect(parser, isParseFailure('a', position: 1));
        expect(parser, isParseFailure('ax', position: 1));
      });
      test('converter', () {
        final parser = [char('a'), char('b')].toSequenceParser();
        expect(parser, isParseSuccess('ab', ['a', 'b']));
        expect(parser, isParseFailure(''));
        expect(parser, isParseFailure('x'));
        expect(parser, isParseFailure('a', position: 1));
        expect(parser, isParseFailure('ax', position: 1));
      });
      test('two', () {
        final parser = char('a').seq(char('b'));
        expect(parser, isParseSuccess('ab', ['a', 'b']));
        expect(parser, isParseFailure(''));
        expect(parser, isParseFailure('x'));
        expect(parser, isParseFailure('a', position: 1));
        expect(parser, isParseFailure('ax', position: 1));
      });
      test('three', () {
        final parser = char('a').seq(char('b')).seq(char('c'));
        expect(parser, isParseSuccess('abc', ['a', 'b', 'c']));
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
        final parser = char('a').settable();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseFailure('b', message: '"a" expected'));
        expect(parser, isParseFailure(''));
      });
      test('undefined', () {
        final parser = undefined();
        expect(parser, isParseFailure('', message: 'undefined parser'));
        expect(parser, isParseFailure('a', message: 'undefined parser'));
        parser.set(char('a'));
        expect(parser, isParseSuccess('a', 'a'));
      });
    });
    group('skip', () {
      final inner = digit();
      group('none', () {
        final parser = inner.skip();
        expectParserInvariants(parser);
        test('default', () {
          expect(parser, same(inner));
          expect(parser, isParseSuccess('1', '1'));
          expect(parser, isParseSuccess('2', '2'));
          expect(parser, isParseFailure('', message: 'digit expected'));
        });
      });
      group('before', () {
        final parser = inner.skip(before: char('*'));
        expectParserInvariants(parser);
        test('default', () {
          expect(parser, isParseSuccess('*1', '1'));
          expect(parser, isParseSuccess('*2', '2'));
          expect(parser, isParseFailure('', message: '"*" expected'));
          expect(parser, isParseFailure('1', message: '"*" expected'));
          expect(parser,
              isParseFailure('*', message: 'digit expected', position: 1));
          expect(parser,
              isParseFailure('*a', message: 'digit expected', position: 1));
        });
      });
      group('after', () {
        final parser = inner.skip(after: char('!'));
        expectParserInvariants(parser);
        test('default', () {
          expect(parser, isParseSuccess('1!', '1'));
          expect(parser, isParseSuccess('2!', '2'));
          expect(parser, isParseFailure('', message: 'digit expected'));
          expect(parser,
              isParseFailure('1', message: '"!" expected', position: 1));
          expect(parser, isParseFailure('!', message: 'digit expected'));
          expect(parser, isParseFailure('a!', message: 'digit expected'));
        });
      });
      group('before & after', () {
        final parser = inner.skip(before: char('*'), after: char('!'));
        expectParserInvariants(parser);
        test('default', () {
          expect(parser, isParseSuccess('*1!', '1'));
          expect(parser, isParseSuccess('*2!', '2'));
          expect(parser, isParseFailure('', message: '"*" expected'));
          expect(parser, isParseFailure('1', message: '"*" expected'));
          expect(parser, isParseFailure('1!', message: '"*" expected'));
          expect(parser,
              isParseFailure('*', message: 'digit expected', position: 1));
          expect(parser,
              isParseFailure('*1', message: '"!" expected', position: 2));
          expect(parser,
              isParseFailure('*1*', message: '"!" expected', position: 2));
        });
      });
    });
  });
  group('misc', () {
    group('end', () {
      expectParserInvariants(endOfInput());
      test('default', () {
        final parser = char('a').end();
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(parser, isParseSuccess('a', 'a'));
        expect(
            parser,
            isParseFailure('aa',
                position: 1, message: 'end of input expected'));
      });
    });
    group('epsilon', () {
      expectParserInvariants(epsilon());
      test('default', () {
        final parser = epsilon();
        expect(parser, isParseSuccess('', isNull));
        expect(parser, isParseSuccess('a', isNull, position: 0));
      });
    });
    group('failure', () {
      expectParserInvariants(failure());
      test('default', () {
        final parser = failure('failure');
        expect(parser, isParseFailure('', message: 'failure'));
        expect(parser, isParseFailure('a', message: 'failure'));
      });
    });
    group('failure message', () {
      expectParserInvariants(digit().failure('NaN'));
      test('default', () {
        final parser = digit().repeat(2).failure('NaN');
        expect(parser, isParseFailure('', message: 'NaN'));
        expect(parser, isParseFailure('a', message: 'NaN'));
        expect(parser, isParseFailure('1a', message: 'NaN'));
        expect(parser, isParseSuccess('12', ['1', '2']));
      });
    });
    group('labeled', () {
      expectParserInvariants(any().labeled('anything'));
      test('default', () {
        final parser = char('*').labeled('asterisk');
        expect(parser.label, 'asterisk');
        expect(parser, isParseSuccess('*', '*'));
        expect(parser, isParseFailure('a', message: '"*" expected'));
      });
    });
    group('newline', () {
      expectParserInvariants(newline());
      test('default', () {
        final parser = newline();
        expect(parser, isParseSuccess('\n', '\n'));
        expect(parser, isParseSuccess('\r\n', '\r\n'));
        expect(parser, isParseSuccess('\r', '\r'));
        expect(parser, isParseFailure('', message: 'newline expected'));
        expect(parser, isParseFailure('\f', message: 'newline expected'));
      });
    });
    group('position', () {
      expectParserInvariants(position());
      test('default', () {
        final parser = (any().star() & position()).pick(-1);
        expect(parser, isParseSuccess('', 0));
        expect(parser, isParseSuccess('a', 1));
        expect(parser, isParseSuccess('aa', 2));
        expect(parser, isParseSuccess('aaa', 3));
      });
    });
    group('cut', () {
      expectParserInvariants(cut());
    });
  });
  group('predicate', () {
    group('any', () {
      expectParserInvariants(any());
      test('default', () {
        final parser = any();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('b', 'b'));
        expect(parser, isParseFailure('', message: 'input expected'));
      });
    });
    group('pattern', () {
      expectParserInvariants(PatternParser('42', 'number expected'));
      test('string', () {
        final parser = PatternParser('42', 'number expected');
        expect(parser,
            isParseSuccess('42', isPatternMatch('42', start: 0, end: 2)));
        expect(parser, isParseFailure('4', message: 'number expected'));
        expect(parser, isParseFailure('43', message: 'number expected'));
      });
      test('regexp', () {
        final parser = PatternParser(RegExp(r'\d+'), 'digits expected');
        expect(
          parser,
          isParseSuccess('1', isPatternMatch('1', start: 0, end: 1)),
        );
        expect(
          parser,
          isParseSuccess('12', isPatternMatch('12', start: 0, end: 2)),
        );
        expect(
          parser,
          isParseSuccess('123', isPatternMatch('123', start: 0, end: 3)),
        );
        expect(
          parser,
          isParseSuccess('1a', isPatternMatch('1', start: 0, end: 1),
              position: 1),
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
          isParseSuccess('1,2', isPatternMatch('1,2', groups: ['1', '2'])),
        );
        expect(
          parser,
          isParseSuccess('1, 2', isPatternMatch('1, 2', groups: ['1', '2'])),
        );
        expect(
          parser,
          isParseSuccess('1 ,2', isPatternMatch('1 ,2', groups: ['1', '2'])),
        );
        expect(
          parser,
          isParseSuccess('1 , 2', isPatternMatch('1 , 2', groups: ['1', '2'])),
        );
        expect(
          parser,
          isParseSuccess('12,3', isPatternMatch('12,3', groups: ['12', '3'])),
        );
        expect(
          parser,
          isParseSuccess('12, 3', isPatternMatch('12, 3', groups: ['12', '3'])),
        );
        expect(
          parser,
          isParseSuccess('12 ,3', isPatternMatch('12 ,3', groups: ['12', '3'])),
        );
      });
    });
    group('string', () {
      expectParserInvariants(string('foo'));
      test('default', () {
        final parser = string('foo');
        expect(parser, isParseSuccess('foo', 'foo'));
        expect(parser, isParseFailure('', message: '"foo" expected'));
        expect(parser, isParseFailure('f', message: '"foo" expected'));
        expect(parser, isParseFailure('fo', message: '"foo" expected'));
        expect(parser, isParseFailure('Foo', message: '"foo" expected'));
      });
      test('convert empty', () {
        final parser = ''.toParser();
        expect(parser, isParseSuccess('', ''));
      });
      test('convert single char', () {
        final parser = 'a'.toParser();
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseFailure('A', message: '"a" expected'));
      });
      test('convert single char (case-insensitive)', () {
        final parser = 'a'.toParser(caseInsensitive: true);
        expect(parser, isParseSuccess('a', 'a'));
        expect(parser, isParseSuccess('A', 'A'));
        expect(parser,
            isParseFailure('b', message: '"a" (case-insensitive) expected'));
      });
      test('convert pattern', () {
        final parser = 'a-z'.toParser(isPattern: true);
        expect(parser, isParseSuccess('x', 'x'));
        expect(parser, isParseFailure('X', message: '[a-z] expected'));
      });
      test('convert pattern (case-insensitive)', () {
        final parser = 'a-z'.toParser(isPattern: true, caseInsensitive: true);
        expect(parser, isParseSuccess('x', 'x'));
        expect(parser, isParseSuccess('X', 'X'));
        expect(parser,
            isParseFailure('1', message: '[a-z] (case-insensitive) expected'));
      });
      test('convert multiple chars', () {
        final parser = 'foo'.toParser();
        expect(parser, isParseSuccess('foo', 'foo'));
        expect(parser, isParseFailure('Foo', message: '"foo" expected'));
      });
      test('convert multiple chars (case-insensitive)', () {
        final parser = 'foo'.toParser(caseInsensitive: true);
        expect(parser, isParseSuccess('foo', 'foo'));
        expect(parser, isParseSuccess('Foo', 'Foo'));
        expect(
            parser,
            isParseFailure('bar',
                message: '"foo" (case-insensitive) expected'));
      });
    });
    group('stringIgnoreCase', () {
      expectParserInvariants(stringIgnoreCase('foo'));
      test('default', () {
        final parser = stringIgnoreCase('foo');
        expect(parser, isParseSuccess('foo', 'foo'));
        expect(parser, isParseSuccess('FOO', 'FOO'));
        expect(parser, isParseSuccess('fOo', 'fOo'));
        expect(parser,
            isParseFailure('', message: '"foo" (case-insensitive) expected'));
        expect(parser,
            isParseFailure('f', message: '"foo" (case-insensitive) expected'));
        expect(parser,
            isParseFailure('Fo', message: '"foo" (case-insensitive) expected'));
      });
    });
  });
  group('repeater', () {
    group('greedy', () {
      expectParserInvariants(any().starGreedy(digit()));
      test('star', () {
        final parser = word().starGreedy(digit());
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        expect(parser, isParseFailure('ab', message: 'digit expected'));
        expect(parser, isParseSuccess('1', [], position: 0));
        expect(parser, isParseSuccess('a1', ['a'], position: 1));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('12', ['1'], position: 1));
        expect(parser, isParseSuccess('a12', ['a', '1'], position: 2));
        expect(parser, isParseSuccess('ab12', ['a', 'b', '1'], position: 3));
        expect(
            parser, isParseSuccess('abc12', ['a', 'b', 'c', '1'], position: 4));
        expect(parser, isParseSuccess('123', ['1', '2'], position: 2));
        expect(parser, isParseSuccess('a123', ['a', '1', '2'], position: 3));
        expect(
            parser, isParseSuccess('ab123', ['a', 'b', '1', '2'], position: 4));
        expect(parser,
            isParseSuccess('abc123', ['a', 'b', 'c', '1', '2'], position: 5));
      });
      test('plus', () {
        final parser = word().plusGreedy(digit());
        expect(parser, isParseFailure('', message: 'letter or digit expected'));
        expect(parser,
            isParseFailure('a', position: 1, message: 'digit expected'));
        expect(parser,
            isParseFailure('ab', position: 1, message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'digit expected'));
        expect(parser, isParseSuccess('a1', ['a'], position: 1));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('12', ['1'], position: 1));
        expect(parser, isParseSuccess('a12', ['a', '1'], position: 2));
        expect(parser, isParseSuccess('ab12', ['a', 'b', '1'], position: 3));
        expect(
            parser, isParseSuccess('abc12', ['a', 'b', 'c', '1'], position: 4));
        expect(parser, isParseSuccess('123', ['1', '2'], position: 2));
        expect(parser, isParseSuccess('a123', ['a', '1', '2'], position: 3));
        expect(
            parser, isParseSuccess('ab123', ['a', 'b', '1', '2'], position: 4));
        expect(parser,
            isParseSuccess('abc123', ['a', 'b', 'c', '1', '2'], position: 5));
      });
      test('repeat', () {
        final parser = word().repeatGreedy(digit(), 2, 4);
        expect(parser, isParseFailure('', message: 'letter or digit expected'));
        expect(
            parser,
            isParseFailure('a',
                position: 1, message: 'letter or digit expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'digit expected'));
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
        expect(parser,
            isParseFailure('a1', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(
            parser, isParseSuccess('abcd1', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde1', position: 2, message: 'digit expected'));
        expect(parser,
            isParseFailure('12', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('a12', ['a', '1'], position: 2));
        expect(parser, isParseSuccess('ab12', ['a', 'b', '1'], position: 3));
        expect(
            parser, isParseSuccess('abc12', ['a', 'b', 'c', '1'], position: 4));
        expect(parser,
            isParseSuccess('abcd12', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde12', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('123', ['1', '2'], position: 2));
        expect(parser, isParseSuccess('a123', ['a', '1', '2'], position: 3));
        expect(
            parser, isParseSuccess('ab123', ['a', 'b', '1', '2'], position: 4));
        expect(parser,
            isParseSuccess('abc123', ['a', 'b', 'c', '1'], position: 4));
        expect(parser,
            isParseSuccess('abcd123', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde123', position: 2, message: 'digit expected'));
      });
      test('repeat unbounded', () {
        final inputLetter = List.filled(100000, 'a');
        final inputDigit = List.filled(100000, '1');
        final parser = word().repeatGreedy(digit(), 2, unbounded);
        expect(
            parser,
            isParseSuccess('${inputLetter.join()}1', inputLetter,
                position: inputLetter.length));
        expect(
            parser,
            isParseSuccess('${inputDigit.join()}1', inputDigit,
                position: inputDigit.length));
      });
      group('cut', () {
        // TODO: Not clear what the semantics of a cut in a greedy parser are?
      });
    });
    group('lazy', () {
      expectParserInvariants(any().starLazy(digit()));
      test('star', () {
        final parser = word().starLazy(digit());
        expect(parser, isParseFailure(''));
        expect(parser,
            isParseFailure('a', position: 1, message: 'digit expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('1', [], position: 0));
        expect(parser, isParseSuccess('a1', ['a'], position: 1));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('12', [], position: 0));
        expect(parser, isParseSuccess('a12', ['a'], position: 1));
        expect(parser, isParseSuccess('ab12', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc12', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('123', [], position: 0));
        expect(parser, isParseSuccess('a123', ['a'], position: 1));
        expect(parser, isParseSuccess('ab123', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc123', ['a', 'b', 'c'], position: 3));
      });
      test('plus', () {
        final parser = word().plusLazy(digit());
        expect(parser, isParseFailure(''));
        expect(parser,
            isParseFailure('a', position: 1, message: 'digit expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'digit expected'));
        expect(parser,
            isParseFailure('1', position: 1, message: 'digit expected'));
        expect(parser, isParseSuccess('a1', ['a'], position: 1));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('12', ['1'], position: 1));
        expect(parser, isParseSuccess('a12', ['a'], position: 1));
        expect(parser, isParseSuccess('ab12', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc12', ['a', 'b', 'c'], position: 3));
        expect(parser, isParseSuccess('123', ['1'], position: 1));
        expect(parser, isParseSuccess('a123', ['a'], position: 1));
        expect(parser, isParseSuccess('ab123', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc123', ['a', 'b', 'c'], position: 3));
      });
      test('repeat', () {
        final parser = word().repeatLazy(digit(), 2, 4);
        expect(parser, isParseFailure('', message: 'letter or digit expected'));
        expect(
            parser,
            isParseFailure('a',
                position: 1, message: 'letter or digit expected'));
        expect(parser,
            isParseFailure('ab', position: 2, message: 'digit expected'));
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
        expect(parser,
            isParseFailure('a1', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('ab1', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc1', ['a', 'b', 'c'], position: 3));
        expect(
            parser, isParseSuccess('abcd1', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde1', position: 4, message: 'digit expected'));
        expect(parser,
            isParseFailure('12', position: 2, message: 'digit expected'));
        expect(parser, isParseSuccess('a12', ['a', '1'], position: 2));
        expect(parser, isParseSuccess('ab12', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc12', ['a', 'b', 'c'], position: 3));
        expect(parser,
            isParseSuccess('abcd12', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde12', position: 4, message: 'digit expected'));
        expect(parser, isParseSuccess('123', ['1', '2'], position: 2));
        expect(parser, isParseSuccess('a123', ['a', '1'], position: 2));
        expect(parser, isParseSuccess('ab123', ['a', 'b'], position: 2));
        expect(parser, isParseSuccess('abc123', ['a', 'b', 'c'], position: 3));
        expect(parser,
            isParseSuccess('abcd123', ['a', 'b', 'c', 'd'], position: 4));
        expect(parser,
            isParseFailure('abcde123', position: 4, message: 'digit expected'));
      });
      test('repeat unbounded', () {
        final input = List.filled(100000, 'a');
        final parser = word().repeatLazy(digit(), 2, unbounded);
        expect(
            parser,
            isParseSuccess('${input.join()}1111', input,
                position: input.length));
      });
      group('cut', () {
        test('none', () {
          final parser = seq2(char('a'), char('b'))
              .flatten()
              .starLazy(seq2(char('1'), char('2')).flatten());
          expect(
              parser, isParseFailure('', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('1', message: '"2" expected', position: 1));
          expect(parser,
              isParseFailure('a', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('ab', message: '"1" expected', position: 2));
          expect(parser,
              isParseFailure('ab1', message: '"2" expected', position: 3));
          expect(parser, isParseSuccess('ab12', ['ab'], position: 2));
        });
        test('on repeater', () {
          final parser = seq3(char('a'), cut(), char('b'))
              .flatten()
              .starLazy(seq2(char('1'), char('2')).flatten());
          expect(
              parser, isParseFailure('', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('1', message: '"2" expected', position: 1));
          expect(parser,
              isParseFailure('a', message: '"b" expected', position: 1));
          expect(parser,
              isParseFailure('ab', message: '"1" expected', position: 2));
          expect(parser,
              isParseFailure('ab1', message: '"2" expected', position: 3));
          expect(parser, isParseSuccess('ab12', ['ab'], position: 2));
        });
        test('on limiter', () {
          final parser = seq2(char('a'), char('b'))
              .flatten()
              .starLazy(seq3(char('1'), cut(), char('2')).flatten());
          expect(
              parser, isParseFailure('', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('1', message: '"2" expected', position: 1));
          expect(parser,
              isParseFailure('a', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('ab', message: '"1" expected', position: 2));
          expect(parser,
              isParseFailure('ab1', message: '"2" expected', position: 3));
          expect(parser, isParseSuccess('ab12', ['ab'], position: 2));
        });
        test('on both', () {
          final parser = seq3(char('a'), cut(), char('b'))
              .flatten()
              .starLazy(seq3(char('1'), cut(), char('2')).flatten());
          expect(
              parser, isParseFailure('', message: '"1" expected', position: 0));
          expect(parser,
              isParseFailure('1', message: '"2" expected', position: 1));
          expect(parser,
              isParseFailure('a', message: '"b" expected', position: 1));
          expect(parser,
              isParseFailure('ab', message: '"1" expected', position: 2));
          expect(parser,
              isParseFailure('ab1', message: '"2" expected', position: 3));
          expect(parser, isParseSuccess('ab12', ['ab'], position: 2));
        });
      });
    });
    group('possessive', () {
      expectParserInvariants(any().star());
      test('star', () {
        final parser = char('a').star();
        expect(parser, isParseSuccess('', []));
        expect(parser, isParseSuccess('a', ['a']));
        expect(parser, isParseSuccess('aa', ['a', 'a']));
        expect(parser, isParseSuccess('aaa', ['a', 'a', 'a']));
      });
      test('plus', () {
        final parser = char('a').plus();
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(parser, isParseSuccess('a', ['a']));
        expect(parser, isParseSuccess('aa', ['a', 'a']));
        expect(parser, isParseSuccess('aaa', ['a', 'a', 'a']));
      });
      test('repeat', () {
        final parser = char('a').repeat(2, 3);
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(
            parser, isParseFailure('a', position: 1, message: '"a" expected'));
        expect(parser, isParseSuccess('aa', ['a', 'a']));
        expect(parser, isParseSuccess('aaa', ['a', 'a', 'a']));
        expect(parser, isParseSuccess('aaaa', ['a', 'a', 'a'], position: 3));
      });
      test('repeat exact', () {
        final parser = char('a').repeat(2);
        expect(parser, isParseFailure('', message: '"a" expected'));
        expect(
            parser, isParseFailure('a', position: 1, message: '"a" expected'));
        expect(parser, isParseSuccess('aa', ['a', 'a']));
        expect(parser, isParseSuccess('aaa', ['a', 'a'], position: 2));
      });
      test('repeat unbounded', () {
        final input = List.filled(100000, 'a');
        final parser = char('a').repeat(2, unbounded);
        expect(parser, isParseSuccess(input.join(), input));
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
        expect(
            parser, isParseFailure('a', position: 1, message: '"a" expected'));
        expect(parser, isParseSuccess('aa', ['a', 'a']));
        expect(parser, isParseSuccess('aaa', ['a', 'a'], position: 2));
      });
      group('cut', () {
        test('none', () {
          final parser = seq2(char('a'), char('b')).flatten().star();
          expect(parser, isParseSuccess('', isEmpty));
          expect(parser, isParseSuccess('', isEmpty, position: 0));
          expect(parser, isParseSuccess('ab', ['ab']));
          expect(parser, isParseSuccess('aba', ['ab'], position: 2));
          expect(parser, isParseSuccess('abab', ['ab', 'ab']));
        });
        test('on repeater', () {
          final parser = seq3(char('a'), cut(), char('b')).flatten().star();
          expect(parser, isParseSuccess('', isEmpty));
          expect(parser,
              isParseFailure('a', message: '"b" expected', position: 1));
          expect(parser, isParseSuccess('ab', ['ab']));
          expect(parser,
              isParseFailure('aba', message: '"b" expected', position: 3));
          expect(parser, isParseSuccess('abab', ['ab', 'ab']));
        });
      });
    });
    group('separated', () {
      expectParserInvariants(digit().starSeparated(letter()));
      test('star', () {
        final parser = digit().starSeparated(letter());
        expect(parser, isParseSuccess('', isSeparatedList()));
        expect(parser, isParseSuccess('a', isSeparatedList(), position: 0));
        expect(parser, isParseSuccess('1', isSeparatedList(elements: ['1'])));
        expect(
            parser,
            isParseSuccess('1a', isSeparatedList(elements: ['1']),
                position: 1));
        expect(
            parser,
            isParseSuccess('1a2',
                isSeparatedList(elements: ['1', '2'], separators: ['a'])));
        expect(
            parser,
            isParseSuccess('1a2b',
                isSeparatedList(elements: ['1', '2'], separators: ['a']),
                position: 3));
        expect(
            parser,
            isParseSuccess(
                '1a2b3',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4',
                isSeparatedList(
                    elements: ['1', '2', '3', '4'],
                    separators: ['a', 'b', 'c'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4d',
                isSeparatedList(
                    elements: ['1', '2', '3', '4'],
                    separators: ['a', 'b', 'c']),
                position: 7));
      });
      test('plus', () {
        final parser = digit().plusSeparated(letter());
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        expect(parser, isParseSuccess('1', isSeparatedList(elements: ['1'])));
        expect(
            parser,
            isParseSuccess('1a', isSeparatedList(elements: ['1']),
                position: 1));
        expect(
            parser,
            isParseSuccess('1a2',
                isSeparatedList(elements: ['1', '2'], separators: ['a'])));
        expect(
            parser,
            isParseSuccess('1a2b',
                isSeparatedList(elements: ['1', '2'], separators: ['a']),
                position: 3));
        expect(
            parser,
            isParseSuccess(
                '1a2b3',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4',
                isSeparatedList(
                    elements: ['1', '2', '3', '4'],
                    separators: ['a', 'b', 'c'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4d',
                isSeparatedList(
                    elements: ['1', '2', '3', '4'],
                    separators: ['a', 'b', 'c']),
                position: 7));
      });
      test('times', () {
        final parser = digit().timesSeparated(letter(), 3);
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', message: 'letter expected', position: 1));
        expect(parser,
            isParseFailure('1a', message: 'digit expected', position: 2));
        expect(parser,
            isParseFailure('1a2', message: 'letter expected', position: 3));
        expect(parser,
            isParseFailure('1a2b', message: 'digit expected', position: 4));
        expect(
            parser,
            isParseSuccess(
                '1a2b3',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4d',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
      });
      test('repeat', () {
        final parser = digit().repeatSeparated(letter(), 2, 3);
        expect(parser, isParseFailure('', message: 'digit expected'));
        expect(parser, isParseFailure('a', message: 'digit expected'));
        expect(parser,
            isParseFailure('1', message: 'letter expected', position: 1));
        expect(parser,
            isParseFailure('1a', message: 'digit expected', position: 2));
        expect(
            parser,
            isParseSuccess('1a2',
                isSeparatedList(elements: ['1', '2'], separators: ['a'])));
        expect(
            parser,
            isParseSuccess('1a2b',
                isSeparatedList(elements: ['1', '2'], separators: ['a']),
                position: 3));
        expect(
            parser,
            isParseSuccess(
                '1a2b3',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b'])));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
        expect(
            parser,
            isParseSuccess(
                '1a2b3c4d',
                isSeparatedList(
                    elements: ['1', '2', '3'], separators: ['a', 'b']),
                position: 5));
      });
      group('separated list', () {
        final empty = SeparatedList<String, String>([], []);
        final single = SeparatedList<String, String>(['1'], []);
        final double = SeparatedList<String, String>(['1', '2'], ['+']);
        final triple =
            SeparatedList<String, String>(['1', '2', '3'], ['+', '-']);
        final quadruple = SeparatedList<String, String>(
            ['1', '2', '3', '4'], ['+', '-', '*']);
        final mixed = SeparatedList<int, String>([1, 2, 3], ['+', '-']);
        String combinator(String first, String separator, String second) =>
            '($first$separator$second)';
        test('elements', () {
          expect(empty.elements, []);
          expect(single.elements, ['1']);
          expect(double.elements, ['1', '2']);
          expect(triple.elements, ['1', '2', '3']);
          expect(quadruple.elements, ['1', '2', '3', '4']);
          expect(mixed.elements, [1, 2, 3]);
        });
        test('separators', () {
          expect(empty.separators, []);
          expect(single.separators, []);
          expect(double.separators, ['+']);
          expect(triple.separators, ['+', '-']);
          expect(quadruple.separators, ['+', '-', '*']);
          expect(mixed.separators, ['+', '-']);
        });
        test('sequence', () {
          expect(empty.sequential, []);
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
          expect(empty.toString(), 'SeparatedList()');
          expect(single.toString(), 'SeparatedList(1)');
          expect(double.toString(), 'SeparatedList(1, +, 2)');
          expect(triple.toString(), 'SeparatedList(1, +, 2, -, 3)');
          expect(quadruple.toString(), 'SeparatedList(1, +, 2, -, 3, *, 4)');
          expect(mixed.toString(), 'SeparatedList(1, +, 2, -, 3)');
        });
      });
    });
  });
}
