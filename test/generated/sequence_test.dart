// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import '../utils/assertions.dart';
import '../utils/checks.dart';

void main() {
  group('seq2', () {
    final parser = seq2(char('a'), char('b'));
    const record = ('a', 'b');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('ab', result: record);
      check(parser).parseSuccess('ab*', result: record, position: 2);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('toSequenceParser()', () {
      final alternate = (char('a'), char('b')).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a').then(char('b'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map2', () {
    final parser = seq2(char('a'), char('b')).map2((a, b) => '$a$b');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('ab', result: 'ab');
      check(parser).parseSuccess('ab*', result: 'ab', position: 2);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
  });
  group('record', () {
    const record = ('a', 'b');
    const other = ('b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
    });
    test('map', () {
      check(
        record.map((a, b) {
          check(a).equals('a');
          check(b).equals('b');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b)');
      check(other.toString()).endsWith('(b, a)');
    });
  });
  group('seq3', () {
    final parser = seq3(char('a'), char('b'), char('c'));
    const record = ('a', 'b', 'c');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abc', result: record);
      check(parser).parseSuccess('abc*', result: record, position: 3);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('toSequenceParser()', () {
      final alternate = (char('a'), char('b'), char('c')).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a').then(char('b')).then(char('c'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map3', () {
    final parser = seq3(
      char('a'),
      char('b'),
      char('c'),
    ).map3((a, b, c) => '$a$b$c');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abc', result: 'abc');
      check(parser).parseSuccess('abc*', result: 'abc', position: 3);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c');
    const other = ('c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
    });
    test('map', () {
      check(
        record.map((a, b, c) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c)');
      check(other.toString()).endsWith('(c, b, a)');
    });
  });
  group('seq4', () {
    final parser = seq4(char('a'), char('b'), char('c'), char('d'));
    const record = ('a', 'b', 'c', 'd');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcd', result: record);
      check(parser).parseSuccess('abcd*', result: record, position: 4);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map4', () {
    final parser = seq4(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
    ).map4((a, b, c, d) => '$a$b$c$d');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcd', result: 'abcd');
      check(parser).parseSuccess('abcd*', result: 'abcd', position: 4);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd');
    const other = ('d', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
    });
    test('map', () {
      check(
        record.map((a, b, c, d) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d)');
      check(other.toString()).endsWith('(d, c, b, a)');
    });
  });
  group('seq5', () {
    final parser = seq5(char('a'), char('b'), char('c'), char('d'), char('e'));
    const record = ('a', 'b', 'c', 'd', 'e');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcde', result: record);
      check(parser).parseSuccess('abcde*', result: record, position: 5);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'))
          .then(char('e'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map5', () {
    final parser = seq5(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
    ).map5((a, b, c, d, e) => '$a$b$c$d$e');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcde', result: 'abcde');
      check(parser).parseSuccess('abcde*', result: 'abcde', position: 5);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e');
    const other = ('e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
      check(record.$5).equals('e');
    });
    test('map', () {
      check(
        record.map((a, b, c, d, e) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          check(e).equals('e');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d, e)');
      check(other.toString()).endsWith('(e, d, c, b, a)');
    });
  });
  group('seq6', () {
    final parser = seq6(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
    );
    const record = ('a', 'b', 'c', 'd', 'e', 'f');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdef', result: record);
      check(parser).parseSuccess('abcdef*', result: record, position: 6);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'))
          .then(char('e'))
          .then(char('f'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map6', () {
    final parser = seq6(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
    ).map6((a, b, c, d, e, f) => '$a$b$c$d$e$f');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdef', result: 'abcdef');
      check(parser).parseSuccess('abcdef*', result: 'abcdef', position: 6);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f');
    const other = ('f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
      check(record.$5).equals('e');
      check(record.$6).equals('f');
    });
    test('map', () {
      check(
        record.map((a, b, c, d, e, f) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          check(e).equals('e');
          check(f).equals('f');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d, e, f)');
      check(other.toString()).endsWith('(f, e, d, c, b, a)');
    });
  });
  group('seq7', () {
    final parser = seq7(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
    );
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefg', result: record);
      check(parser).parseSuccess('abcdefg*', result: record, position: 7);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'))
          .then(char('e'))
          .then(char('f'))
          .then(char('g'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map7', () {
    final parser = seq7(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
    ).map7((a, b, c, d, e, f, g) => '$a$b$c$d$e$f$g');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefg', result: 'abcdefg');
      check(parser).parseSuccess('abcdefg*', result: 'abcdefg', position: 7);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g');
    const other = ('g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
      check(record.$5).equals('e');
      check(record.$6).equals('f');
      check(record.$7).equals('g');
    });
    test('map', () {
      check(
        record.map((a, b, c, d, e, f, g) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          check(e).equals('e');
          check(f).equals('f');
          check(g).equals('g');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d, e, f, g)');
      check(other.toString()).endsWith('(g, f, e, d, c, b, a)');
    });
  });
  group('seq8', () {
    final parser = seq8(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h'),
    );
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefgh', result: record);
      check(parser).parseSuccess('abcdefgh*', result: record, position: 8);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
    test('failure at 7', () {
      check(parser)
          .parseFailure('abcdefg', message: '"h" expected', position: 7);
      check(parser)
          .parseFailure('abcdefg*', message: '"h" expected', position: 7);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
        char('h'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'))
          .then(char('e'))
          .then(char('f'))
          .then(char('g'))
          .then(char('h'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map8', () {
    final parser = seq8(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h'),
    ).map8((a, b, c, d, e, f, g, h) => '$a$b$c$d$e$f$g$h');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefgh', result: 'abcdefgh');
      check(parser).parseSuccess('abcdefgh*', result: 'abcdefgh', position: 8);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
    test('failure at 7', () {
      check(parser)
          .parseFailure('abcdefg', message: '"h" expected', position: 7);
      check(parser)
          .parseFailure('abcdefg*', message: '"h" expected', position: 7);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
    const other = ('h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
      check(record.$5).equals('e');
      check(record.$6).equals('f');
      check(record.$7).equals('g');
      check(record.$8).equals('h');
    });
    test('map', () {
      check(
        record.map((a, b, c, d, e, f, g, h) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          check(e).equals('e');
          check(f).equals('f');
          check(g).equals('g');
          check(h).equals('h');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d, e, f, g, h)');
      check(other.toString()).endsWith('(h, g, f, e, d, c, b, a)');
    });
  });
  group('seq9', () {
    final parser = seq9(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h'),
      char('i'),
    );
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefghi', result: record);
      check(parser).parseSuccess('abcdefghi*', result: record, position: 9);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
    test('failure at 7', () {
      check(parser)
          .parseFailure('abcdefg', message: '"h" expected', position: 7);
      check(parser)
          .parseFailure('abcdefg*', message: '"h" expected', position: 7);
    });
    test('failure at 8', () {
      check(parser)
          .parseFailure('abcdefgh', message: '"i" expected', position: 8);
      check(parser)
          .parseFailure('abcdefgh*', message: '"i" expected', position: 8);
    });
    test('toSequenceParser()', () {
      final alternate = (
        char('a'),
        char('b'),
        char('c'),
        char('d'),
        char('e'),
        char('f'),
        char('g'),
        char('h'),
        char('i'),
      ).toSequenceParser();
      check(alternate).isDeepEqualTo(parser);
    });
    test('then()', () {
      final alternate = char('a')
          .then(char('b'))
          .then(char('c'))
          .then(char('d'))
          .then(char('e'))
          .then(char('f'))
          .then(char('g'))
          .then(char('h'))
          .then(char('i'));
      check(alternate).isDeepEqualTo(parser);
    });
  });
  group('map9', () {
    final parser = seq9(
      char('a'),
      char('b'),
      char('c'),
      char('d'),
      char('e'),
      char('f'),
      char('g'),
      char('h'),
      char('i'),
    ).map9((a, b, c, d, e, f, g, h, i) => '$a$b$c$d$e$f$g$h$i');
    expectParserInvariants(parser);
    test('success', () {
      check(parser).parseSuccess('abcdefghi', result: 'abcdefghi');
      check(parser)
          .parseSuccess('abcdefghi*', result: 'abcdefghi', position: 9);
    });
    test('failure at 0', () {
      check(parser).parseFailure('', message: '"a" expected', position: 0);
      check(parser).parseFailure('*', message: '"a" expected', position: 0);
    });
    test('failure at 1', () {
      check(parser).parseFailure('a', message: '"b" expected', position: 1);
      check(parser).parseFailure('a*', message: '"b" expected', position: 1);
    });
    test('failure at 2', () {
      check(parser).parseFailure('ab', message: '"c" expected', position: 2);
      check(parser).parseFailure('ab*', message: '"c" expected', position: 2);
    });
    test('failure at 3', () {
      check(parser).parseFailure('abc', message: '"d" expected', position: 3);
      check(parser).parseFailure('abc*', message: '"d" expected', position: 3);
    });
    test('failure at 4', () {
      check(parser).parseFailure('abcd', message: '"e" expected', position: 4);
      check(parser).parseFailure('abcd*', message: '"e" expected', position: 4);
    });
    test('failure at 5', () {
      check(parser).parseFailure('abcde', message: '"f" expected', position: 5);
      check(parser)
          .parseFailure('abcde*', message: '"f" expected', position: 5);
    });
    test('failure at 6', () {
      check(parser)
          .parseFailure('abcdef', message: '"g" expected', position: 6);
      check(parser)
          .parseFailure('abcdef*', message: '"g" expected', position: 6);
    });
    test('failure at 7', () {
      check(parser)
          .parseFailure('abcdefg', message: '"h" expected', position: 7);
      check(parser)
          .parseFailure('abcdefg*', message: '"h" expected', position: 7);
    });
    test('failure at 8', () {
      check(parser)
          .parseFailure('abcdefgh', message: '"i" expected', position: 8);
      check(parser)
          .parseFailure('abcdefgh*', message: '"i" expected', position: 8);
    });
  });
  group('record', () {
    const record = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
    const other = ('i', 'h', 'g', 'f', 'e', 'd', 'c', 'b', 'a');
    test('accessors', () {
      check(record.$1).equals('a');
      check(record.$2).equals('b');
      check(record.$3).equals('c');
      check(record.$4).equals('d');
      check(record.$5).equals('e');
      check(record.$6).equals('f');
      check(record.$7).equals('g');
      check(record.$8).equals('h');
      check(record.$9).equals('i');
    });
    test('map', () {
      check(
        record.map((a, b, c, d, e, f, g, h, i) {
          check(a).equals('a');
          check(b).equals('b');
          check(c).equals('c');
          check(d).equals('d');
          check(e).equals('e');
          check(f).equals('f');
          check(g).equals('g');
          check(h).equals('h');
          check(i).equals('i');
          return 42;
        }),
      ).equals(42);
    });
    test('equals', () {
      check(record).equals(record);
      check(record).not((it) => it.equals(other));
      check(other).not((it) => it.equals(record));
      check(other).equals(other);
    });
    test('hashCode', () {
      check(record.hashCode).equals(record.hashCode);
      check(record.hashCode).not((it) => it.equals(other.hashCode));
      check(other.hashCode).not((it) => it.equals(record.hashCode));
      check(other.hashCode).equals(other.hashCode);
    });
    test('toString', () {
      check(record.toString()).endsWith('(a, b, c, d, e, f, g, h, i)');
      check(other.toString()).endsWith('(i, h, g, f, e, d, c, b, a)');
    });
  });
}
