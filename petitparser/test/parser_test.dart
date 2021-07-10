import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart' hide anyOf;

import 'test_utils.dart';

void expectCommon(Parser parser) {
  test('copy', () {
    final copy = parser.copy();
    expect(copy, isNot(same(parser)));
    expect(copy.toString(), parser.toString());
    expect(copy.runtimeType, parser.runtimeType);
    expect(copy.children,
        pairwiseCompare(parser.children, identical, 'same children'));
  });
  test('transform', () {
    final copy = transformParser(parser, <T>(parser) => parser);
    expect(copy, isNot(same(parser)));
    expect(copy.toString(), parser.toString());
    expect(copy.runtimeType, parser.runtimeType);
    expect(
        copy.children,
        pairwiseCompare(parser.children, (parser, copy) {
          expect(copy, isNot(same(parser)));
          expect(copy.toString(), parser.toString());
          expect(copy.runtimeType, parser.runtimeType);
          return true;
        }, 'same children'));
  });
  test('isEqualTo', () {
    final copy = parser.copy();
    expect(copy.isEqualTo(copy), isTrue);
    expect(parser.isEqualTo(parser), isTrue);
    expect(copy.isEqualTo(parser), isTrue);
    expect(parser.isEqualTo(copy), isTrue);
  });
  test('replace', () {
    final copy = parser.copy();
    final replaced = <Parser>[];
    for (var i = 0; i < copy.children.length; i++) {
      final source = copy.children[i];
      final target = source.copy();
      expect(source, isNot(same(target)));
      copy.replace(source, target);
      expect(copy.children[i], same(target));
      replaced.add(target);
    }
    expect(copy.children,
        pairwiseCompare(replaced, identical, 'replaced children'));
  });
  test('toString', () {
    expect(parser.toString(),
        stringContainsInOrder([parser.runtimeType.toString()]));
  });
}

