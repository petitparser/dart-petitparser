library reflection_test;

import 'package:unittest/unittest.dart';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';

main() {
  group('iterator', () {
    test('single', () {
      var parser1 = lowercase();
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('nested', () {
      var parser3 = lowercase();
      var parser2 = parser3.star();
      var parser1 = parser2.flatten();
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('branched', () {
      var parser3 = lowercase();
      var parser2 = uppercase();
      var parser1 = parser2.seq(parser3);
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser3, parser2]);
    });
    test('duplicated', () {
      var parser2 = uppercase();
      var parser1 = parser2.seq(parser2);
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2]);
    });
    test('knot', () {
      var parser1 = undefined();
      parser1.set(parser1);
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('looping', () {
      var parser1 = undefined();
      var parser2 = undefined();
      var parser3 = undefined();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      var parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('basic', () {
      var lower = lowercase();
      var iterator = allParser(lower).iterator;
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, lower);
      expect(iterator.current, lower);
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isFalse);
    });
  });

  group('transform', () {
    test('identity', () {
      var lower = lowercase();
      var parser = lower.setable();
      var transformed = transformParser(parser, (parser) => parser);
      expect(transformed.equals(parser), isTrue);
    });
    test('root', () {
      var input = lowercase();
      var source = lowercase();
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.equals(parser) ? target : parser;
      });
      expect(input.equals(output), isFalse);
      expect(output.equals(target), isTrue);
    });
    test('delegate', () {
      var input = lowercase().setable();
      var source = lowercase();
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.equals(parser) ? target : parser;
      });
      expect(input.equals(output), isFalse);
      expect(output.equals(target.setable()), isTrue);
    });
    test('double reference', () {
      var lower = lowercase();
      var input = lower & lower;
      var source = lowercase();
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.equals(parser) ? target : parser;
      });
      expect(input.equals(output), isFalse);
      expect(output.equals(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
  });

  group('optimize', () {
    test('remove setables', () {
      var input = lowercase().setable();
      var output = removeSetables(input);
      expect(output.equals(lowercase()), isTrue);
    });
    test('remove nested setables', () {
      var input = lowercase().setable().star();
      var output = removeSetables(input);
      expect(output.equals(lowercase().star()), isTrue);
    });
    test('remove double setables', () {
      var input = lowercase().setable().setable();
      var output = removeSetables(input);
      expect(output.equals(lowercase()), isTrue);
    });
  });

  group('copying and matching', () {
    void verify(Parser parser) {
      var copy = parser.copy();
      expect(copy.runtimeType, parser.runtimeType);
      expect(copy.children, pairwiseCompare(parser.children, identical, 'same children'));
      expect(copy.equals(copy), isTrue);
      expect(parser.equals(parser), isTrue);
      expect(copy, isNot(same(parser)));
      expect(copy.equals(parser), isTrue);
      expect(parser.equals(copy), isTrue);
    }
    test('and()', () => verify(digit().and()));
    test('char()', () => verify(char('a')));
    test('digit()', () => verify(digit()));
    test('end()', () => verify(digit().end()));
    test('epsilon()', () => verify(epsilon()));
    test('failure()', () => verify(failure()));
    test('flatten()', () => verify(digit().flatten()));
    test('map()', () => verify(digit().map((a) => a)));
    test('not()', () => verify(digit().not()));
    test('optional()', () => verify(digit().optional()));
    test('or()', () => verify(digit().or(word())));
    test('plus()', () => verify(digit().plus()));
    test('plusGreedy()', () => verify(digit().plusGreedy(word())));
    test('plusLazy()', () => verify(digit().plusLazy(word())));
    test('repeat()', () => verify(digit().repeat(2, 3)));
    test('repeatGreedy()', () => verify(digit().repeatGreedy(word(), 2, 3)));
    test('repeatLazy()', () => verify(digit().repeatLazy(word(), 2, 3)));
    test('seq()', () => verify(digit().seq(word())));
    test('setable()', () => verify(digit().setable()));
    test('star()', () => verify(digit().star()));
    test('starGreedy()', () => verify(digit().starGreedy(word())));
    test('starLazy()', () => verify(digit().starLazy(word())));
    test('string()', () => verify(string('ab')));
    test('times()', () => verify(digit().times(2)));
    test('token()', () => verify(digit().token()));
    test('trim()', () => verify(digit().trim()));
    test('undefined()', () => verify(undefined()));
  });
}
