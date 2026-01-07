import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('cast', () {
    expectParserInvariants(any().cast<String>());
    test('default', () {
      final parser = digit().map(int.parse).cast<num>();
      expect(parser, isParseSuccess('1', result: 1));
      expect(parser, isParseFailure('a', message: 'digit expected'));
    });
  });
  group('castList', () {
    expectParserInvariants(any().star().castList<String>());
    test('default', () {
      final parser = digit().map(int.parse).repeat(3).castList<num>();
      expect(parser, isParseSuccess('123', result: <num>[1, 2, 3]));
      expect(
        parser,
        isParseFailure('abc', position: 0, message: 'digit expected'),
      );
    });
  });
  group('constant', () {
    final parser = digit().constant(42);
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('1', result: 42));
      expect(parser, isParseFailure('a', message: 'digit expected'));
    });
  });
  group('continuation', () {
    expectParserInvariants(
      any().callCC<String>((continuation, context) => continuation(context)),
    );
    test('delegation', () {
      final parser = digit().callCC<String>(
        (continuation, context) => continuation(context),
      );
      expect(parser, isParseSuccess('1', result: '1'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
    });
    test('diversion', () {
      final parser = digit().callCC<String>(
        (continuation, context) => letter().parseOn(context),
      );
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('1', message: 'letter expected'));
    });
    test('resume', () {
      final continuations = <ContinuationFunction<Object>>[];
      final contexts = <Context>[];
      final parser = digit().callCC((continuation, context) {
        continuations.add(continuation);
        contexts.add(context);
        // we have to return something for now
        return context.failure('Abort');
      });
      // execute the parser twice to collect the continuations
      expect(parser.parse('1') is Success, isFalse);
      expect(parser.parse('a') is Success, isFalse);
      // later we can execute the captured continuations
      expect(continuations[0](contexts[0]) is Success, isTrue);
      expect(continuations[1](contexts[1]) is Success, isFalse);
      // of course the continuations can be resumed multiple times
      expect(continuations[0](contexts[0]) is Success, isTrue);
      expect(continuations[1](contexts[1]) is Success, isFalse);
    });
    test('success', () {
      final parser = digit().callCC<String>(
        (continuation, context) => context.success('success'),
      );
      expect(parser, isParseSuccess('1', result: 'success', position: 0));
      expect(parser, isParseSuccess('a', result: 'success', position: 0));
    });
    test('failure', () {
      final parser = digit().callCC<String>(
        (continuation, context) => context.failure('failure'),
      );
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
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'digit expected'),
      );
      expect(
        parser,
        isParseFailure('1a', position: 1, message: 'digit expected'),
      );
      expect(parser, isParseSuccess('12', result: '12'));
      expect(parser, isParseSuccess('123', result: '123'));
      expect(parser, isParseSuccess('1234', result: '1234'));
    });
    test('with message', () {
      final parser = digit()
          .repeat(2, unbounded)
          .flatten(message: 'gimme a number');
      expect(parser, isParseFailure('', message: 'gimme a number'));
      expect(parser, isParseFailure('a', message: 'gimme a number'));
      expect(parser, isParseFailure('1', message: 'gimme a number'));
      expect(parser, isParseFailure('1a', message: 'gimme a number'));
      expect(parser, isParseSuccess('12', result: '12'));
      expect(parser, isParseSuccess('123', result: '123'));
      expect(parser, isParseSuccess('1234', result: '1234'));
    });
    test('nested', () {
      final parser = digit()
          .star()
          .flatten()
          .plusSeparated(char(','))
          .flatten();
      expect(parser, isParseSuccess('1', result: '1'));
      expect(parser, isParseSuccess('1,12', result: '1,12'));
      expect(parser, isParseSuccess('1,12,123', result: '1,12,123'));
    });
  });
  group('map', () {
    expectParserInvariants(any().map((a) => a));
    test('default', () {
      final parser = digit().map(
        (each) => each.codeUnitAt(0) - '0'.codeUnitAt(0),
      );
      expect(parser, isParseSuccess('1', result: 1));
      expect(parser, isParseSuccess('4', result: 4));
      expect(parser, isParseSuccess('9', result: 9));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
    });
    test('without side-effects', () {
      final effects = <String>[];
      final parser = digit().map(effects.add, hasSideEffects: false);
      expect(parser.fastParseOn('1', 0), 1);
      expect(effects, isEmpty);
    });
    test('with side-effects', () {
      final effects = <String>[];
      final parser = digit().map(effects.add, hasSideEffects: true);
      expect(parser.fastParseOn('1', 0), 1);
      expect(effects, ['1']);
    });
  });
  group('permute', () {
    expectParserInvariants(any().star().permute([-1, 1]));
    test('from start', () {
      final parser = digit().seq(letter()).permute([1, 0]);
      expect(parser, isParseSuccess('1a', result: ['a', '1']));
      expect(parser, isParseSuccess('2b', result: ['b', '2']));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'letter expected'),
      );
      expect(
        parser,
        isParseFailure('12', position: 1, message: 'letter expected'),
      );
    });
    test('from end', () {
      final parser = digit().seq(letter()).permute([-1, 0]);
      expect(parser, isParseSuccess('1a', result: ['a', '1']));
      expect(parser, isParseSuccess('2b', result: ['b', '2']));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'letter expected'),
      );
      expect(
        parser,
        isParseFailure('12', position: 1, message: 'letter expected'),
      );
    });
    test('repeated', () {
      final parser = digit().seq(letter()).permute([1, 1]);
      expect(parser, isParseSuccess('1a', result: ['a', 'a']));
      expect(parser, isParseSuccess('2b', result: ['b', 'b']));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'letter expected'),
      );
      expect(
        parser,
        isParseFailure('12', position: 1, message: 'letter expected'),
      );
    });
  });
  group('pick', () {
    expectParserInvariants(any().star().pick(-1));
    test('from start', () {
      final parser = digit().seq(letter()).pick(1);
      expect(parser, isParseSuccess('1a', result: 'a'));
      expect(parser, isParseSuccess('2b', result: 'b'));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'letter expected'),
      );
      expect(
        parser,
        isParseFailure('12', position: 1, message: 'letter expected'),
      );
    });
    test('from end', () {
      final parser = digit().seq(letter()).pick(-1);
      expect(parser, isParseSuccess('1a', result: 'a'));
      expect(parser, isParseSuccess('2b', result: 'b'));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('1', position: 1, message: 'letter expected'),
      );
      expect(
        parser,
        isParseFailure('12', position: 1, message: 'letter expected'),
      );
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
      expect(token.toString(), isNot(startsWith('Instance of')));
      expect(
        token.toString(),
        stringContainsInOrder(['Token', '[1:1]: [1, 2, 3]']),
      );
    });
    const buffer = '1\r12\r\n123\n1234';
    final parser = any().map((value) => value.codeUnitAt(0)).token().star();
    final result = parser.parse(buffer).value;
    test('value', () {
      final expected = [49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52];
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
        '4',
      ];
      expect(result.map((token) => token.input), expected);
    });
    group('join', () {
      test('normal', () {
        final joined = Token.join(result);
        expect(
          joined,
          isA<Token<List<int>>>()
              .having((token) => token.value, 'value', [
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
                52,
              ])
              .having((token) => token.buffer, 'buffer', buffer)
              .having((token) => token.start, 'start', 0)
              .having((token) => token.stop, 'stop', buffer.length),
        );
      });
      test('reverse order', () {
        final joined = Token.join(result.reversed);
        expect(
          joined,
          isA<Token<List<int>>>()
              .having((token) => token.value, 'value', [
                52,
                51,
                50,
                49,
                10,
                51,
                50,
                49,
                10,
                13,
                50,
                49,
                13,
                49,
              ])
              .having((token) => token.buffer, 'buffer', buffer)
              .having((token) => token.start, 'start', 0)
              .having((token) => token.stop, 'stop', buffer.length),
        );
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
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess(' a', result: 'a'));
      expect(parser, isParseSuccess('a ', result: 'a'));
      expect(parser, isParseSuccess(' a ', result: 'a'));
      expect(parser, isParseSuccess('  a', result: 'a'));
      expect(parser, isParseSuccess('a  ', result: 'a'));
      expect(parser, isParseSuccess('  a  ', result: 'a'));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(
        parser,
        isParseFailure(' b', position: 1, message: '"a" expected'),
      );
      expect(
        parser,
        isParseFailure('  b', position: 2, message: '"a" expected'),
      );
    });
    test('custom both', () {
      final parser = char('a').trim(char('*'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('*a', result: 'a'));
      expect(parser, isParseSuccess('a*', result: 'a'));
      expect(parser, isParseSuccess('*a*', result: 'a'));
      expect(parser, isParseSuccess('**a', result: 'a'));
      expect(parser, isParseSuccess('a**', result: 'a'));
      expect(parser, isParseSuccess('**a**', result: 'a'));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(
        parser,
        isParseFailure('*b', position: 1, message: '"a" expected'),
      );
      expect(
        parser,
        isParseFailure('**b', position: 2, message: '"a" expected'),
      );
    });
    test('custom left and right', () {
      final parser = char('a').trim(char('*'), char('#'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('*a', result: 'a'));
      expect(parser, isParseSuccess('a#', result: 'a'));
      expect(parser, isParseSuccess('*a#', result: 'a'));
      expect(parser, isParseSuccess('**a', result: 'a'));
      expect(parser, isParseSuccess('a##', result: 'a'));
      expect(parser, isParseSuccess('**a##', result: 'a'));
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(
        parser,
        isParseFailure('*b', position: 1, message: '"a" expected'),
      );
      expect(
        parser,
        isParseFailure('**b', position: 2, message: '"a" expected'),
      );
      expect(
        parser,
        isParseFailure('#a', position: 0, message: '"a" expected'),
      );
      expect(parser, isParseSuccess('a*', result: 'a', position: 1));
    });
  });
  group('where', () {
    expectParserInvariants(any().where((value) => true));
    test('default', () {
      final parser = any().where((value) => value == '*');
      expect(parser, isParseSuccess('*', result: '*'));
      expect(parser, isParseFailure('', message: 'input expected'));
      expect(parser, isParseFailure('!', message: 'unexpected "!"'));
    });
    test('with message', () {
      final parser = any().where(
        (value) => value == '*',
        message: 'star expected',
      );
      expect(parser, isParseSuccess('*', result: '*'));
      expect(parser, isParseFailure('', message: 'input expected'));
      expect(parser, isParseFailure('!', message: 'star expected'));
    });
    test('with factory', () {
      final parser = digit()
          .plus()
          .flatten()
          .map(int.parse)
          .where(
            (value) => value % 7 == 0,
            factory: (context, success) =>
                context.failure('${success.value} is not divisible by 7'),
          );
      expect(parser, isParseSuccess('7', result: 7));
      expect(parser, isParseSuccess('14', result: 14));
      expect(parser, isParseSuccess('861', result: 861));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(
        parser,
        isParseFailure('865', message: '865 is not divisible by 7'),
      );
    });
  });
}
