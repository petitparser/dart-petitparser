// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import '../utils/assertions.dart';
import '../utils/matchers.dart';

void main() {
  group('seq2', () {
    final parser = seq2(char('a'), char('b'));
    const sequence = Sequence2('a', 'b');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('ab', result: sequence));
      expect(parser, isParseSuccess('ab*', result: sequence, position: 2));
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
  group('map2', () {
    final parser = seq2(char('a'), char('b')).map2((a, b) => '$a$b');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('ab', result: 'ab'));
      expect(parser, isParseSuccess('ab*', result: 'ab', position: 2));
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
  group('Sequence2', () {
    const sequence = Sequence2('a', 'b');
    const other = Sequence2('b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.last, 'b');
    });
    test('map', () {
      expect(sequence.map((a, b) {
        expect(a, 'a');
        expect(b, 'b');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b)'));
      expect(other.toString(), endsWith('(b, a)'));
    });
  });
  group('seq3', () {
    final parser = seq3(char('a'), char('b'), char('c'));
    const sequence = Sequence3('a', 'b', 'c');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abc', result: sequence));
      expect(parser, isParseSuccess('abc*', result: sequence, position: 3));
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
  group('map3', () {
    final parser =
        seq3(char('a'), char('b'), char('c')).map3((a, b, c) => '$a$b$c');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abc', result: 'abc'));
      expect(parser, isParseSuccess('abc*', result: 'abc', position: 3));
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
  group('Sequence3', () {
    const sequence = Sequence3('a', 'b', 'c');
    const other = Sequence3('c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.last, 'c');
    });
    test('map', () {
      expect(sequence.map((a, b, c) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c)'));
      expect(other.toString(), endsWith('(c, b, a)'));
    });
  });
  group('seq4', () {
    final parser = seq4(char('a'), char('b'), char('c'), char('d'));
    const sequence = Sequence4('a', 'b', 'c', 'd');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcd', result: sequence));
      expect(parser, isParseSuccess('abcd*', result: sequence, position: 4));
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
  group('map4', () {
    final parser = seq4(char('a'), char('b'), char('c'), char('d'))
        .map4((a, b, c, d) => '$a$b$c$d');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcd', result: 'abcd'));
      expect(parser, isParseSuccess('abcd*', result: 'abcd', position: 4));
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
  group('Sequence4', () {
    const sequence = Sequence4('a', 'b', 'c', 'd');
    const other = Sequence4('d', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.last, 'd');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d)'));
      expect(other.toString(), endsWith('(d, c, b, a)'));
    });
  });
  group('seq5', () {
    final parser = seq5(char('a'), char('b'), char('c'), char('d'), char('e'));
    const sequence = Sequence5('a', 'b', 'c', 'd', 'e');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcde', result: sequence));
      expect(parser, isParseSuccess('abcde*', result: sequence, position: 5));
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
  group('map5', () {
    final parser = seq5(char('a'), char('b'), char('c'), char('d'), char('e'))
        .map5((a, b, c, d, e) => '$a$b$c$d$e');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcde', result: 'abcde'));
      expect(parser, isParseSuccess('abcde*', result: 'abcde', position: 5));
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
  group('Sequence5', () {
    const sequence = Sequence5('a', 'b', 'c', 'd', 'e');
    const other = Sequence5('e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.fifth, 'e');
      expect(sequence.last, 'e');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d, e) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d, e)'));
      expect(other.toString(), endsWith('(e, d, c, b, a)'));
    });
  });
  group('seq6', () {
    final parser =
        seq6(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'));
    const sequence = Sequence6('a', 'b', 'c', 'd', 'e', 'f');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdef', result: sequence));
      expect(parser, isParseSuccess('abcdef*', result: sequence, position: 6));
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
  group('map6', () {
    final parser =
        seq6(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'))
            .map6((a, b, c, d, e, f) => '$a$b$c$d$e$f');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdef', result: 'abcdef'));
      expect(parser, isParseSuccess('abcdef*', result: 'abcdef', position: 6));
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
  group('Sequence6', () {
    const sequence = Sequence6('a', 'b', 'c', 'd', 'e', 'f');
    const other = Sequence6('f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.fifth, 'e');
      expect(sequence.sixth, 'f');
      expect(sequence.last, 'f');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d, e, f) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        expect(f, 'f');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d, e, f)'));
      expect(other.toString(), endsWith('(f, e, d, c, b, a)'));
    });
  });
  group('seq7', () {
    final parser = seq7(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'));
    const sequence = Sequence7('a', 'b', 'c', 'd', 'e', 'f', 'g');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefg', result: sequence));
      expect(parser, isParseSuccess('abcdefg*', result: sequence, position: 7));
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
  group('map7', () {
    final parser = seq7(char('a'), char('b'), char('c'), char('d'), char('e'),
            char('f'), char('g'))
        .map7((a, b, c, d, e, f, g) => '$a$b$c$d$e$f$g');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefg', result: 'abcdefg'));
      expect(
          parser, isParseSuccess('abcdefg*', result: 'abcdefg', position: 7));
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
  group('Sequence7', () {
    const sequence = Sequence7('a', 'b', 'c', 'd', 'e', 'f', 'g');
    const other = Sequence7('g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.fifth, 'e');
      expect(sequence.sixth, 'f');
      expect(sequence.seventh, 'g');
      expect(sequence.last, 'g');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d, e, f, g) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        expect(f, 'f');
        expect(g, 'g');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d, e, f, g)'));
      expect(other.toString(), endsWith('(g, f, e, d, c, b, a)'));
    });
  });
  group('seq8', () {
    final parser = seq8(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'));
    const sequence = Sequence8('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefgh', result: sequence));
      expect(
          parser, isParseSuccess('abcdefgh*', result: sequence, position: 8));
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
  group('map8', () {
    final parser = seq8(char('a'), char('b'), char('c'), char('d'), char('e'),
            char('f'), char('g'), char('h'))
        .map8((a, b, c, d, e, f, g, h) => '$a$b$c$d$e$f$g$h');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefgh', result: 'abcdefgh'));
      expect(
          parser, isParseSuccess('abcdefgh*', result: 'abcdefgh', position: 8));
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
  group('Sequence8', () {
    const sequence = Sequence8('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    const other = Sequence8('h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.fifth, 'e');
      expect(sequence.sixth, 'f');
      expect(sequence.seventh, 'g');
      expect(sequence.eighth, 'h');
      expect(sequence.last, 'h');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d, e, f, g, h) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        expect(f, 'f');
        expect(g, 'g');
        expect(h, 'h');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d, e, f, g, h)'));
      expect(other.toString(), endsWith('(h, g, f, e, d, c, b, a)'));
    });
  });
  group('seq9', () {
    final parser = seq9(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'), char('i'));
    const sequence = Sequence9('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefghi', result: sequence));
      expect(
          parser, isParseSuccess('abcdefghi*', result: sequence, position: 9));
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
  group('map9', () {
    final parser = seq9(char('a'), char('b'), char('c'), char('d'), char('e'),
            char('f'), char('g'), char('h'), char('i'))
        .map9((a, b, c, d, e, f, g, h, i) => '$a$b$c$d$e$f$g$h$i');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefghi', result: 'abcdefghi'));
      expect(parser,
          isParseSuccess('abcdefghi*', result: 'abcdefghi', position: 9));
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
  group('Sequence9', () {
    const sequence = Sequence9('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    const other = Sequence9('i', 'h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(sequence.first, 'a');
      expect(sequence.second, 'b');
      expect(sequence.third, 'c');
      expect(sequence.fourth, 'd');
      expect(sequence.fifth, 'e');
      expect(sequence.sixth, 'f');
      expect(sequence.seventh, 'g');
      expect(sequence.eighth, 'h');
      expect(sequence.ninth, 'i');
      expect(sequence.last, 'i');
    });
    test('map', () {
      expect(sequence.map((a, b, c, d, e, f, g, h, i) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        expect(f, 'f');
        expect(g, 'g');
        expect(h, 'h');
        expect(i, 'i');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(sequence, sequence);
      expect(sequence, isNot(other));
      expect(other, isNot(sequence));
      expect(other, other);
    });
    test('hashCode', () {
      expect(sequence.hashCode, sequence.hashCode);
      expect(sequence.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(sequence.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(sequence.toString(), endsWith('(a, b, c, d, e, f, g, h, i)'));
      expect(other.toString(), endsWith('(i, h, g, f, e, d, c, b, a)'));
    });
  });
}
