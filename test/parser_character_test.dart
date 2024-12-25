import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('anyOf', () {
    final parser = anyOf('uncopyrightable');
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('g', result: 'g'));
      expect(parser, isParseSuccess('h', result: 'h'));
      expect(parser, isParseSuccess('i', result: 'i'));
      expect(parser, isParseSuccess('o', result: 'o'));
      expect(parser, isParseSuccess('p', result: 'p'));
      expect(parser, isParseSuccess('r', result: 'r'));
      expect(parser, isParseSuccess('t', result: 't'));
      expect(parser, isParseSuccess('y', result: 'y'));
      expect(parser,
          isParseFailure('x', message: 'any of "uncopyrightable" expected'));
    });
  });
  group('noneOf', () {
    final parser = noneOf('uncopyrightable');
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('x', result: 'x'));
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
    test('default', () {
      final parser = char('a');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseFailure('b', message: '"a" expected'));
      expect(parser, isParseFailure('', message: '"a" expected'));
    });
    test('with message', () {
      final parser = char('a', message: 'lowercase a');
      expect(parser, isParseSuccess('a', result: 'a'));
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
        expect(parser, isParseSuccess(value, result: value));
        expect(parser, isParseFailure('a', message: '"$key" expected'));
      });
    });
  });
  group('charIgnoringCase', () {
    expectParserInvariants(char('a', ignoreCase: true));
    test('with lowercase string', () {
      final parser = char('a', ignoreCase: true);
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser,
          isParseFailure('b', message: '"a" (case-insensitive) expected'));
      expect(parser,
          isParseFailure('', message: '"a" (case-insensitive) expected'));
    });
    test('with uppercase string', () {
      final parser = char('A', ignoreCase: true);
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser,
          isParseFailure('b', message: '"A" (case-insensitive) expected'));
      expect(parser,
          isParseFailure('', message: '"A" (case-insensitive) expected'));
    });
    test('with custom message', () {
      final parser = char('a', message: 'upper or lower', ignoreCase: true);
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser, isParseFailure('b', message: 'upper or lower'));
      expect(parser, isParseFailure('', message: 'upper or lower'));
    });
    test('with single char', () {
      final parser = char('1', ignoreCase: true);
      expect(parser, isParseSuccess('1', result: '1'));
      expect(parser,
          isParseFailure('a', message: '"1" (case-insensitive) expected'));
      expect(parser,
          isParseFailure('', message: '"1" (case-insensitive) expected'));
    });
    test('char invalid', () {
      expect(() => char('ab', ignoreCase: true), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
  });
  group('digit', () {
    final parser = digit();
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('1', result: '1'));
      expect(parser, isParseSuccess('9', result: '9'));
      expect(parser, isParseFailure('', message: 'digit expected'));
      expect(parser, isParseFailure('a', message: 'digit expected'));
    });
  });
  group('letter', () {
    final parser = letter();
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('X', result: 'X'));
      expect(parser, isParseFailure('', message: 'letter expected'));
      expect(parser, isParseFailure('0', message: 'letter expected'));
    });
  });
  group('lowercase', () {
    final parser = lowercase();
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('z', result: 'z'));
      expect(parser, isParseFailure('', message: 'lowercase letter expected'));
      expect(parser, isParseFailure('A', message: 'lowercase letter expected'));
      expect(parser, isParseFailure('0', message: 'lowercase letter expected'));
    });
  });
  group('pattern', () {
    expectParserInvariants(pattern('^ad-f'));
    test('with single', () {
      final parser = pattern('abc');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseFailure('d', message: '[abc] expected'));
      expect(parser, isParseFailure('', message: '[abc] expected'));
    });
    test('with range', () {
      final parser = pattern('a-c');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseFailure('d', message: '[a-c] expected'));
      expect(parser, isParseFailure('', message: '[a-c] expected'));
    });
    test('with overlapping range', () {
      final parser = pattern('b-da-c');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseFailure('e', message: '[b-da-c] expected'));
      expect(parser, isParseFailure('', message: '[b-da-c] expected'));
    });
    test('with adjacent range', () {
      final parser = pattern('c-ea-c');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseSuccess('e', result: 'e'));
      expect(parser, isParseFailure('f', message: '[c-ea-c] expected'));
      expect(parser, isParseFailure('', message: '[c-ea-c] expected'));
    });
    test('with prefix range', () {
      final parser = pattern('a-ea-c');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseSuccess('e', result: 'e'));
      expect(parser, isParseFailure('f', message: '[a-ea-c] expected'));
      expect(parser, isParseFailure('', message: '[a-ea-c] expected'));
    });
    test('with postfix range', () {
      final parser = pattern('a-ec-e');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseSuccess('e', result: 'e'));
      expect(parser, isParseFailure('f', message: '[a-ec-e] expected'));
      expect(parser, isParseFailure('', message: '[a-ec-e] expected'));
    });
    test('with repeated range', () {
      final parser = pattern('a-ea-e');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseSuccess('e', result: 'e'));
      expect(parser, isParseFailure('f', message: '[a-ea-e] expected'));
      expect(parser, isParseFailure('', message: '[a-ea-e] expected'));
    });
    test('with composed range', () {
      final parser = pattern('ac-df-');
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('c', result: 'c'));
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseSuccess('f', result: 'f'));
      expect(parser, isParseSuccess('-', result: '-'));
      expect(parser, isParseFailure('b', message: '[ac-df-] expected'));
      expect(parser, isParseFailure('e', message: '[ac-df-] expected'));
      expect(parser, isParseFailure('g', message: '[ac-df-] expected'));
      expect(parser, isParseFailure('', message: '[ac-df-] expected'));
    });
    test('with negated single', () {
      final parser = pattern('^a');
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('a', message: '[^a] expected'));
      expect(parser, isParseFailure('', message: '[^a] expected'));
    });
    test('with negated range', () {
      final parser = pattern('^a-c');
      expect(parser, isParseSuccess('d', result: 'd'));
      expect(parser, isParseFailure('a', message: '[^a-c] expected'));
      expect(parser, isParseFailure('b', message: '[^a-c] expected'));
      expect(parser, isParseFailure('c', message: '[^a-c] expected'));
      expect(parser, isParseFailure('', message: '[^a-c] expected'));
    });
    test('with negate but without range', () {
      final parser = pattern('^a-');
      expect(parser, isParseSuccess('b', result: 'b'));
      expect(parser, isParseFailure('a', message: '[^a-] expected'));
      expect(parser, isParseFailure('-', message: '[^a-] expected'));
      expect(parser, isParseFailure('', message: '[^a-] expected'));
    });
    test('with everything', () {
      final parser = pattern('\u0000-\uffff');
      for (var i = 0; i <= 0xffff; i++) {
        final input = String.fromCharCode(i);
        expect(parser, isParseSuccess(input, result: input));
      }
    });
    test('with nothing', () {
      final parser = pattern('^\u0000-\uffff');
      for (var i = 0; i <= 0xffff; i++) {
        final input = String.fromCharCode(i);
        expect(
            parser, isParseFailure(input, message: '[^\\x00-\uffff] expected'));
      }
    });
    test('with nothing (empty pattern)', () {
      final parser = pattern('');
      for (var i = 0; i <= 0xffff; i++) {
        final input = String.fromCharCode(i);
        expect(parser, isParseFailure(input, message: '[] expected'));
      }
    });
    test('with error', () {
      expect(() => pattern('c-a'), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
    group('ignore case', () {
      expectParserInvariants(pattern('^ad-f', ignoreCase: true));
      test('with single', () {
        final parser = pattern('abc', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser,
            isParseFailure('d', message: '[abc] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('D', message: '[abc] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '[abc] (case-insensitive) expected'));
      });
      test('with range', () {
        final parser = pattern('a-c', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser,
            isParseFailure('d', message: '[a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('D', message: '[a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '[a-c] (case-insensitive) expected'));
      });
      test('with overlapping range', () {
        final parser = pattern('b-da-c', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
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
        final parser = pattern('c-ea-c', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser, isParseSuccess('e', result: 'e'));
        expect(parser, isParseSuccess('E', result: 'E'));
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
        final parser = pattern('a-ea-c', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser, isParseSuccess('e', result: 'e'));
        expect(parser, isParseSuccess('E', result: 'E'));
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
        final parser = pattern('a-ec-e', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser, isParseSuccess('e', result: 'e'));
        expect(parser, isParseSuccess('E', result: 'E'));
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
        final parser = pattern('a-ea-e', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser, isParseSuccess('e', result: 'e'));
        expect(parser, isParseSuccess('E', result: 'E'));
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
        final parser = pattern('ac-df-', ignoreCase: true);
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('A', result: 'A'));
        expect(parser, isParseSuccess('c', result: 'c'));
        expect(parser, isParseSuccess('C', result: 'C'));
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser, isParseSuccess('f', result: 'f'));
        expect(parser, isParseSuccess('F', result: 'F'));
        expect(parser, isParseSuccess('-', result: '-'));
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
        final parser = pattern('^a', ignoreCase: true);
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser,
            isParseFailure('a', message: '[^a] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('A', message: '[^a] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '[^a] (case-insensitive) expected'));
      });
      test('with negated range', () {
        final parser = pattern('^a-c', ignoreCase: true);
        expect(parser, isParseSuccess('d', result: 'd'));
        expect(parser, isParseSuccess('D', result: 'D'));
        expect(parser,
            isParseFailure('a', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('A', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('b', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('B', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('c', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('C', message: '[^a-c] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '[^a-c] (case-insensitive) expected'));
      });
      test('with negate but without range', () {
        final parser = pattern('^a-', ignoreCase: true);
        expect(parser, isParseSuccess('b', result: 'b'));
        expect(parser, isParseSuccess('B', result: 'B'));
        expect(parser,
            isParseFailure('a', message: '[^a-] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('A', message: '[^a-] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('-', message: '[^a-] (case-insensitive) expected'));
        expect(parser,
            isParseFailure('', message: '[^a-] (case-insensitive) expected'));
      });
      test('with error', () {
        expect(
            () => pattern('c-a', ignoreCase: true), throwsA(isAssertionError));
      }, skip: !hasAssertionsEnabled());
    });
    group('large ranges', () {
      final parser = pattern('\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff');
      expectParserInvariants(parser);
      test('mathematical symbols', () {
        expect(parser, isParseSuccess('∉', result: '∉'));
        expect(parser, isParseSuccess('⟃', result: '⟃'));
        expect(parser, isParseSuccess('⦻', result: '⦻'));
        expect(
            parser,
            isParseFailure('a',
                message: '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected'));
        expect(
            parser,
            isParseFailure('',
                message: '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected'));
      });
    });
  });
  group('range', () {
    final parser = range('e', 'o');
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('e', result: 'e'));
      expect(parser, isParseSuccess('i', result: 'i'));
      expect(parser, isParseSuccess('o', result: 'o'));
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
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser, isParseSuccess('Z', result: 'Z'));
      expect(parser, isParseFailure('a', message: 'uppercase letter expected'));
      expect(parser, isParseFailure('0', message: 'uppercase letter expected'));
      expect(parser, isParseFailure('', message: 'uppercase letter expected'));
    });
  });
  group('whitespace', () {
    final parser = whitespace();
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess(' ', result: ' '));
      expect(parser, isParseSuccess('\t', result: '\t'));
      expect(parser, isParseSuccess('\r', result: '\r'));
      expect(parser, isParseSuccess('\f', result: '\f'));
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
        final character = String.fromCharCode(i);
        expect(
            parser,
            whitespace.contains(i)
                ? isParseSuccess(character, result: character)
                : isParseFailure(character));
      }
    });
  });
  group('word', () {
    final parser = word();
    expectParserInvariants(parser);
    test('default', () {
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('z', result: 'z'));
      expect(parser, isParseSuccess('A', result: 'A'));
      expect(parser, isParseSuccess('Z', result: 'Z'));
      expect(parser, isParseSuccess('0', result: '0'));
      expect(parser, isParseSuccess('9', result: '9'));
      expect(parser, isParseSuccess('_', result: '_'));
      expect(parser, isParseFailure('-', message: 'letter or digit expected'));
      expect(parser, isParseFailure(''));
    });
  });
  group('unicode', () {
    group('char', () {
      group('narrow', () {
        expectParserInvariants(char('a', unicode: true));
        test('default', () {
          final parser = char('a', unicode: true);
          expect(parser, isParseSuccess('a', result: 'a'));
          expect(parser, isParseFailure('b', message: '"a" expected'));
          expect(parser, isParseFailure('😀', message: '"a" expected'));
          expect(parser, isParseFailure('', message: '"a" expected'));
        });
        test('with message', () {
          final parser = char('a', message: 'lowercase a', unicode: true);
          expect(parser, isParseSuccess('a', result: 'a'));
          expect(parser, isParseFailure('b', message: 'lowercase a'));
          expect(parser, isParseFailure('😀', message: 'lowercase a'));
          expect(parser, isParseFailure('', message: 'lowercase a'));
        });
      });
      group('wide', () {
        expectParserInvariants(char('😀', unicode: true));
        test('default', () {
          final parser = char('😀', unicode: true);
          expect(parser, isParseSuccess('😀', result: '😀'));
          expect(parser, isParseFailure('a', message: '"😀" expected'));
          expect(parser, isParseFailure('👻', message: '"😀" expected'));
          expect(parser, isParseFailure('', message: '"😀" expected'));
        });
        test('with message', () {
          final parser = char('😀', message: 'smile', unicode: true);
          expect(parser, isParseSuccess('😀', result: '😀'));
          expect(parser, isParseFailure('a', message: 'smile'));
          expect(parser, isParseFailure('👻', message: 'smile'));
          expect(parser, isParseFailure('', message: 'smile'));
        });
      });
    });
    group('range', () {
      group('narrow', () {
        expectParserInvariants(range('e', 'o', unicode: true));
        test('default', () {
          final parser = range('e', 'o', unicode: true);
          expect(parser, isParseSuccess('e', result: 'e'));
          expect(parser, isParseSuccess('i', result: 'i'));
          expect(parser, isParseSuccess('o', result: 'o'));
          expect(parser, isParseFailure('p', message: '[e-o] expected'));
          expect(parser, isParseFailure('d', message: '[e-o] expected'));
          expect(parser, isParseFailure('😺', message: '[e-o] expected'));
          expect(parser, isParseFailure('', message: '[e-o] expected'));
        });
        test('with message', () {
          final parser =
              range('e', 'o', message: 'range expected', unicode: true);
          expect(parser, isParseSuccess('e', result: 'e'));
          expect(parser, isParseSuccess('i', result: 'i'));
          expect(parser, isParseSuccess('o', result: 'o'));
          expect(parser, isParseFailure('p', message: 'range expected'));
          expect(parser, isParseFailure('d', message: 'range expected'));
          expect(parser, isParseFailure('😺', message: 'range expected'));
          expect(parser, isParseFailure('', message: 'range expected'));
        });
        test('invalid', () {
          expect(
              () => range('o', 'e', unicode: true), throwsA(isAssertionError));
        }, skip: !hasAssertionsEnabled());
      });
      group('wide', () {
        expectParserInvariants(range('😺', '😾', unicode: true));
        test('default', () {
          final parser = range('😺', '😾', unicode: true);
          expect(parser, isParseSuccess('😺', result: '😺'));
          expect(parser, isParseSuccess('😻', result: '😻'));
          expect(parser, isParseSuccess('😾', result: '😾'));
          expect(parser, isParseFailure('p', message: '[😺-😾] expected'));
          expect(parser, isParseFailure('d', message: '[😺-😾] expected'));
          expect(parser, isParseFailure('', message: '[😺-😾] expected'));
        });
        test('with message', () {
          final parser =
              range('😺', '😾', message: 'cat expected', unicode: true);
          expect(parser, isParseSuccess('😺', result: '😺'));
          expect(parser, isParseSuccess('😻', result: '😻'));
          expect(parser, isParseSuccess('😾', result: '😾'));
          expect(parser, isParseFailure('p', message: 'cat expected'));
          expect(parser, isParseFailure('d', message: 'cat expected'));
          expect(parser, isParseFailure('', message: 'cat expected'));
        });
        test('invalid', () {
          expect(() => range('😾', '😺', unicode: true),
              throwsA(isAssertionError));
        }, skip: !hasAssertionsEnabled());
      });
    });
  });
}
