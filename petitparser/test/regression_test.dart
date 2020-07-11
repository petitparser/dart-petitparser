library petitparser.test.regression_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
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
    void testWith(String name, Parser<List<T>> Function<T>(Parser<T>) builder) {
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
}
