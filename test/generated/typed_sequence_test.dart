// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import '../utils/assertions.dart';
import '../utils/matchers.dart';

void main() {
  group('seqMap2', () {
    final parser = seq2(char('a'), char('b'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser = parser.map2((a, b) => '$a$b');
      expect(mappedParser, isParseSuccess('ab', 'ab'));
      expect(mappedParser, isParseSuccess('ab*', 'ab', position: 2));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
  });
  group('seqMap3', () {
    final parser = seq3(char('a'), char('b'), char('c'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser = parser.map3((a, b, c) => '$a$b$c');
      expect(mappedParser, isParseSuccess('abc', 'abc'));
      expect(mappedParser, isParseSuccess('abc*', 'abc', position: 3));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
  });
  group('seqMap4', () {
    final parser = seq4(char('a'), char('b'), char('c'), char('d'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser = parser.map4((a, b, c, d) => '$a$b$c$d');
      expect(mappedParser, isParseSuccess('abcd', 'abcd'));
      expect(mappedParser, isParseSuccess('abcd*', 'abcd', position: 4));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
  });
  group('seqMap5', () {
    final parser = seq5(char('a'), char('b'), char('c'), char('d'), char('e'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser = parser.map5((a, b, c, d, e) => '$a$b$c$d$e');
      expect(mappedParser, isParseSuccess('abcde', 'abcde'));
      expect(mappedParser, isParseSuccess('abcde*', 'abcde', position: 5));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
    test('failure at 4', () {
      expect(
          parser, isParseFailure('abcd', message: '"e" expected', position: 4));
      expect(parser,
          isParseFailure('abcd*', message: '"e" expected', position: 4));
    });
  });
  group('seqMap6', () {
    final parser =
        seq6(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser = parser.map6((a, b, c, d, e, f) => '$a$b$c$d$e$f');
      expect(mappedParser, isParseSuccess('abcdef', 'abcdef'));
      expect(mappedParser, isParseSuccess('abcdef*', 'abcdef', position: 6));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
    test('failure at 4', () {
      expect(
          parser, isParseFailure('abcd', message: '"e" expected', position: 4));
      expect(parser,
          isParseFailure('abcd*', message: '"e" expected', position: 4));
    });
    test('failure at 5', () {
      expect(parser,
          isParseFailure('abcde', message: '"f" expected', position: 5));
      expect(parser,
          isParseFailure('abcde*', message: '"f" expected', position: 5));
    });
  });
  group('seqMap7', () {
    final parser = seq7(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser =
          parser.map7((a, b, c, d, e, f, g) => '$a$b$c$d$e$f$g');
      expect(mappedParser, isParseSuccess('abcdefg', 'abcdefg'));
      expect(mappedParser, isParseSuccess('abcdefg*', 'abcdefg', position: 7));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
    test('failure at 4', () {
      expect(
          parser, isParseFailure('abcd', message: '"e" expected', position: 4));
      expect(parser,
          isParseFailure('abcd*', message: '"e" expected', position: 4));
    });
    test('failure at 5', () {
      expect(parser,
          isParseFailure('abcde', message: '"f" expected', position: 5));
      expect(parser,
          isParseFailure('abcde*', message: '"f" expected', position: 5));
    });
    test('failure at 6', () {
      expect(parser,
          isParseFailure('abcdef', message: '"g" expected', position: 6));
      expect(parser,
          isParseFailure('abcdef*', message: '"g" expected', position: 6));
    });
  });
  group('seqMap8', () {
    final parser = seq8(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser =
          parser.map8((a, b, c, d, e, f, g, h) => '$a$b$c$d$e$f$g$h');
      expect(mappedParser, isParseSuccess('abcdefgh', 'abcdefgh'));
      expect(
          mappedParser, isParseSuccess('abcdefgh*', 'abcdefgh', position: 8));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
    test('failure at 4', () {
      expect(
          parser, isParseFailure('abcd', message: '"e" expected', position: 4));
      expect(parser,
          isParseFailure('abcd*', message: '"e" expected', position: 4));
    });
    test('failure at 5', () {
      expect(parser,
          isParseFailure('abcde', message: '"f" expected', position: 5));
      expect(parser,
          isParseFailure('abcde*', message: '"f" expected', position: 5));
    });
    test('failure at 6', () {
      expect(parser,
          isParseFailure('abcdef', message: '"g" expected', position: 6));
      expect(parser,
          isParseFailure('abcdef*', message: '"g" expected', position: 6));
    });
    test('failure at 7', () {
      expect(parser,
          isParseFailure('abcdefg', message: '"h" expected', position: 7));
      expect(parser,
          isParseFailure('abcdefg*', message: '"h" expected', position: 7));
    });
  });
  group('seqMap9', () {
    final parser = seq9(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'), char('i'));
    expectParserInvariants(parser);
    test('success', () {
      final mappedParser =
          parser.map9((a, b, c, d, e, f, g, h, i) => '$a$b$c$d$e$f$g$h$i');
      expect(mappedParser, isParseSuccess('abcdefghi', 'abcdefghi'));
      expect(
          mappedParser, isParseSuccess('abcdefghi*', 'abcdefghi', position: 9));
    });
    test('failure at 0', () {
      expect(parser, isParseFailure('', message: '"a" expected', position: 0));
      expect(parser, isParseFailure('*', message: '"a" expected', position: 0));
    });
    test('failure at 1', () {
      expect(parser, isParseFailure('a', message: '"b" expected', position: 1));
      expect(
          parser, isParseFailure('a*', message: '"b" expected', position: 1));
    });
    test('failure at 2', () {
      expect(
          parser, isParseFailure('ab', message: '"c" expected', position: 2));
      expect(
          parser, isParseFailure('ab*', message: '"c" expected', position: 2));
    });
    test('failure at 3', () {
      expect(
          parser, isParseFailure('abc', message: '"d" expected', position: 3));
      expect(
          parser, isParseFailure('abc*', message: '"d" expected', position: 3));
    });
    test('failure at 4', () {
      expect(
          parser, isParseFailure('abcd', message: '"e" expected', position: 4));
      expect(parser,
          isParseFailure('abcd*', message: '"e" expected', position: 4));
    });
    test('failure at 5', () {
      expect(parser,
          isParseFailure('abcde', message: '"f" expected', position: 5));
      expect(parser,
          isParseFailure('abcde*', message: '"f" expected', position: 5));
    });
    test('failure at 6', () {
      expect(parser,
          isParseFailure('abcdef', message: '"g" expected', position: 6));
      expect(parser,
          isParseFailure('abcdef*', message: '"g" expected', position: 6));
    });
    test('failure at 7', () {
      expect(parser,
          isParseFailure('abcdefg', message: '"h" expected', position: 7));
      expect(parser,
          isParseFailure('abcdefg*', message: '"h" expected', position: 7));
    });
    test('failure at 8', () {
      expect(parser,
          isParseFailure('abcdefgh', message: '"i" expected', position: 8));
      expect(parser,
          isParseFailure('abcdefgh*', message: '"i" expected', position: 8));
    });
  });
}
