// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import '../utils/assertions.dart';
import '../utils/matchers.dart';

void main() {
  group('seq2', () {
    final parser = seq2(char('a'), char('b'));
    const record = ('a', 'b');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('ab', result: record));
      expect(parser, isParseSuccess('ab*', result: record, position: 2));
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
  group('toSequenceParser()', () {
    final parser = (char('a'), char('b')).toSequenceParser();
    const record = ('a', 'b');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('ab', result: record));
      expect(parser, isParseSuccess('ab*', result: record, position: 2));
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
  group('record', () {
    const record = ('a', 'b');
    const other = ('b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'b');
    });
    test('map', () {
      expect(record.map((a, b) {
        expect(a, 'a');
        expect(b, 'b');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b)'));
      expect(other.toString(), endsWith('(b, a)'));
    });
  });
  group('seq3', () {
    final parser = seq3(char('a'), char('b'), char('c'));
    const record = ('a', 'b', 'c');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abc', result: record));
      expect(parser, isParseSuccess('abc*', result: record, position: 3));
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
  group('toSequenceParser()', () {
    final parser = (char('a'), char('b'), char('c')).toSequenceParser();
    const record = ('a', 'b', 'c');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abc', result: record));
      expect(parser, isParseSuccess('abc*', result: record, position: 3));
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
  group('record', () {
    const record = ('a', 'b', 'c');
    const other = ('c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'c');
    });
    test('map', () {
      expect(record.map((a, b, c) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c)'));
      expect(other.toString(), endsWith('(c, b, a)'));
    });
  });
  group('seq4', () {
    final parser = seq4(char('a'), char('b'), char('c'), char('d'));
    const record = ('a', 'b', 'c', 'd');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcd', result: record));
      expect(parser, isParseSuccess('abcd*', result: record, position: 4));
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
  group('toSequenceParser()', () {
    final parser =
        (char('a'), char('b'), char('c'), char('d')).toSequenceParser();
    const record = ('a', 'b', 'c', 'd');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcd', result: record));
      expect(parser, isParseSuccess('abcd*', result: record, position: 4));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd');
    const other = ('d', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'd');
    });
    test('map', () {
      expect(record.map((a, b, c, d) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d)'));
      expect(other.toString(), endsWith('(d, c, b, a)'));
    });
  });
  group('seq5', () {
    final parser = seq5(char('a'), char('b'), char('c'), char('d'), char('e'));
    const record = ('a', 'b', 'c', 'd', 'e');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcde', result: record));
      expect(parser, isParseSuccess('abcde*', result: record, position: 5));
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
  group('toSequenceParser()', () {
    final parser = (char('a'), char('b'), char('c'), char('d'), char('e'))
        .toSequenceParser();
    const record = ('a', 'b', 'c', 'd', 'e');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcde', result: record));
      expect(parser, isParseSuccess('abcde*', result: record, position: 5));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e');
    const other = ('e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      expect(record.$5, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fifth, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'e');
    });
    test('map', () {
      expect(record.map((a, b, c, d, e) {
        expect(a, 'a');
        expect(b, 'b');
        expect(c, 'c');
        expect(d, 'd');
        expect(e, 'e');
        return 42;
      }), 42);
    });
    test('equals', () {
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d, e)'));
      expect(other.toString(), endsWith('(e, d, c, b, a)'));
    });
  });
  group('seq6', () {
    final parser =
        seq6(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'));
    const record = ('a', 'b', 'c', 'd', 'e', 'f');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdef', result: record));
      expect(parser, isParseSuccess('abcdef*', result: record, position: 6));
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
  group('toSequenceParser()', () {
    final parser = (
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f')
    ).toSequenceParser();
    const record = ('a', 'b', 'c', 'd', 'e', 'f');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdef', result: record));
      expect(parser, isParseSuccess('abcdef*', result: record, position: 6));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f');
    const other = ('f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      expect(record.$5, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fifth, 'e');
      expect(record.$6, 'f');
      // ignore: deprecated_member_use_from_same_package
      expect(record.sixth, 'f');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'f');
    });
    test('map', () {
      expect(record.map((a, b, c, d, e, f) {
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
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d, e, f)'));
      expect(other.toString(), endsWith('(f, e, d, c, b, a)'));
    });
  });
  group('seq7', () {
    final parser = seq7(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'));
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefg', result: record));
      expect(parser, isParseSuccess('abcdefg*', result: record, position: 7));
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
  group('toSequenceParser()', () {
    final parser = (
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g')
    ).toSequenceParser();
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefg', result: record));
      expect(parser, isParseSuccess('abcdefg*', result: record, position: 7));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g');
    const other = ('g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      expect(record.$5, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fifth, 'e');
      expect(record.$6, 'f');
      // ignore: deprecated_member_use_from_same_package
      expect(record.sixth, 'f');
      expect(record.$7, 'g');
      // ignore: deprecated_member_use_from_same_package
      expect(record.seventh, 'g');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'g');
    });
    test('map', () {
      expect(record.map((a, b, c, d, e, f, g) {
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
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d, e, f, g)'));
      expect(other.toString(), endsWith('(g, f, e, d, c, b, a)'));
    });
  });
  group('seq8', () {
    final parser = seq8(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'));
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefgh', result: record));
      expect(parser, isParseSuccess('abcdefgh*', result: record, position: 8));
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
  group('toSequenceParser()', () {
    final parser = (
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h')
    ).toSequenceParser();
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefgh', result: record));
      expect(parser, isParseSuccess('abcdefgh*', result: record, position: 8));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    const other = ('h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      expect(record.$5, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fifth, 'e');
      expect(record.$6, 'f');
      // ignore: deprecated_member_use_from_same_package
      expect(record.sixth, 'f');
      expect(record.$7, 'g');
      // ignore: deprecated_member_use_from_same_package
      expect(record.seventh, 'g');
      expect(record.$8, 'h');
      // ignore: deprecated_member_use_from_same_package
      expect(record.eighth, 'h');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'h');
    });
    test('map', () {
      expect(record.map((a, b, c, d, e, f, g, h) {
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
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d, e, f, g, h)'));
      expect(other.toString(), endsWith('(h, g, f, e, d, c, b, a)'));
    });
  });
  group('seq9', () {
    final parser = seq9(char('a'), char('b'), char('c'), char('d'), char('e'),
        char('f'), char('g'), char('h'), char('i'));
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefghi', result: record));
      expect(parser, isParseSuccess('abcdefghi*', result: record, position: 9));
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
  group('toSequenceParser()', () {
    final parser = (
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h'),
      char('i')
    ).toSequenceParser();
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    expectParserInvariants(parser);
    test('success', () {
      expect(parser, isParseSuccess('abcdefghi', result: record));
      expect(parser, isParseSuccess('abcdefghi*', result: record, position: 9));
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
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    const other = ('i', 'h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      expect(record.$1, 'a');
      // ignore: deprecated_member_use_from_same_package
      expect(record.first, 'a');
      expect(record.$2, 'b');
      // ignore: deprecated_member_use_from_same_package
      expect(record.second, 'b');
      expect(record.$3, 'c');
      // ignore: deprecated_member_use_from_same_package
      expect(record.third, 'c');
      expect(record.$4, 'd');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fourth, 'd');
      expect(record.$5, 'e');
      // ignore: deprecated_member_use_from_same_package
      expect(record.fifth, 'e');
      expect(record.$6, 'f');
      // ignore: deprecated_member_use_from_same_package
      expect(record.sixth, 'f');
      expect(record.$7, 'g');
      // ignore: deprecated_member_use_from_same_package
      expect(record.seventh, 'g');
      expect(record.$8, 'h');
      // ignore: deprecated_member_use_from_same_package
      expect(record.eighth, 'h');
      expect(record.$9, 'i');
      // ignore: deprecated_member_use_from_same_package
      expect(record.ninth, 'i');
      // ignore: deprecated_member_use_from_same_package
      expect(record.last, 'i');
    });
    test('map', () {
      expect(record.map((a, b, c, d, e, f, g, h, i) {
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
      expect(record, record);
      expect(record, isNot(other));
      expect(other, isNot(record));
      expect(other, other);
    });
    test('hashCode', () {
      expect(record.hashCode, record.hashCode);
      expect(record.hashCode, isNot(other.hashCode));
      expect(other.hashCode, isNot(record.hashCode));
      expect(other.hashCode, other.hashCode);
    });
    test('toString', () {
      expect(record.toString(), endsWith('(a, b, c, d, e, f, g, h, i)'));
      expect(other.toString(), endsWith('(i, h, g, f, e, d, c, b, a)'));
    });
  });
}