void main() {
  group('action', () {
    group('cast', () {
      expectCommon(any().cast());
      test('default', () {
        final parser = digit().map(num.parse);
        expectSuccess(parser, '1', 1);
        expectFailure(parser, 'a', 0, 'digit expected');
      });
    });
    group('castList', () {
      expectCommon(any().star().castList());
      test('default', () {
        final parser = digit().map(int.parse).repeat(3).castList<num>();
        expectSuccess(parser, '123', <num>[1, 2, 3]);
        expectFailure(parser, 'abc', 0, 'digit expected');
      });
    });
    group('callCC', () {
      expectCommon(
          any().callCC((continuation, context) => continuation(context)));
      test('delegation', () {
        final parser =
            digit().callCC((continuation, context) => continuation(context));
        expectSuccess(parser, '1', '1');
        expectFailure(parser, 'a', 0, 'digit expected');
      });
      test('diversion', () {
        final parser = digit()
            .callCC((continuation, context) => letter().parseOn(context));
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, '1', 0, 'letter expected');
      });
      test('resume', () {
        final continuations = <ContinuationFunction>[];
        final contexts = <Context>[];
        final parser = digit().callCC((continuation, context) {
          continuations.add(continuation);
          contexts.add(context);
          // we have to return something for now
          return context.failure('Abort');
        });
        // execute the parser twice to collect the continuations
        expect(parser.parse('1').isSuccess, isFalse);
        expect(parser.parse('a').isSuccess, isFalse);
        // later we can execute the captured continuations
        expect(continuations[0](contexts[0]).isSuccess, isTrue);
        expect(continuations[1](contexts[1]).isSuccess, isFalse);
        // of course the continuations can be resumed multiple times
        expect(continuations[0](contexts[0]).isSuccess, isTrue);
        expect(continuations[1](contexts[1]).isSuccess, isFalse);
      });
      test('success', () {
        final parser = digit()
            .callCC((continuation, context) => context.success('success'));
        expectSuccess(parser, '1', 'success', 0);
        expectSuccess(parser, 'a', 'success', 0);
      });
      test('failure', () {
        final parser = digit()
            .callCC((continuation, context) => context.failure('failure'));
        expectFailure(parser, '1', 0, 'failure');
        expectFailure(parser, 'a', 0, 'failure');
      });
    });
    group('flatten', () {
      expectCommon(any().flatten());
      test('default', () {
        final parser = digit().repeat(2, unbounded).flatten();
        expectFailure(parser, '', 0, 'digit expected');
        expectFailure(parser, 'a', 0, 'digit expected');
        expectFailure(parser, '1', 1, 'digit expected');
        expectFailure(parser, '1a', 1, 'digit expected');
        expectSuccess(parser, '12', '12');
        expectSuccess(parser, '123', '123');
        expectSuccess(parser, '1234', '1234');
      });
      test('with message', () {
        final parser = digit().repeat(2, unbounded).flatten('gimme a number');
        expectFailure(parser, '', 0, 'gimme a number');
        expectFailure(parser, 'a', 0, 'gimme a number');
        expectFailure(parser, '1', 0, 'gimme a number');
        expectFailure(parser, '1a', 0, 'gimme a number');
        expectSuccess(parser, '12', '12');
        expectSuccess(parser, '123', '123');
        expectSuccess(parser, '1234', '1234');
      });
    });
    group('filter', () {
      expectCommon(any().filter((value) => true, 'filter'));
      test('default', () {
        final parser =
            any().filter((value) => value == '*', 'asterisk expected');
        expectSuccess(parser, '*', '*');
        expectFailure(parser, '', 0, 'input expected');
        expectFailure(parser, '!', 0, 'asterisk expected');
      });
      test('complicated', () {
        final parser = digit()
            .plus()
            .flatten()
            .map(int.parse)
            .filter((value) => value % 7 == 0, 'integer not divisible by 7');
        expectSuccess(parser, '7', 7);
        expectSuccess(parser, '14', 14);
        expectSuccess(parser, '861', 861);
        expectFailure(parser, '', 0, 'digit expected');
        expectFailure(parser, '865', 0, 'integer not divisible by 7');
      });
    });
    group('map', () {
      expectCommon(any().map((a) => a));
      test('default', () {
        final parser =
            digit().map((each) => each.codeUnitAt(0) - '0'.codeUnitAt(0));
        expectSuccess(parser, '1', 1);
        expectSuccess(parser, '4', 4);
        expectSuccess(parser, '9', 9);
        expectFailure(parser, '');
        expectFailure(parser, 'a');
      });
      test('with side-effects', () {
        final parser = digit().map(
            (each) => each.codeUnitAt(0) - '0'.codeUnitAt(0),
            hasSideEffects: true);
        expectSuccess(parser, '1', 1);
        expectSuccess(parser, '4', 4);
        expectSuccess(parser, '9', 9);
        expectFailure(parser, '');
        expectFailure(parser, 'a');
      });
    });
    group('permute', () {
      expectCommon(any().star().permute([-1, 1]));
      test('from start', () {
        final parser = digit().seq(letter()).permute([1, 0]);
        expectSuccess(parser, '1a', ['a', '1']);
        expectSuccess(parser, '2b', ['b', '2']);
        expectFailure(parser, '');
        expectFailure(parser, '1', 1, 'letter expected');
        expectFailure(parser, '12', 1, 'letter expected');
      });
      test('from end', () {
        final parser = digit().seq(letter()).permute([-1, 0]);
        expectSuccess(parser, '1a', ['a', '1']);
        expectSuccess(parser, '2b', ['b', '2']);
        expectFailure(parser, '');
        expectFailure(parser, '1', 1, 'letter expected');
        expectFailure(parser, '12', 1, 'letter expected');
      });
      test('repeated', () {
        final parser = digit().seq(letter()).permute([1, 1]);
        expectSuccess(parser, '1a', ['a', 'a']);
        expectSuccess(parser, '2b', ['b', 'b']);
        expectFailure(parser, '');
        expectFailure(parser, '1', 1, 'letter expected');
        expectFailure(parser, '12', 1, 'letter expected');
      });
    });
    group('pick', () {
      expectCommon(any().star().pick(-1));
      test('from start', () {
        final parser = digit().seq(letter()).pick(1);
        expectSuccess(parser, '1a', 'a');
        expectSuccess(parser, '2b', 'b');
        expectFailure(parser, '');
        expectFailure(parser, '1', 1, 'letter expected');
        expectFailure(parser, '12', 1, 'letter expected');
      });
      test('from end', () {
        final parser = digit().seq(letter()).pick(-1);
        expectSuccess(parser, '1a', 'a');
        expectSuccess(parser, '2b', 'b');
        expectFailure(parser, '');
        expectFailure(parser, '1', 1, 'letter expected');
        expectFailure(parser, '12', 1, 'letter expected');
      });
    });
    group('token', () {
      expectCommon(any().token());
      test('default', () {
        final parser = digit().plus().token();
        expectFailure(parser, '');
        expectFailure(parser, 'a');
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
      expectCommon(any().trim(char('a'), char('b')));
      test('default', () {
        final parser = char('a').trim();
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, ' a', 'a');
        expectSuccess(parser, 'a ', 'a');
        expectSuccess(parser, ' a ', 'a');
        expectSuccess(parser, '  a', 'a');
        expectSuccess(parser, 'a  ', 'a');
        expectSuccess(parser, '  a  ', 'a');
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, ' b', 1, '"a" expected');
        expectFailure(parser, '  b', 2, '"a" expected');
      });
      test('custom both', () {
        final parser = char('a').trim(char('*'));
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, '*a', 'a');
        expectSuccess(parser, 'a*', 'a');
        expectSuccess(parser, '*a*', 'a');
        expectSuccess(parser, '**a', 'a');
        expectSuccess(parser, 'a**', 'a');
        expectSuccess(parser, '**a**', 'a');
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '*b', 1, '"a" expected');
        expectFailure(parser, '**b', 2, '"a" expected');
      });
      test('custom left and right', () {
        final parser = char('a').trim(char('*'), char('#'));
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, '*a', 'a');
        expectSuccess(parser, 'a#', 'a');
        expectSuccess(parser, '*a#', 'a');
        expectSuccess(parser, '**a', 'a');
        expectSuccess(parser, 'a##', 'a');
        expectSuccess(parser, '**a##', 'a');
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '*b', 1, '"a" expected');
        expectFailure(parser, '**b', 2, '"a" expected');
        expectFailure(parser, '#a', 0, '"a" expected');
        expectSuccess(parser, 'a*', 'a', 1);
      });
    });
  });
  group('character', () {
    group('anyOf', () {
      final parser = anyOf('uncopyrightable');
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'g', 'g');
        expectSuccess(parser, 'h', 'h');
        expectSuccess(parser, 'i', 'i');
        expectSuccess(parser, 'o', 'o');
        expectSuccess(parser, 'p', 'p');
        expectSuccess(parser, 'r', 'r');
        expectSuccess(parser, 't', 't');
        expectSuccess(parser, 'y', 'y');
        expectFailure(parser, 'x', 0, 'any of "uncopyrightable" expected');
      });
    });
    group('noneOf', () {
      final parser = noneOf('uncopyrightable');
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'x', 'x');
        expectFailure(parser, 'c', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'g', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'h', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'i', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'o', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'p', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'r', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 't', 0, 'none of "uncopyrightable" expected');
        expectFailure(parser, 'y', 0, 'none of "uncopyrightable" expected');
      });
    });
    group('char', () {
      expectCommon(char('a'));
      test('with string', () {
        final parser = char('a');
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '', 0, '"a" expected');
      });
      test('with number', () {
        final parser = char(97);
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '', 0, '"a" expected');
      });
      test('with message', () {
        final parser = char('a', 'lowercase a');
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'b', 0, 'lowercase a');
        expectFailure(parser, '', 0, 'lowercase a');
      });
      test('char invalid', () {
        expect(() => char('ab'), throwsArgumentError);
      });
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
          expectSuccess(parser, value, value);
          expectFailure(parser, 'a', 0, '"$key" expected');
        });
      });
    });
    group('digit', () {
      final parser = digit();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, '1', '1');
        expectSuccess(parser, '9', '9');
        expectFailure(parser, 'a', 0, 'digit expected');
        expectFailure(parser, '');
      });
    });
    group('letter', () {
      final parser = letter();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'X', 'X');
        expectFailure(parser, '0', 0, 'letter expected');
        expectFailure(parser, '');
      });
    });
    group('lowercase', () {
      final parser = lowercase();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'z', 'z');
        expectFailure(parser, 'A', 0, 'lowercase letter expected');
        expectFailure(parser, '0', 0, 'lowercase letter expected');
        expectFailure(parser, '');
      });
    });
    group('pattern', () {
      expectCommon(pattern('^ad-f'));
      test('with single', () {
        final parser = pattern('abc');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectFailure(parser, 'd', 0, '[abc] expected');
        expectFailure(parser, '');
      });
      test('with range', () {
        final parser = pattern('a-c');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectFailure(parser, 'd', 0, '[a-c] expected');
        expectFailure(parser, '');
      });
      test('with overlapping range', () {
        final parser = pattern('b-da-c');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectFailure(parser, 'e', 0, '[b-da-c] expected');
        expectFailure(parser, '', 0, '[b-da-c] expected');
      });
      test('with adjacent range', () {
        final parser = pattern('c-ea-c');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectSuccess(parser, 'e', 'e');
        expectFailure(parser, 'f', 0, '[c-ea-c] expected');
        expectFailure(parser, '', 0, '[c-ea-c] expected');
      });
      test('with prefix range', () {
        final parser = pattern('a-ea-c');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectSuccess(parser, 'e', 'e');
        expectFailure(parser, 'f', 0, '[a-ea-c] expected');
        expectFailure(parser, '', 0, '[a-ea-c] expected');
      });
      test('with postfix range', () {
        final parser = pattern('a-ec-e');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectSuccess(parser, 'e', 'e');
        expectFailure(parser, 'f', 0, '[a-ec-e] expected');
        expectFailure(parser, '', 0, '[a-ec-e] expected');
      });
      test('with repeated range', () {
        final parser = pattern('a-ea-e');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectSuccess(parser, 'e', 'e');
        expectFailure(parser, 'f', 0, '[a-ea-e] expected');
        expectFailure(parser, '', 0, '[a-ea-e] expected');
      });
      test('with composed range', () {
        final parser = pattern('ac-df-');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'c', 'c');
        expectSuccess(parser, 'd', 'd');
        expectSuccess(parser, 'f', 'f');
        expectSuccess(parser, '-', '-');
        expectFailure(parser, 'b', 0, '[ac-df-] expected');
        expectFailure(parser, 'e', 0, '[ac-df-] expected');
        expectFailure(parser, 'g', 0, '[ac-df-] expected');
        expectFailure(parser, '');
      });
      test('with negated single', () {
        final parser = pattern('^a');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, 'a', 0, '[^a] expected');
        expectFailure(parser, '');
      });
      test('with negated range', () {
        final parser = pattern('^a-c');
        expectSuccess(parser, 'd', 'd');
        expectFailure(parser, 'a', 0, '[^a-c] expected');
        expectFailure(parser, 'b', 0, '[^a-c] expected');
        expectFailure(parser, 'c', 0, '[^a-c] expected');
        expectFailure(parser, '');
      });
      test('with negate but without range', () {
        final parser = pattern('^a-');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, 'a', 0, '[^a-] expected');
        expectFailure(parser, '-', 0, '[^a-] expected');
        expectFailure(parser, '');
      });
      test('with error', () {
        expect(() => pattern('c-a'), throwsArgumentError);
      });
      group('ignore case', () {
        expectCommon(patternIgnoreCase('^ad-f'));
        test('with single', () {
          final parser = patternIgnoreCase('abc');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectFailure(parser, 'd', 0, '[abcABC] expected');
          expectFailure(parser, 'D', 0, '[abcABC] expected');
          expectFailure(parser, '');
        });
        test('with range', () {
          final parser = patternIgnoreCase('a-c');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectFailure(parser, 'd', 0, '[a-cA-C] expected');
          expectFailure(parser, 'D', 0, '[a-cA-C] expected');
          expectFailure(parser, '');
        });
        test('with overlapping range', () {
          final parser = patternIgnoreCase('b-da-c');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectFailure(parser, 'e', 0, '[b-da-cB-DA-C] expected');
          expectFailure(parser, 'E', 0, '[b-da-cB-DA-C] expected');
          expectFailure(parser, '', 0, '[b-da-cB-DA-C] expected');
        });
        test('with adjacent range', () {
          final parser = patternIgnoreCase('c-ea-c');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectSuccess(parser, 'e', 'e');
          expectSuccess(parser, 'E', 'E');
          expectFailure(parser, 'f', 0, '[c-ea-cC-EA-C] expected');
          expectFailure(parser, 'F', 0, '[c-ea-cC-EA-C] expected');
          expectFailure(parser, '', 0, '[c-ea-cC-EA-C] expected');
        });
        test('with prefix range', () {
          final parser = patternIgnoreCase('a-ea-c');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectSuccess(parser, 'e', 'e');
          expectSuccess(parser, 'E', 'E');
          expectFailure(parser, 'f', 0, '[a-ea-cA-EA-C] expected');
          expectFailure(parser, '', 0, '[a-ea-cA-EA-C] expected');
        });
        test('with postfix range', () {
          final parser = patternIgnoreCase('a-ec-e');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectSuccess(parser, 'e', 'e');
          expectSuccess(parser, 'E', 'E');
          expectFailure(parser, 'f', 0, '[a-ec-eA-EC-E] expected');
          expectFailure(parser, '', 0, '[a-ec-eA-EC-E] expected');
        });
        test('with repeated range', () {
          final parser = patternIgnoreCase('a-ea-e');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectSuccess(parser, 'e', 'e');
          expectSuccess(parser, 'E', 'E');
          expectFailure(parser, 'f', 0, '[a-ea-eA-EA-E] expected');
          expectFailure(parser, '', 0, '[a-ea-eA-EA-E] expected');
        });
        test('with composed range', () {
          final parser = patternIgnoreCase('ac-df-');
          expectSuccess(parser, 'a', 'a');
          expectSuccess(parser, 'A', 'A');
          expectSuccess(parser, 'c', 'c');
          expectSuccess(parser, 'C', 'C');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectSuccess(parser, 'f', 'f');
          expectSuccess(parser, 'F', 'F');
          expectSuccess(parser, '-', '-');
          expectFailure(parser, 'b', 0, '[ac-dfAC-DF-] expected');
          expectFailure(parser, 'e', 0, '[ac-dfAC-DF-] expected');
          expectFailure(parser, 'g', 0, '[ac-dfAC-DF-] expected');
          expectFailure(parser, '');
        });
        test('with negated single', () {
          final parser = patternIgnoreCase('^a');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectFailure(parser, 'a', 0, '[^aA] expected');
          expectFailure(parser, 'A', 0, '[^aA] expected');
          expectFailure(parser, '');
        });
        test('with negated range', () {
          final parser = patternIgnoreCase('^a-c');
          expectSuccess(parser, 'd', 'd');
          expectSuccess(parser, 'D', 'D');
          expectFailure(parser, 'a', 0, '[^a-cA-C] expected');
          expectFailure(parser, 'A', 0, '[^a-cA-C] expected');
          expectFailure(parser, 'b', 0, '[^a-cA-C] expected');
          expectFailure(parser, 'B', 0, '[^a-cA-C] expected');
          expectFailure(parser, 'c', 0, '[^a-cA-C] expected');
          expectFailure(parser, 'C', 0, '[^a-cA-C] expected');
          expectFailure(parser, '');
        });
        test('with negate but without range', () {
          final parser = patternIgnoreCase('^a-');
          expectSuccess(parser, 'b', 'b');
          expectSuccess(parser, 'B', 'B');
          expectFailure(parser, 'a', 0, '[^aA-] expected');
          expectFailure(parser, 'A', 0, '[^aA-] expected');
          expectFailure(parser, '-', 0, '[^aA-] expected');
          expectFailure(parser, '');
        });
        test('with error', () {
          expect(() => patternIgnoreCase('c-a'), throwsArgumentError);
        });
      });
      group('large ranges', () {
        final parser = pattern('\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff');
        expectCommon(parser);
        test('mathematical symbols', () {
          expectSuccess(parser, '∉', '∉');
          expectSuccess(parser, '⟃', '⟃');
          expectSuccess(parser, '⦻', '⦻');
          expectFailure(parser, 'a', 0,
              '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected');
          expectFailure(parser, '');
        });
      });
      group('without anything', () {
        final parser = pattern('');
        expectCommon(parser);
        test('test', () {
          for (var i = 0; i <= 0xffff; i++) {
            expectFailure(parser, String.fromCharCode(i), 0, '[] expected');
          }
        });
      });
      group('with everything', () {
        final parser = pattern('\x00-\uffff');
        expectCommon(parser);
        test('test', () {
          for (var i = 0; i <= 0xffff; i++) {
            final character = String.fromCharCode(i);
            expectSuccess(parser, character, character);
          }
        });
      });
    });
    group('range', () {
      final parser = range('e', 'o');
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'e', 'e');
        expectSuccess(parser, 'i', 'i');
        expectSuccess(parser, 'o', 'o');
        expectFailure(parser, 'p', 0, 'e..o expected');
        expectFailure(parser, 'd', 0, 'e..o expected');
        expectFailure(parser, '');
      });
      test('invalid', () {
        expect(() => range('o', 'e'), throwsArgumentError);
      });
    });
    group('uppercase', () {
      final parser = uppercase();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'A', 'A');
        expectSuccess(parser, 'Z', 'Z');
        expectFailure(parser, 'a', 0, 'uppercase letter expected');
        expectFailure(parser, '0', 0, 'uppercase letter expected');
        expectFailure(parser, '');
      });
    });
    group('whitespace', () {
      final parser = whitespace();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, ' ', ' ');
        expectSuccess(parser, '\t', '\t');
        expectSuccess(parser, '\r', '\r');
        expectSuccess(parser, '\f', '\f');
        expectFailure(parser, 'z', 0, 'whitespace expected');
        expectFailure(parser, '');
      });
      test('unicode', () {
        final string = String.fromCharCodes([
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
        ]);
        expectSuccess(parser.star().flatten(), string, string);
      });
    });
    group('word', () {
      final parser = word();
      expectCommon(parser);
      test('default', () {
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'z', 'z');
        expectSuccess(parser, 'A', 'A');
        expectSuccess(parser, 'Z', 'Z');
        expectSuccess(parser, '0', '0');
        expectSuccess(parser, '9', '9');
        expectSuccess(parser, '_', '_');
        expectFailure(parser, '-', 0, 'letter or digit expected');
        expectFailure(parser, '');
      });
    });
  });
  group('combinator', () {
    group('and', () {
      expectCommon(any().and());
      test('default', () {
        final parser = char('a').and();
        expectSuccess(parser, 'a', 'a', 0);
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '');
      });
    });
    group('choice', () {
      expectCommon(any().or(word()));
      test('operator', () {
        final parser = char('a') | char('b');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, 'c');
        expectFailure(parser, '');
      });
      test('converter', () {
        final parser = [char('a'), char('b')].toChoiceParser();
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, 'c');
        expectFailure(parser, '');
      });
      test('two', () {
        final parser = char('a').or(char('b'));
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, 'c');
        expectFailure(parser, '');
      });
      test('three', () {
        final parser = char('a').or(char('b')).or(char('c'));
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectSuccess(parser, 'c', 'c');
        expectFailure(parser, 'd');
        expectFailure(parser, '');
      });
      test('empty', () {
        expect(() => <Parser>[].toChoiceParser(), throwsArgumentError);
      });
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
          expectSuccess(parser, 'ab12', 'ab12');
          expectSuccess(parser, 'ac13', 'ac13');
          expectSuccess(parser, 'ad14', 'ad14');
          expectFailure(parser, '', 0, 'any of "ab" expected');
          expectFailure(parser, 'a', 1, 'any of "12" expected');
          expectFailure(parser, 'ab', 2, 'any of "12" expected');
          expectFailure(parser, 'ac', 1, 'any of "12" expected');
          expectFailure(parser, 'ad', 1, 'any of "12" expected');
        });
        test('select last', () {
          final parser = parsers.toChoiceParser(failureJoiner: selectLast);
          expect(selectLast(failureA0, failureB0), failureB0);
          expect(selectLast(failureB0, failureA0), failureA0);
          expectSuccess(parser, 'ab12', 'ab12');
          expectSuccess(parser, 'ac13', 'ac13');
          expectSuccess(parser, 'ad14', 'ad14');
          expectFailure(parser, '', 0, 'any of "ad" expected');
          expectFailure(parser, 'a', 1, 'any of "14" expected');
          expectFailure(parser, 'ab', 1, 'any of "14" expected');
          expectFailure(parser, 'ac', 1, 'any of "14" expected');
          expectFailure(parser, 'ad', 2, 'any of "14" expected');
        });
        test('farthest failure', () {
          final parser = parsers.toChoiceParser(failureJoiner: selectFarthest);
          expect(selectFarthest(failureA0, failureB0), failureB0);
          expect(selectFarthest(failureA0, failureB1), failureB1);
          expect(selectFarthest(failureB0, failureA0), failureA0);
          expect(selectFarthest(failureB1, failureA0), failureB1);
          expectSuccess(parser, 'ab12', 'ab12');
          expectSuccess(parser, 'ac13', 'ac13');
          expectSuccess(parser, 'ad14', 'ad14');
          expectFailure(parser, '', 0, 'any of "ad" expected');
          expectFailure(parser, 'a', 1, 'any of "14" expected');
          expectFailure(parser, 'ab', 2, 'any of "12" expected');
          expectFailure(parser, 'ac', 2, 'any of "13" expected');
          expectFailure(parser, 'ad', 2, 'any of "14" expected');
        });
        test('farthest failure and joined', () {
          final parser =
              parsers.toChoiceParser(failureJoiner: selectFarthestJoined);
          expect(selectFarthestJoined(failureA0, failureB1), failureB1);
          expect(selectFarthestJoined(failureB1, failureA0), failureB1);
          expect(
              selectFarthestJoined(failureA0, failureB0).message, 'A0 OR B0');
          expect(
              selectFarthestJoined(failureB0, failureA0).message, 'B0 OR A0');
          expect(
              selectFarthestJoined(failureA1, failureB1).message, 'A1 OR B1');
          expect(
              selectFarthestJoined(failureB1, failureA1).message, 'B1 OR A1');
          expectSuccess(parser, 'ab12', 'ab12');
          expectSuccess(parser, 'ac13', 'ac13');
          expectSuccess(parser, 'ad14', 'ad14');
          expectFailure(
              parser,
              '',
              0,
              'any of "ab" expected OR '
                  'any of "ac" expected OR any of "ad" expected');
          expectFailure(
              parser,
              'a',
              1,
              'any of "12" expected OR '
                  'any of "13" expected OR any of "14" expected');
          expectFailure(parser, 'ab', 2, 'any of "12" expected');
          expectFailure(parser, 'ac', 2, 'any of "13" expected');
          expectFailure(parser, 'ad', 2, 'any of "14" expected');
        });
      });
    });
    group('not', () {
      expectCommon(any().not());
      test('default', () {
        final parser = char('a').not('not "a" expected');
        expectFailure(parser, 'a', 0, 'not "a" expected');
        expectSuccess(
            parser,
            'b',
            isFailure.having(
                (failure) => failure.message, 'message', '"a" expected'),
            0);
        expectSuccess(
            parser,
            '',
            isFailure.having(
                (failure) => failure.message, 'message', '"a" expected'),
            0);
      });
      test('neg', () {
        final parser = digit().neg('no digit expected');
        expectFailure(parser, '1', 0, 'no digit expected');
        expectFailure(parser, '9', 0, 'no digit expected');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, ' ', ' ');
        expectFailure(parser, '', 0, 'input expected');
      });
    });
    group('optional', () {
      expectCommon(any().optional());
      test('without default', () {
        final parser = char('a').optional();
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', null, 0);
        expectSuccess(parser, '', null);
      });
      test('with default', () {
        final parser = char('a').optionalWith('0');
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', '0', 0);
        expectSuccess(parser, '', '0');
      });
    });
    group('sequence', () {
      expectCommon(any().seq(word()));
      test('operator', () {
        final parser = char('a') & char('b');
        expectSuccess(parser, 'ab', ['a', 'b']);
        expectFailure(parser, '');
        expectFailure(parser, 'x');
        expectFailure(parser, 'a', 1);
        expectFailure(parser, 'ax', 1);
      });
      test('converter', () {
        final parser = [char('a'), char('b')].toSequenceParser();
        expectSuccess(parser, 'ab', ['a', 'b']);
        expectFailure(parser, '');
        expectFailure(parser, 'x');
        expectFailure(parser, 'a', 1);
        expectFailure(parser, 'ax', 1);
      });
      test('two', () {
        final parser = char('a').seq(char('b'));
        expectSuccess(parser, 'ab', ['a', 'b']);
        expectFailure(parser, '');
        expectFailure(parser, 'x');
        expectFailure(parser, 'a', 1);
        expectFailure(parser, 'ax', 1);
      });
      test('three', () {
        final parser = char('a').seq(char('b')).seq(char('c'));
        expectSuccess(parser, 'abc', ['a', 'b', 'c']);
        expectFailure(parser, '');
        expectFailure(parser, 'x');
        expectFailure(parser, 'a', 1);
        expectFailure(parser, 'ax', 1);
        expectFailure(parser, 'ab', 2);
        expectFailure(parser, 'abx', 2);
      });
    });
    group('setable', () {
      expectCommon(any().settable());
      test('default', () {
        final parser = char('a').settable();
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'b', 0, '"a" expected');
        expectFailure(parser, '');
      });
      test('undefined', () {
        final parser = undefined();
        expectFailure(parser, '', 0, 'undefined parser');
        expectFailure(parser, 'a', 0, 'undefined parser');
        parser.set(char('a'));
        expectSuccess(parser, 'a', 'a');
      });
    });
  });
  group('misc', () {
    group('end', () {
      expectCommon(endOfInput());
      test('default', () {
        final parser = char('a').end();
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'aa', 1, 'end of input expected');
      });
    });
    group('epsilon', () {
      expectCommon(epsilon());
      test('default', () {
        final parser = epsilon();
        expectSuccess(parser, '', null);
        expectSuccess(parser, 'a', null, 0);
      });
    });
    group('failure', () {
      expectCommon(failure());
      test('default', () {
        final parser = failure('failure');
        expectFailure(parser, '', 0, 'failure');
        expectFailure(parser, 'a', 0, 'failure');
      });
    });
    group('position', () {
      expectCommon(position());
      test('default', () {
        final parser = (any().star() & position()).pick(-1);
        expectSuccess(parser, '', 0);
        expectSuccess(parser, 'a', 1);
        expectSuccess(parser, 'aa', 2);
        expectSuccess(parser, 'aaa', 3);
      });
    });
  });
  group('predicate', () {
    group('any', () {
      expectCommon(any());
      test('default', () {
        final parser = any();
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'b', 'b');
        expectFailure(parser, '', 0, 'input expected');
      });
    });
    group('string', () {
      expectCommon(string('foo'));
      test('default', () {
        final parser = string('foo');
        expectSuccess(parser, 'foo', 'foo');
        expectFailure(parser, '');
        expectFailure(parser, 'f');
        expectFailure(parser, 'fo');
        expectFailure(parser, 'Foo');
      });
      test('convert empty', () {
        final parser = ''.toParser();
        expectSuccess(parser, '', '');
      });
      test('convert single char', () {
        final parser = 'a'.toParser();
        expectSuccess(parser, 'a', 'a');
        expectFailure(parser, 'A');
      });
      test('convert single char (case-insensitive)', () {
        final parser = 'a'.toParser(caseInsensitive: true);
        expectSuccess(parser, 'a', 'a');
        expectSuccess(parser, 'A', 'A');
        expectFailure(parser, 'b');
      });
      test('convert multiple chars', () {
        final parser = 'foo'.toParser();
        expectSuccess(parser, 'foo', 'foo');
        expectFailure(parser, 'Foo');
      });
      test('convert multiple chars (case-insensitive)', () {
        final parser = 'foo'.toParser(caseInsensitive: true);
        expectSuccess(parser, 'foo', 'foo');
        expectSuccess(parser, 'Foo', 'Foo');
        expectFailure(parser, 'bar');
      });
    });
    group('stringIgnoreCase', () {
      expectCommon(stringIgnoreCase('foo'));
      test('default', () {
        final parser = stringIgnoreCase('foo');
        expectSuccess(parser, 'foo', 'foo');
        expectSuccess(parser, 'FOO', 'FOO');
        expectSuccess(parser, 'fOo', 'fOo');
        expectFailure(parser, '');
        expectFailure(parser, 'f');
        expectFailure(parser, 'Fo');
      });
    });
  });
  group('repeater', () {
    group('greedy', () {
      expectCommon(any().starGreedy(digit()));
      test('star', () {
        final parser = word().starGreedy(digit());
        expectFailure(parser, '', 0, 'digit expected');
        expectFailure(parser, 'a', 0, 'digit expected');
        expectFailure(parser, 'ab', 0, 'digit expected');
        expectSuccess(parser, '1', [], 0);
        expectSuccess(parser, 'a1', ['a'], 1);
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '12', ['1'], 1);
        expectSuccess(parser, 'a12', ['a', '1'], 2);
        expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
        expectSuccess(parser, '123', ['1', '2'], 2);
        expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
        expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1', '2'], 5);
      });
      test('plus', () {
        final parser = word().plusGreedy(digit());
        expectFailure(parser, '', 0, 'letter or digit expected');
        expectFailure(parser, 'a', 1, 'digit expected');
        expectFailure(parser, 'ab', 1, 'digit expected');
        expectFailure(parser, '1', 1, 'digit expected');
        expectSuccess(parser, 'a1', ['a'], 1);
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '12', ['1'], 1);
        expectSuccess(parser, 'a12', ['a', '1'], 2);
        expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
        expectSuccess(parser, '123', ['1', '2'], 2);
        expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
        expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1', '2'], 5);
      });
      test('repeat', () {
        final parser = word().repeatGreedy(digit(), 2, 4);
        expectFailure(parser, '', 0, 'letter or digit expected');
        expectFailure(parser, 'a', 1, 'letter or digit expected');
        expectFailure(parser, 'ab', 2, 'digit expected');
        expectFailure(parser, 'abc', 2, 'digit expected');
        expectFailure(parser, 'abcd', 2, 'digit expected');
        expectFailure(parser, 'abcde', 2, 'digit expected');
        expectFailure(parser, '1', 1, 'letter or digit expected');
        expectFailure(parser, 'a1', 2, 'digit expected');
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, 'abcd1', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde1', 2, 'digit expected');
        expectFailure(parser, '12', 2, 'digit expected');
        expectSuccess(parser, 'a12', ['a', '1'], 2);
        expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
        expectSuccess(parser, 'abcd12', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde12', 2, 'digit expected');
        expectSuccess(parser, '123', ['1', '2'], 2);
        expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
        expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1'], 4);
        expectSuccess(parser, 'abcd123', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde123', 2, 'digit expected');
      });
      test('repeat unbounded', () {
        final inputLetter = List.filled(100000, 'a');
        final inputDigit = List.filled(100000, '1');
        final parser = word().repeatGreedy(digit(), 2, unbounded);
        expectSuccess(
            parser, '${inputLetter.join()}1', inputLetter, inputLetter.length);
        expectSuccess(
            parser, '${inputDigit.join()}1', inputDigit, inputDigit.length);
      });
    });
    group('lazy', () {
      expectCommon(any().starLazy(digit()));
      test('star', () {
        final parser = word().starLazy(digit());
        expectFailure(parser, '');
        expectFailure(parser, 'a', 1, 'digit expected');
        expectFailure(parser, 'ab', 2, 'digit expected');
        expectSuccess(parser, '1', [], 0);
        expectSuccess(parser, 'a1', ['a'], 1);
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '12', [], 0);
        expectSuccess(parser, 'a12', ['a'], 1);
        expectSuccess(parser, 'ab12', ['a', 'b'], 2);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '123', [], 0);
        expectSuccess(parser, 'a123', ['a'], 1);
        expectSuccess(parser, 'ab123', ['a', 'b'], 2);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
      });
      test('plus', () {
        final parser = word().plusLazy(digit());
        expectFailure(parser, '');
        expectFailure(parser, 'a', 1, 'digit expected');
        expectFailure(parser, 'ab', 2, 'digit expected');
        expectFailure(parser, '1', 1, 'digit expected');
        expectSuccess(parser, 'a1', ['a'], 1);
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '12', ['1'], 1);
        expectSuccess(parser, 'a12', ['a'], 1);
        expectSuccess(parser, 'ab12', ['a', 'b'], 2);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
        expectSuccess(parser, '123', ['1'], 1);
        expectSuccess(parser, 'a123', ['a'], 1);
        expectSuccess(parser, 'ab123', ['a', 'b'], 2);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
      });
      test('repeat', () {
        final parser = word().repeatLazy(digit(), 2, 4);
        expectFailure(parser, '', 0, 'letter or digit expected');
        expectFailure(parser, 'a', 1, 'letter or digit expected');
        expectFailure(parser, 'ab', 2, 'digit expected');
        expectFailure(parser, 'abc', 3, 'digit expected');
        expectFailure(parser, 'abcd', 4, 'digit expected');
        expectFailure(parser, 'abcde', 4, 'digit expected');
        expectFailure(parser, '1', 1, 'letter or digit expected');
        expectFailure(parser, 'a1', 2, 'digit expected');
        expectSuccess(parser, 'ab1', ['a', 'b'], 2);
        expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
        expectSuccess(parser, 'abcd1', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde1', 4, 'digit expected');
        expectFailure(parser, '12', 2, 'digit expected');
        expectSuccess(parser, 'a12', ['a', '1'], 2);
        expectSuccess(parser, 'ab12', ['a', 'b'], 2);
        expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
        expectSuccess(parser, 'abcd12', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde12', 4, 'digit expected');
        expectSuccess(parser, '123', ['1', '2'], 2);
        expectSuccess(parser, 'a123', ['a', '1'], 2);
        expectSuccess(parser, 'ab123', ['a', 'b'], 2);
        expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
        expectSuccess(parser, 'abcd123', ['a', 'b', 'c', 'd'], 4);
        expectFailure(parser, 'abcde123', 4, 'digit expected');
      });
      test('repeat unbounded', () {
        final input = List.filled(100000, 'a');
        final parser = word().repeatLazy(digit(), 2, unbounded);
        expectSuccess(parser, '${input.join()}1111', input, input.length);
      });
    });
    group('possessive', () {
      expectCommon(any().star());
      test('star', () {
        final parser = char('a').star();
        expectSuccess(parser, '', []);
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'aa', ['a', 'a']);
        expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      });
      test('plus', () {
        final parser = char('a').plus();
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'aa', ['a', 'a']);
        expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      });
      test('repeat', () {
        final parser = char('a').repeat(2, 3);
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'a', 1, '"a" expected');
        expectSuccess(parser, 'aa', ['a', 'a']);
        expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
        expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
      });
      test('repeat exact', () {
        final parser = char('a').repeat(2);
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'a', 1, '"a" expected');
        expectSuccess(parser, 'aa', ['a', 'a']);
        expectSuccess(parser, 'aaa', ['a', 'a'], 2);
      });
      test('repeat unbounded', () {
        final input = List.filled(100000, 'a');
        final parser = char('a').repeat(2, unbounded);
        expectSuccess(parser, input.join(), input);
      });
      test('repeat erroneous', () {
        expect(() => char('a').repeat(-1, 1), throwsArgumentError);
        expect(() => char('a').repeat(2, 1), throwsArgumentError);
      });
      test('times', () {
        final parser = char('a').times(2);
        expectFailure(parser, '', 0, '"a" expected');
        expectFailure(parser, 'a', 1, '"a" expected');
        expectSuccess(parser, 'aa', ['a', 'a']);
        expectSuccess(parser, 'aaa', ['a', 'a'], 2);
      });
    });
    group('separated by', () {
      expectCommon(any().separatedBy(letter()));
      test('default', () {
        final parser = char('a').separatedBy(char('b'));
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'ab', ['a'], 1);
        expectSuccess(parser, 'aba', ['a', 'b', 'a']);
        expectSuccess(parser, 'abab', ['a', 'b', 'a'], 3);
        expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
        expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a'], 5);
      });
      test('without separators', () {
        final parser =
            char('a').separatedBy(char('b'), includeSeparators: false);
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'ab', ['a'], 1);
        expectSuccess(parser, 'aba', ['a', 'a']);
        expectSuccess(parser, 'abab', ['a', 'a'], 3);
        expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
        expectSuccess(parser, 'ababab', ['a', 'a', 'a'], 5);
      });
      test('with separator at end', () {
        final parser =
            char('a').separatedBy(char('b'), optionalSeparatorAtEnd: true);
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'ab', ['a', 'b']);
        expectSuccess(parser, 'aba', ['a', 'b', 'a']);
        expectSuccess(parser, 'abab', ['a', 'b', 'a', 'b']);
        expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
        expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a', 'b']);
      });
      test('without separators & separator at end', () {
        final parser = char('a').separatedBy(char('b'),
            includeSeparators: false, optionalSeparatorAtEnd: true);
        expectFailure(parser, '', 0, '"a" expected');
        expectSuccess(parser, 'a', ['a']);
        expectSuccess(parser, 'ab', ['a']);
        expectSuccess(parser, 'aba', ['a', 'a']);
        expectSuccess(parser, 'abab', ['a', 'a']);
        expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
        expectSuccess(parser, 'ababab', ['a', 'a', 'a']);
      });
    });
  });
}
