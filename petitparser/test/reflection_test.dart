import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

void expectAll(Iterable<Parser> parsers, Iterable<String> inputs) {
  final matchedParsers = <Parser, int>{for (final parser in parsers) parser: 0};
  final matchedInputs = <String, int>{for (final input in inputs) input: 0};
  for (final parser in parsers) {
    final tester = parser.end();
    for (final input in inputs) {
      if (tester.accept(input)) {
        matchedInputs[input] = matchedInputs[input]! + 1;
        matchedParsers[parser] = matchedParsers[parser]! + 1;
      }
    }
  }
  matchedInputs.forEach((input, count) =>
      expect(count, greaterThan(0), reason: '$input expected'));
  matchedParsers.forEach((parser, count) =>
      expect(count, greaterThan(0), reason: '$parser not expected'));
}

// ignore_for_file: deprecated_member_use_from_same_package
void main() {
  group('first-set', () {
    test('plus', () {
      final parser = char('a').plus();
      expectAll(firstSet(parser), ['a']);
    });
    test('star', () {
      final parser = char('a').star();
      expectAll(firstSet(parser), ['a', '']);
    });
    test('optional', () {
      final parser = char('a').optional();
      expectAll(firstSet(parser), ['a', '']);
    });
    test('choice', () {
      final parser = char('a').or(char('b'));
      expectAll(firstSet(parser), ['a', 'b']);
    });
    test('sequence', () {
      final parser = char('a').seq(char('b'));
      expectAll(firstSet(parser), ['a']);
    });
    test('epsilon sequence', () {
      final parser = epsilon().seq(char('a'));
      expectAll(firstSet(parser), ['a']);
    });
    test('optional sequence', () {
      final parser = char('a').optional().seq(char('b'));
      expectAll(firstSet(parser), ['a', 'b']);
    });
  });
  group('iterable', () {
    test('single', () {
      final parser1 = lowercase();
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('nested', () {
      final parser3 = lowercase();
      final parser2 = parser3.star();
      final parser1 = parser2.flatten();
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('branched', () {
      final parser3 = lowercase();
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser3);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser3, parser2]);
    });
    test('duplicated', () {
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser2);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2]);
    });
    test('knot', () {
      final parser1 = undefined();
      parser1.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('looping', () {
      final parser1 = undefined();
      final parser2 = undefined();
      final parser3 = undefined();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
  });
  group('queries', () {
    group('isNullable', () {
      test('true', () {
        expect(isNullable(char('a').optional()), isTrue);
        expect(isNullable(char('a').optionalWith('b')), isTrue);
        expect(isNullable(char('a').star()), isTrue);
        expect(isNullable(char('a').starGreedy(char('b'))), isTrue);
        expect(isNullable(char('a').starLazy(char('b'))), isTrue);
        expect(isNullable(epsilon()), isTrue);
      });
      test('false', () {
        expect(isNullable(char('a')), isFalse);
        expect(isNullable(char('a').and()), isFalse);
        expect(isNullable(char('a').not()), isFalse);
        expect(isNullable(char('a').or(char('b'))), isFalse);
        expect(isNullable(char('a').plus()), isFalse);
        expect(isNullable(char('a').seq(char('b'))), isFalse);
        expect(isNullable(failure()), isFalse);
      });
    });
    group('isTerminal', () {
      test('true', () {
        expect(isTerminal(char('a')), isTrue);
        expect(isTerminal(epsilon()), isTrue);
        expect(isTerminal(failure()), isTrue);
        expect(isTerminal(string('a')), isTrue);
      });
      test('false', () {
        expect(isTerminal(char('a').and()), isFalse);
        expect(isTerminal(char('a').not()), isFalse);
        expect(isTerminal(char('a').or(char('b'))), isFalse);
        expect(isTerminal(char('a').plus()), isFalse);
        expect(isTerminal(char('a').seq(char('b'))), isFalse);
      });
    });
  });
  group('transform', () {
    test('copy', () {
      final input = lowercase().settable();
      final output = transformParser(input, <T>(parser) => parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.single, isNot(output.children.single));
    });
    test('root', () {
      final source = lowercase();
      final input = source;
      final target = uppercase();
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input, source);
      expect(output, target);
    });
    test('single', () {
      final source = lowercase();
      final input = source.settable();
      final target = uppercase();
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.children.single, source);
      expect(output.children.single, target);
    });
    test('double', () {
      final source = lowercase();
      final input = source & source;
      final target = uppercase();
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.isEqualTo(source & source), isTrue);
      expect(input.children.first, input.children.last);
      expect(output.isEqualTo(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
    test('loop (existing)', () {
      final inner = failure().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(outer, <T>(parser) {
        return parser;
      });
      expect(outer, isNot(output));
      expect(outer.isEqualTo(output), isTrue);
      final inputs = allParser(outer).toSet();
      final outputs = allParser(output).toSet();
      for (final input in inputs) {
        expect(outputs.contains(input), isFalse);
      }
      for (final output in outputs) {
        expect(inputs.contains(output), isFalse);
      }
    });
    test('loop (new)', () {
      final source = lowercase();
      final input = source;
      final inner = failure<String>().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(
          input,
          <T>(parser) =>
              source.isEqualTo(parser) ? outer as Parser<T> : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(output.isEqualTo(outer), isTrue);
    });
  });
  group('optimize', () {
    group('remove settables', () {
      test('basic settables', () {
        final input = lowercase().settable();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase()), isTrue);
      });
      test('nested settables', () {
        final input = lowercase().settable().star();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase().star()), isTrue);
      });
      test('double settables', () {
        final input = lowercase().settable().settable();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase()), isTrue);
      });
    });
    test('remove duplicate', () {
      final input = lowercase() & lowercase();
      final output = removeDuplicates(input);
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.first, isNot(input.children.last));
      expect(output.children.first, output.children.last);
    });
  });
}
