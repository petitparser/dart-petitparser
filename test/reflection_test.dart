library petitparser.test.reflection_test;

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

void main() {
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
    test('copy', () {
      var input = lowercase().settable();
      var output = transformParser(input, (parser) => parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.single, isNot(output.children.single));
    });
    test('root', () {
      var source = lowercase();
      var input = source;
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.isEqualTo(parser) ? target : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input, source);
      expect(output, target);
    });
    test('single', () {
      var source = lowercase();
      var input = source.settable();
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.isEqualTo(parser) ? target : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.children.single, source);
      expect(output.children.single, target);
    });
    test('double', () {
      var source = lowercase();
      var input = source & source;
      var target = uppercase();
      var output = transformParser(input, (parser) {
        return source.isEqualTo(parser) ? target : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.isEqualTo(source & source), isTrue);
      expect(input.children.first, input.children.last);
      expect(output.isEqualTo(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
    test('loop (existing)', () {
      var input = failure().settable().settable().settable();
      (input.children.single.children.single as SettableParser).set(input);
      var output = transformParser(input, (parser) {
        return parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      var inputs = allParser(input).toSet();
      var outputs = allParser(output).toSet();
      inputs.forEach((each) => expect(outputs.contains(each), isFalse));
      outputs.forEach((each) => expect(inputs.contains(each), isFalse));
    });
    test('loop (new)', () {
      var source = lowercase();
      var input = source;
      var target = failure().settable().settable().settable();
      (target.children.single.children.single as SettableParser).set(target);
      var output = transformParser(input, (parser) {
        return source.isEqualTo(parser) ? target : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(output.isEqualTo(target), isTrue);
    });
  });
  group('optimize', () {
    test('remove setables', () {
      var input = lowercase().settable();
      var output = removeSettables(input);
      expect(output.isEqualTo(lowercase()), isTrue);
    });
    test('remove nested setables', () {
      var input = lowercase().settable().star();
      var output = removeSettables(input);
      expect(output.isEqualTo(lowercase().star()), isTrue);
    });
    test('remove double setables', () {
      var input = lowercase().settable().settable();
      var output = removeSettables(input);
      expect(output.isEqualTo(lowercase()), isTrue);
    });
    test('remove duplicate', () {
      var input = lowercase() & lowercase();
      var output = removeDuplicates(input);
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.first, isNot(input.children.last));
      expect(output.children.first, output.children.last);
    });
  });
}
