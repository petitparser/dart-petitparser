import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

void main() {
  group('iterator', () {
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
    test('basic', () {
      final lower = lowercase();
      final iterator = allParser(lower).iterator;
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
    test('copy', () {
      final input = lowercase().settable();
      final output = transformParser(input, (parser) => parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.single, isNot(output.children.single));
    });
    test('root', () {
      final source = lowercase();
      final input = source;
      final target = uppercase();
      final output = transformParser(
          input, (parser) => source.isEqualTo(parser) ? target : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input, source);
      expect(output, target);
    });
    test('single', () {
      final source = lowercase();
      final input = source.settable();
      final target = uppercase();
      final output = transformParser(
          input, (parser) => source.isEqualTo(parser) ? target : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.children.single, source);
      expect(output.children.single, target);
    });
    test('double', () {
      final source = lowercase();
      final input = source & source;
      final target = uppercase();
      final output = transformParser(
          input, (parser) => source.isEqualTo(parser) ? target : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.isEqualTo(source & source), isTrue);
      expect(input.children.first, input.children.last);
      expect(output.isEqualTo(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
    test('loop (existing)', () {
      final input = failure().settable().settable().settable();
      final SettableParser settable = input.children.single.children.single;
      settable.set(input);
      final output = transformParser(input, (parser) => parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      final inputs = allParser(input).toSet();
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
      final target = failure().settable().settable().settable();
      final SettableParser settable = target.children.single.children.single;
      settable.set(target);
      final output = transformParser(
          input, (parser) => source.isEqualTo(parser) ? target : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(output.isEqualTo(target), isTrue);
    });
  });
  group('optimize', () {
    test('remove settables', () {
      final input = lowercase().settable();
      final output = removeSettables(input);
      expect(output.isEqualTo(lowercase()), isTrue);
    });
    test('remove nested settables', () {
      final input = lowercase().settable().star();
      final output = removeSettables(input);
      expect(output.isEqualTo(lowercase().star()), isTrue);
    });
    test('remove double settables', () {
      final input = lowercase().settable().settable();
      final output = removeSettables(input);
      expect(output.isEqualTo(lowercase()), isTrue);
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
