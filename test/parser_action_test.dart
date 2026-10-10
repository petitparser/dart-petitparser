import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import 'utils/assertions.dart';
import 'utils/checks.dart';

void main() {
  group('cast', () {
    expectParserInvariants(any().cast<String>());
    test('default', () {
      final parser = digit().map(int.parse).cast<num>();
      check(parser).parseSuccess('1', result: 1);
      check(parser).parseFailure('a', message: 'digit expected');
    });
  });
  group('castList', () {
    expectParserInvariants(any().star().castList<String>());
    test('default', () {
      final parser = digit().map(int.parse).repeat(3).castList<num>();
      check(parser).parseSuccess('123', result: <num>[1, 2, 3]);
      check(parser).parseFailure('abc', position: 0, message: 'digit expected');
    });
  });
  group('constant', () {
    final parser = digit().constant(42);
    expectParserInvariants(parser);
    test('default', () {
      check(parser).parseSuccess('1', result: 42);
      check(parser).parseFailure('a', message: 'digit expected');
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
      check(parser).parseSuccess('1', result: '1');
      check(parser).parseFailure('a', message: 'digit expected');
    });
    test('diversion', () {
      final parser = digit().callCC<String>(
        (continuation, context) => letter().parseOn(context),
      );
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseFailure('1', message: 'letter expected');
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
      check(parser.parse('1')).isFailure();
      check(parser.parse('a')).isFailure();
      // later we can execute the captured continuations
      check(continuations[0](contexts[0])).isSuccess();
      check(continuations[1](contexts[1])).isFailure();
      // of course the continuations can be resumed multiple times
      check(continuations[0](contexts[0])).isSuccess();
      check(continuations[1](contexts[1])).isFailure();
    });
    test('success', () {
      final parser = digit().callCC<String>(
        (continuation, context) => context.success('success'),
      );
      check(parser).parseSuccess('1', result: 'success', position: 0);
      check(parser).parseSuccess('a', result: 'success', position: 0);
    });
    test('failure', () {
      final parser = digit().callCC<String>(
        (continuation, context) => context.failure('failure'),
      );
      check(parser).parseFailure('1', message: 'failure');
      check(parser).parseFailure('a', message: 'failure');
    });
  });
  group('flatten', () {
    expectParserInvariants(any().flatten());
    test('default', () {
      final parser = digit().repeat(2, unbounded).flatten();
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'digit expected');
      check(parser).parseFailure('1a', position: 1, message: 'digit expected');
      check(parser).parseSuccess('12', result: '12');
      check(parser).parseSuccess('123', result: '123');
      check(parser).parseSuccess('1234', result: '1234');
    });
    test('with message', () {
      final parser = digit()
          .repeat(2, unbounded)
          .flatten(message: 'gimme a number');
      check(parser).parseFailure('', message: 'gimme a number');
      check(parser).parseFailure('a', message: 'gimme a number');
      check(parser).parseFailure('1', message: 'gimme a number');
      check(parser).parseFailure('1a', message: 'gimme a number');
      check(parser).parseSuccess('12', result: '12');
      check(parser).parseSuccess('123', result: '123');
      check(parser).parseSuccess('1234', result: '1234');
    });
    test('nested', () {
      final parser = digit()
          .star()
          .flatten()
          .plusSeparated(char(','))
          .flatten();
      check(parser).parseSuccess('1', result: '1');
      check(parser).parseSuccess('1,12', result: '1,12');
      check(parser).parseSuccess('1,12,123', result: '1,12,123');
    });
  });
  group('map', () {
    expectParserInvariants(any().map((a) => a));
    test('default', () {
      final parser = digit().map(
        (each) => each.codeUnitAt(0) - '0'.codeUnitAt(0),
      );
      check(parser).parseSuccess('1', result: 1);
      check(parser).parseSuccess('4', result: 4);
      check(parser).parseSuccess('9', result: 9);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
    });
    test('without side-effects', () {
      final effects = <String>[];
      final parser = digit().map(effects.add, hasSideEffects: false);
      check(parser.fastParseOn('1', 0)).equals(1);
      check(effects).isEmpty();
    });
    test('with side-effects', () {
      final effects = <String>[];
      final parser = digit().map(effects.add, hasSideEffects: true);
      check(parser.fastParseOn('1', 0)).equals(1);
      check(effects).deepEquals(['1']);
    });
  });
  group('permute', () {
    expectParserInvariants(any().star().permute([-1, 1]));
    test('from start', () {
      final parser = digit().seq(letter()).permute([1, 0]);
      check(parser).parseSuccess('1a', result: ['a', '1']);
      check(parser).parseSuccess('2b', result: ['b', '2']);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'letter expected');
      check(parser).parseFailure('12', position: 1, message: 'letter expected');
    });
    test('from end', () {
      final parser = digit().seq(letter()).permute([-1, 0]);
      check(parser).parseSuccess('1a', result: ['a', '1']);
      check(parser).parseSuccess('2b', result: ['b', '2']);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'letter expected');
      check(parser).parseFailure('12', position: 1, message: 'letter expected');
    });
    test('repeated', () {
      final parser = digit().seq(letter()).permute([1, 1]);
      check(parser).parseSuccess('1a', result: ['a', 'a']);
      check(parser).parseSuccess('2b', result: ['b', 'b']);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'letter expected');
      check(parser).parseFailure('12', position: 1, message: 'letter expected');
    });
  });
  group('pick', () {
    expectParserInvariants(any().star().pick(-1));
    test('from start', () {
      final parser = digit().seq(letter()).pick(1);
      check(parser).parseSuccess('1a', result: 'a');
      check(parser).parseSuccess('2b', result: 'b');
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'letter expected');
      check(parser).parseFailure('12', position: 1, message: 'letter expected');
    });
    test('from end', () {
      final parser = digit().seq(letter()).pick(-1);
      check(parser).parseSuccess('1a', result: 'a');
      check(parser).parseSuccess('2b', result: 'b');
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('1', position: 1, message: 'letter expected');
      check(parser).parseFailure('12', position: 1, message: 'letter expected');
    });
  });
  group('token', () {
    expectParserInvariants(any().token());
    test('default', () {
      final parser = digit().plus().token();
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('a', message: 'digit expected');
      final token = parser.parse('123').value;
      check(token.value).deepEquals(['1', '2', '3']);
      check(token.buffer).equals('123');
      check(token.start).equals(0);
      check(token.stop).equals(3);
      check(token.input).equals('123');
      check(token.length).equals(3);
      check(token.line).equals(1);
      check(token.column).equals(1);
      check(token.toString())
          .isCustomToString(rest: ['Token', '[1:1]: [1, 2, 3]']);
    });
    const buffer = '1\r12\r\n123\n1234';
    final parser = any().map((value) => value.codeUnitAt(0)).token().star();
    final result = parser.parse(buffer).value;
    test('value', () {
      final expected = [49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52];
      check(result.map((token) => token.value)).deepEquals(expected);
    });
    test('buffer', () {
      final expected = List.filled(buffer.length, buffer);
      check(result.map((token) => token.buffer)).deepEquals(expected);
    });
    test('start', () {
      final expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
      check(result.map((token) => token.start)).deepEquals(expected);
    });
    test('stop', () {
      final expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
      check(result.map((token) => token.stop)).deepEquals(expected);
    });
    test('length', () {
      final expected = List.filled(buffer.length, 1);
      check(result.map((token) => token.length)).deepEquals(expected);
    });
    test('line', () {
      final expected = [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4];
      check(result.map((token) => token.line)).deepEquals(expected);
    });
    test('column', () {
      final expected = [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4];
      check(result.map((token) => token.column)).deepEquals(expected);
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
      check(result.map((token) => token.input)).deepEquals(expected);
    });
    group('join', () {
      test('normal', () {
        final joined = Token.join(result);
        check(joined).isA<Token<List<int>>>()
          ..has(
            (token) => token.value,
            'value',
          ).deepEquals([49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52])
          ..has((token) => token.buffer, 'buffer').equals(buffer)
          ..has((token) => token.start, 'start').equals(0)
          ..has((token) => token.stop, 'stop').equals(buffer.length);
      });
      test('reverse order', () {
        final joined = Token.join(result.reversed);
        check(joined).isA<Token<List<int>>>()
          ..has(
            (token) => token.value,
            'value',
          ).deepEquals([52, 51, 50, 49, 10, 51, 50, 49, 10, 13, 50, 49, 13, 49])
          ..has((token) => token.buffer, 'buffer').equals(buffer)
          ..has((token) => token.start, 'start').equals(0)
          ..has((token) => token.stop, 'stop').equals(buffer.length);
      });
      test('empty', () {
        check(() => Token.join([])).throws<ArgumentError>();
      });
      test('different buffer', () {
        const token = [Token(12, '12', 0, 2), Token(32, '32', 0, 2)];
        check(() => Token.join(token)).throws<ArgumentError>();
      });
    });
    test('unique', () {
      check({...result}.length).equals(result.length);
    });
    test('equals', () {
      for (var i = 0; i < result.length; i++) {
        for (var j = 0; j < result.length; j++) {
          check(result[i] == result[j]).equals(i == j);
          check(result[i].hashCode == result[j].hashCode).equals(i == j);
        }
      }
    });
  });
  group('trim', () {
    expectParserInvariants(any().trim(char('a'), char('b')));
    test('default', () {
      final parser = char('a').trim();
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess(' a', result: 'a');
      check(parser).parseSuccess('a ', result: 'a');
      check(parser).parseSuccess(' a ', result: 'a');
      check(parser).parseSuccess('  a', result: 'a');
      check(parser).parseSuccess('a  ', result: 'a');
      check(parser).parseSuccess('  a  ', result: 'a');
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('b', message: '"a" expected');
      check(parser).parseFailure(' b', position: 1, message: '"a" expected');
      check(parser).parseFailure('  b', position: 2, message: '"a" expected');
    });
    test('custom both', () {
      final parser = char('a').trim(char('*'));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('*a', result: 'a');
      check(parser).parseSuccess('a*', result: 'a');
      check(parser).parseSuccess('*a*', result: 'a');
      check(parser).parseSuccess('**a', result: 'a');
      check(parser).parseSuccess('a**', result: 'a');
      check(parser).parseSuccess('**a**', result: 'a');
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('b', message: '"a" expected');
      check(parser).parseFailure('*b', position: 1, message: '"a" expected');
      check(parser).parseFailure('**b', position: 2, message: '"a" expected');
    });
    test('custom left and right', () {
      final parser = char('a').trim(char('*'), char('#'));
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('*a', result: 'a');
      check(parser).parseSuccess('a#', result: 'a');
      check(parser).parseSuccess('*a#', result: 'a');
      check(parser).parseSuccess('**a', result: 'a');
      check(parser).parseSuccess('a##', result: 'a');
      check(parser).parseSuccess('**a##', result: 'a');
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseFailure('b', message: '"a" expected');
      check(parser).parseFailure('*b', position: 1, message: '"a" expected');
      check(parser).parseFailure('**b', position: 2, message: '"a" expected');
      check(parser).parseFailure('#a', position: 0, message: '"a" expected');
      check(parser).parseSuccess('a*', result: 'a', position: 1);
    });
  });
  group('where', () {
    expectParserInvariants(any().where((value) => true));
    test('default', () {
      final parser = any().where((value) => value == '*');
      check(parser).parseSuccess('*', result: '*');
      check(parser).parseFailure('', message: 'input expected');
      check(parser).parseFailure('!', message: 'unexpected "!"');
    });
    test('with message', () {
      final parser = any().where(
        (value) => value == '*',
        message: 'star expected',
      );
      check(parser).parseSuccess('*', result: '*');
      check(parser).parseFailure('', message: 'input expected');
      check(parser).parseFailure('!', message: 'star expected');
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
      check(parser).parseSuccess('7', result: 7);
      check(parser).parseSuccess('14', result: 14);
      check(parser).parseSuccess('861', result: 861);
      check(parser).parseFailure('', message: 'digit expected');
      check(parser).parseFailure('865', message: '865 is not divisible by 7');
    });
  });
}
