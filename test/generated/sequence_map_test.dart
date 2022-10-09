// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import '../utils/assertions.dart';
import '../utils/matchers.dart';

void main() {
  group('seqMap2', () {
    final parser = seqMap2(char('a'), char('b'), (a, b) => '$a$b');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('ab', 'ab'));
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
    final parser =
        seqMap3(char('a'), char('b'), char('c'), (a, b, c) => '$a$b$c');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abc', 'abc'));
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
    final parser = seqMap4(
        char('a'), char('b'), char('c'), char('d'), (a, b, c, d) => '$a$b$c$d');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcd', 'abcd'));
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
    final parser = seqMap5(char('a'), char('b'), char('c'), char('d'),
        char('e'), (a, b, c, d, e) => '$a$b$c$d$e');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcde', 'abcde'));
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
    final parser = seqMap6(char('a'), char('b'), char('c'), char('d'),
        char('e'), char('f'), (a, b, c, d, e, f) => '$a$b$c$d$e$f');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdef', 'abcdef'));
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
    final parser = seqMap7(
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
        (a, b, c, d, e, f, g) => '$a$b$c$d$e$f$g');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefg', 'abcdefg'));
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
    final parser = seqMap8(
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
        char('h'),
        (a, b, c, d, e, f, g, h) => '$a$b$c$d$e$f$g$h');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefgh', 'abcdefgh'));
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
    final parser = seqMap9(
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
        char('h'),
        char('i'),
        (a, b, c, d, e, f, g, h, i) => '$a$b$c$d$e$f$g$h$i');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefghi', 'abcdefghi'));
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
