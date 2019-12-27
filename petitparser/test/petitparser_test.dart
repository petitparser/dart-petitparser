library petitparser.test.core_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'testutils.dart';

void main() {
  group('examples', () {
    final identifier = letter().seq(word().star()).flatten();
    final number = char('-')
        .optional()
        .seq(digit().plus())
        .seq(char('.').seq(digit().plus()).optional())
        .flatten();
    final quoted =
        char('"').seq(char('"').neg().star()).seq(char('"')).flatten();
    final keyword = string('return')
        .seq(whitespace().plus().flatten())
        .seq(identifier.or(number).or(quoted))
        .map((list) => list.last);
    final javadoc = string('/**')
        .seq(string('*/').neg().star())
        .seq(string('*/'))
        .flatten();
    final multiLine = string('"""')
        .seq((string(r'\"""') | any()).starLazy(string('"""')).flatten())
        .seq(string('"""'))
        .pick(1);
    test('valid identifier', () {
      expectSuccess(identifier, 'a', 'a');
      expectSuccess(identifier, 'a1', 'a1');
      expectSuccess(identifier, 'a12', 'a12');
      expectSuccess(identifier, 'ab', 'ab');
      expectSuccess(identifier, 'a1b', 'a1b');
    });
    test('incomplete identifier', () {
      expectSuccess(identifier, 'a=', 'a', 1);
      expectSuccess(identifier, 'a1-', 'a1', 2);
      expectSuccess(identifier, 'a12+', 'a12', 3);
      expectSuccess(identifier, 'ab ', 'ab', 2);
    });
    test('invalid identifier', () {
      expectFailure(identifier, '', 0, 'letter expected');
      expectFailure(identifier, '1', 0, 'letter expected');
      expectFailure(identifier, '1a', 0, 'letter expected');
    });
    test('positive number', () {
      expectSuccess(number, '1', '1');
      expectSuccess(number, '12', '12');
      expectSuccess(number, '12.3', '12.3');
      expectSuccess(number, '12.34', '12.34');
    });
    test('negative number', () {
      expectSuccess(number, '-1', '-1');
      expectSuccess(number, '-12', '-12');
      expectSuccess(number, '-12.3', '-12.3');
      expectSuccess(number, '-12.34', '-12.34');
    });
    test('incomplete number', () {
      expectSuccess(number, '1..', '1', 1);
      expectSuccess(number, '12-', '12', 2);
      expectSuccess(number, '12.3.', '12.3', 4);
      expectSuccess(number, '12.34.', '12.34', 5);
    });
    test('invalid number', () {
      expectFailure(number, '', 0, 'digit expected');
      expectFailure(number, '-', 1, 'digit expected');
      expectFailure(number, '-x', 1, 'digit expected');
      expectFailure(number, '.', 0, 'digit expected');
      expectFailure(number, '.1', 0, 'digit expected');
    });
    test('valid string', () {
      expectSuccess(quoted, '""', '""');
      expectSuccess(quoted, '"a"', '"a"');
      expectSuccess(quoted, '"ab"', '"ab"');
      expectSuccess(quoted, '"abc"', '"abc"');
    });
    test('incomplete string', () {
      expectSuccess(quoted, '""x', '""', 2);
      expectSuccess(quoted, '"a"x', '"a"', 3);
      expectSuccess(quoted, '"ab"x', '"ab"', 4);
      expectSuccess(quoted, '"abc"x', '"abc"', 5);
    });
    test('invalid string', () {
      expectFailure(quoted, '"', 1, '"\\"" expected');
      expectFailure(quoted, '"a', 2, '"\\"" expected');
      expectFailure(quoted, '"ab', 3, '"\\"" expected');
      expectFailure(quoted, 'a"', 0, '"\\"" expected');
      expectFailure(quoted, 'ab"', 0, '"\\"" expected');
    });
    test('return statement', () {
      expectSuccess(keyword, 'return f', 'f');
      expectSuccess(keyword, 'return  f', 'f');
      expectSuccess(keyword, 'return foo', 'foo');
      expectSuccess(keyword, 'return    foo', 'foo');
      expectSuccess(keyword, 'return 1', '1');
      expectSuccess(keyword, 'return  1', '1');
      expectSuccess(keyword, 'return -2.3', '-2.3');
      expectSuccess(keyword, 'return    -2.3', '-2.3');
      expectSuccess(keyword, 'return "a"', '"a"');
      expectSuccess(keyword, 'return  "a"', '"a"');
    });
    test('invalid statement', () {
      expectFailure(keyword, 'retur f', 0, 'return expected');
      expectFailure(keyword, 'return1', 6, 'whitespace expected');
      expectFailure(keyword, 'return  _', 8, '"\\"" expected');
    });
    test('javadoc', () {
      expectSuccess(javadoc, '/** foo */', '/** foo */');
      expectSuccess(javadoc, '/** * * */', '/** * * */');
    });
    test('multiline', () {
      expectSuccess(multiLine, r'"""abc"""', r'abc');
      expectSuccess(multiLine, r'"""abc\n"""', r'abc\n');
      expectSuccess(multiLine, r'"""abc\"""def"""', r'abc\"""def');
    });
  });

  group('regressions', () {
    test('flatten().trim()', () {
      final parser = word().plus().flatten().trim();
      expectSuccess(parser, 'ab1', 'ab1');
      expectSuccess(parser, ' ab1 ', 'ab1');
      expectSuccess(parser, '  ab1  ', 'ab1');
    });
    test('trim().flatten()', () {
      final parser = word().plus().trim().flatten();
      expectSuccess(parser, 'ab1', 'ab1');
      expectSuccess(parser, ' ab1 ', ' ab1 ');
      expectSuccess(parser, '  ab1  ', '  ab1  ');
    });
    group('separatedBy()', () {
      void testWith(
          String name, Parser<List<T>> Function<T>(Parser<T>) builder) {
        test(name, () {
          final string = letter();
          final stringList = builder(string);
          expect(stringList is Parser<List<String>>, isTrue);
          expectSuccess(stringList, 'a,b,c', ['a', 'b', 'c']);

          final integer = digit().map(int.parse);
          final integerList = builder(integer);
          expect(integerList is Parser<List<int>>, isTrue);
          expectSuccess(integerList, '1,2,3', [1, 2, 3]);

          final mixed = string | integer;
          final mixedList = builder(mixed);
          expect(mixedList is Parser<List>, isTrue);
          expectSuccess(mixedList, '1,a,2', [1, 'a', 2]);
        });
      }

      Parser<List<T>> typeParam<T>(Parser<T> parser) =>
          parser.separatedBy<T>(char(','), includeSeparators: false);
      Parser<List<T>> castList<T>(Parser<T> parser) =>
          parser.separatedBy(char(','), includeSeparators: false).castList<T>();
      Parser<List<T>> smartCompiler<T>(Parser<T> parser) =>
          parser.separatedBy(char(','), includeSeparators: false);

      testWith('with list created using desired type', typeParam);
      testWith('with generic list cast to desired type', castList);
      testWith('with compiler inferring desired type', smartCompiler);
    });
  });

  group('tutorial', () {
    test('simple grammar', () {
      final id = letter().seq(letter().or(digit()).star());
      final id1 = id.parse('yeah');
      final id2 = id.parse('f12');
      expect(id1.value, [
        'y',
        ['e', 'a', 'h']
      ]);
      expect(id2.value, [
        'f',
        ['1', '2']
      ]);
      final id3 = id.parse('123');
      expect(id3.message, 'letter expected');
      expect(id3.position, 0);
      expect(id.accept('foo'), isTrue);
      expect(id.accept('123'), isFalse);
    });
    test('different parsers', () {
      final id = letter().seq(word().star()).flatten();
      final matches = id.matchesSkipping('foo 123 bar4');
      expect(matches, ['foo', 'bar4']);
    });
    test('complicated grammar', () {
      final number = digit().plus().flatten().trim().map(int.parse);
      final term = undefined();
      final prod = undefined();
      final prim = undefined();
      term.set(prod.seq(char('+').trim()).seq(term).map((values) {
        return values[0] + values[2];
      }).or(prod));
      prod.set(prim.seq(char('*').trim()).seq(prod).map((values) {
        return values[0] * values[2];
      }).or(prim));
      prim.set(char('(').trim().seq(term).seq(char(')'.trim())).map((values) {
        return values[1];
      }).or(number));
      final start = term.end();
      expect(7, start.parse('1 + 2 * 3').value);
      expect(9, start.parse('(1 + 2) * 3').value);
    });
  });
}
