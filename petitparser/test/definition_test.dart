import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

class ListGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(list).end();
  Parser list() => ref0(element) & char(',') & ref0(list) | ref0(element);
  Parser element() => digit().plus().flatten();
}

class ListParserDefinition extends ListGrammarDefinition {
  @override
  Parser element() => super.element().map((value) => int.parse(value));
}

class TokenizedListGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(list).end();
  Parser list() =>
      ref0(element) & ref1(token, char(',')) & ref0(list) | ref0(element);
  Parser element() => ref1(token, digit().plus());
  Parser token(Parser parser) => parser.flatten().trim();
}

class TypedReferencesGrammarDefinition extends GrammarDefinition {
  @override
  Parser<List<String>> start() => this.ref0(f0);
  Parser<List<String>> f0() => this.ref1(f1, 1);
  Parser<List<String>> f1(int a1) => this.ref2(f2, a1, 2);
  Parser<List<String>> f2(int a1, int a2) => this.ref3(f3, a1, a2, 3);
  Parser<List<String>> f3(int a1, int a2, int a3) =>
      this.ref4(f4, a1, a2, a3, 4);
  Parser<List<String>> f4(int a1, int a2, int a3, int a4) =>
      this.ref5(f5, a1, a2, a3, a4, 5);
  Parser<List<String>> f5(int a1, int a2, int a3, int a4, int a5) => [
        a1.toString().toParser(),
        a2.toString().toParser(),
        a3.toString().toParser(),
        a4.toString().toParser(),
        a5.toString().toParser(),
      ].toSequenceParser();
}

class UntypedReferencesGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => this.ref0(f0);
  Parser f0() => this.ref1(f1, 1);
  Parser f1(int a1) => this.ref2(f2, a1, 2);
  Parser f2(int a1, int a2) => this.ref3(f3, a1, a2, 3);
  Parser f3(int a1, int a2, int a3) => this.ref4(f4, a1, a2, a3, 4);
  Parser f4(int a1, int a2, int a3, int a4) => this.ref5(f5, a1, a2, a3, a4, 5);
  Parser f5(int a1, int a2, int a3, int a4, int a5) => [
        a1.toString().toParser(),
        a2.toString().toParser(),
        a3.toString().toParser(),
        a4.toString().toParser(),
        a5.toString().toParser(),
      ].toSequenceParser();
}

// ignore_for_file: deprecated_member_use_from_same_package
class DeprecatedUntypedReferencesGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => this.ref(f0);
  Parser f0() => this.ref(f1, 1);
  Parser f1(int a1) => this.ref(f2, a1, 2);
  Parser f2(int a1, int a2) => this.ref(f3, a1, a2, 3);
  Parser f3(int a1, int a2, int a3) => this.ref(f4, a1, a2, a3, 4);
  Parser f4(int a1, int a2, int a3, int a4) => this.ref(f5, a1, a2, a3, a4, 5);
  Parser f5(int a1, int a2, int a3, int a4, int a5) => [
        a1.toString().toParser(),
        a2.toString().toParser(),
        a3.toString().toParser(),
        a4.toString().toParser(),
        a5.toString().toParser(),
      ].toSequenceParser();
}

class BuggedGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => epsilon();

  Parser directRecursion1() => ref0(directRecursion1);

  Parser indirectRecursion1() => ref0(indirectRecursion2);
  Parser indirectRecursion2() => ref0(indirectRecursion3);
  Parser indirectRecursion3() => ref0(indirectRecursion1);

  Parser delegation1() => ref0(delegation2);
  Parser delegation2() => ref0(delegation3);
  Parser delegation3() => epsilon();
}

class LambdaGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(expression).end();
  Parser expression() => ref0(variable) | ref0(abstraction) | ref0(application);

  Parser variable() => (letter() & word().star()).flatten().trim();
  Parser abstraction() =>
      token('\\') & ref0(variable) & token('.') & ref0(expression);
  Parser application() =>
      token('(') & ref0(expression) & ref0(expression) & token(')');

  Parser token(String value) => char(value).trim();
}

class ExpressionGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(terms).end();
  Parser terms() => ref0(addition) | ref0(factors);

  Parser addition() => ref0(factors).separatedBy(token(char('+') | char('-')));
  Parser factors() => ref0(multiplication) | ref0(power);

  Parser multiplication() =>
      ref0(power).separatedBy(token(char('*') | char('/')));
  Parser power() => ref0(primary).separatedBy(char('^').trim());

  Parser primary() => ref0(number) | ref0(parentheses);
  Parser number() => token(char('-').optional() &
      digit().plus() &
      (char('.') & digit().plus()).optional());

  Parser parentheses() => token('(') & ref0(terms) & token(')');
  Parser token(Object value) {
    if (value is String) {
      return char(value).trim();
    } else if (value is Parser) {
      return value.flatten().trim();
    }
    throw ArgumentError.value(value, 'unable to parse');
  }
}

void main() {
  group('reference & resolve', () {
    Parser<String> numberToken() => (char('-').optional() &
            digit().plus() &
            (char('.') & digit().plus()).optional())
        .flatten()
        .trim();
    Parser<num> number() => ref0(numberToken).map(num.parse);
    Parser<List<num>> numberList([String separator = ',']) => ref0(number)
        .separatedBy(separator.toParser(), includeSeparators: false);

    test('reference without parameters', () {
      final firstReference = ref0(number);
      final secondReference = ref0(number);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different production', () {
      final firstReference = ref0(number);
      final secondReference = ref0(numberToken);
      expect(firstReference, isNot(same(secondReference)));
      // ignore: unrelated_type_equality_checks
      expect(firstReference == secondReference, isFalse);
    });
    test('reference with same parameters', () {
      final firstReference = ref1(numberList, ',');
      final secondReference = ref1(numberList, ',');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different parameters', () {
      final firstReference = ref1(numberList, ',');
      final secondReference = ref1(numberList, ';');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
    });
    test('reference unsupported methods', () {
      final reference = ref0(number);
      expect(() => reference.copy(), throwsUnsupportedError);
      expect(() => reference.parse('0'), throwsUnsupportedError);
      expect(() => reference.fastParseOn('0', 0), throwsUnsupportedError);
    });
    test('references typed', () {
      Parser<List<String>> f9(int a1, int a2, int a3, int a4, int a5, int a6,
              int a7, int a8, int a9) =>
          [a1, a2, a3, a4, a5, a6, a7, a8, a9]
              .map((value) => value.toString().toParser())
              .toSequenceParser();
      Parser<List<String>> f8(
              int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8) =>
          ref9(f9, a1, a2, a3, a4, a5, a6, a7, a8, 9);
      Parser<List<String>> f7(
              int a1, int a2, int a3, int a4, int a5, int a6, int a7) =>
          ref8(f8, a1, a2, a3, a4, a5, a6, a7, 8);
      Parser<List<String>> f6(int a1, int a2, int a3, int a4, int a5, int a6) =>
          ref7(f7, a1, a2, a3, a4, a5, a6, 7);
      Parser<List<String>> f5(int a1, int a2, int a3, int a4, int a5) =>
          ref6(f6, a1, a2, a3, a4, a5, 6);
      Parser<List<String>> f4(int a1, int a2, int a3, int a4) =>
          ref5(f5, a1, a2, a3, a4, 5);
      Parser<List<String>> f3(int a1, int a2, int a3) =>
          ref4(f4, a1, a2, a3, 4);
      Parser<List<String>> f2(int a1, int a2) => ref3(f3, a1, a2, 3);
      Parser<List<String>> f1(int a1) => ref2(f2, a1, 2);
      Parser<List<String>> f0() => ref1(f1, 1);
      Parser<List<String>> start() => ref0(f0);
      expect(
          resolve(start()), isParseSuccess('123456789', '123456789'.split('')));
    });
    test('references untyped', () {
      Parser<List<String>> f9(int a1, int a2, int a3, int a4, int a5, int a6,
              int a7, int a8, int a9) =>
          [a1, a2, a3, a4, a5, a6, a7, a8, a9]
              .map((value) => value.toString().toParser())
              .toSequenceParser();
      Parser<List<String>> f8(
              int a1, int a2, int a3, int a4, int a5, int a6, int a7, int a8) =>
          ref(f9, a1, a2, a3, a4, a5, a6, a7, a8, 9);
      Parser<List<String>> f7(
              int a1, int a2, int a3, int a4, int a5, int a6, int a7) =>
          ref(f8, a1, a2, a3, a4, a5, a6, a7, 8);
      Parser<List<String>> f6(int a1, int a2, int a3, int a4, int a5, int a6) =>
          ref(f7, a1, a2, a3, a4, a5, a6, 7);
      Parser<List<String>> f5(int a1, int a2, int a3, int a4, int a5) =>
          ref(f6, a1, a2, a3, a4, a5, 6);
      Parser<List<String>> f4(int a1, int a2, int a3, int a4) =>
          ref(f5, a1, a2, a3, a4, 5);
      Parser<List<String>> f3(int a1, int a2, int a3) => ref(f4, a1, a2, a3, 4);
      Parser<List<String>> f2(int a1, int a2) => ref(f3, a1, a2, 3);
      Parser<List<String>> f1(int a1) => ref(f2, a1, 2);
      Parser<List<String>> f0() => ref(f1, 1);
      Parser<List<String>> start() => ref(f0);
      expect(
          resolve(start()), isParseSuccess('123456789', '123456789'.split('')));
    });
    test('resolved parser', () {
      expect(resolve(number()), isParseSuccess('1', 1));
      expect(resolve(numberList()), isParseSuccess('1,2', [1, 2]));
    });
    test('resolved parser with arguments', () {
      expect(resolve(numberList()), isParseSuccess('1,2', [1, 2]));
      expect(resolve(numberList(';')), isParseSuccess('3;4;5', [3, 4, 5]));
    });
    test('direct recursion', () {
      Parser<String> create() => ref0(create);
      expect(() => resolve(create()), throwsStateError);
    });
    // test('indirect recursion', () {
    //   Parser<String> create1() => ref0(create2);
    //   Parser<String> create2() => ref0(create3);
    //   Parser<String> create3() => ref0(create1);
    //   expect(() => resolve(create1()), throwsStateError);
    // });
    test('reference', () {
      Parser<List<num>> list() => [
            (ref0(number) & char(',') & ref0(list))
                .map((values) => <num>[values[0], ...values[2]]),
            ref0(number).map((value) => [value]),
          ].toChoiceParser();
      final parser = resolve<List<num>>(list());
      expect(parser, isParseSuccess('1', [1]));
      expect(parser, isParseSuccess('1,2', [1, 2]));
      expect(parser, isParseSuccess('1,2,2', [1, 2, 2]));
    });
  });
  group('definition', () {
    final grammarDefinition = ListGrammarDefinition();
    final parserDefinition = ListParserDefinition();
    final tokenDefinition = TokenizedListGrammarDefinition();
    final typedReferenceDefinition = TypedReferencesGrammarDefinition();
    final untypedReferenceDefinition = UntypedReferencesGrammarDefinition();
    final deprecatedUntypedReferenceDefinition =
        UntypedReferencesGrammarDefinition();
    final buggedDefinition = BuggedGrammarDefinition();

    test('reference without parameters', () {
      final firstReference = grammarDefinition.ref0(grammarDefinition.start);
      final secondReference = grammarDefinition.ref0(grammarDefinition.start);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different production', () {
      final firstReference = grammarDefinition.ref0(grammarDefinition.start);
      final secondReference = grammarDefinition.ref0(grammarDefinition.element);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
    });
    test('reference with same parameters', () {
      final firstReference =
          typedReferenceDefinition.ref1(typedReferenceDefinition.f1, 42);
      final secondReference =
          typedReferenceDefinition.ref1(typedReferenceDefinition.f1, 42);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different parameters', () {
      final firstReference =
          typedReferenceDefinition.ref1(typedReferenceDefinition.f1, 42);
      final secondReference =
          typedReferenceDefinition.ref1(typedReferenceDefinition.f1, 43);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
    });
    test('reference with multiple arguments', () {
      final parser = typedReferenceDefinition.build();
      expect(parser, isParseSuccess('12345', ['1', '2', '3', '4', '5']));
    });
    test('reference with multiple arguments (untyped)', () {
      final parser = untypedReferenceDefinition.build();
      expect(parser, isParseSuccess('12345', ['1', '2', '3', '4', '5']));
    });
    test('reference with multiple arguments (untyped, deprecated)', () {
      final parser = deprecatedUntypedReferenceDefinition.build();
      expect(parser, isParseSuccess('12345', ['1', '2', '3', '4', '5']));
    });
    test('invalid building', () {
      expect(() => grammarDefinition.build(arguments: [1, 2, 3]),
          throwsStateError);
    });
    test('reference unsupported methods', () {
      final reference = grammarDefinition.ref0(grammarDefinition.start);
      expect(() => reference.copy(), throwsUnsupportedError);
      expect(() => reference.parse(''), throwsUnsupportedError);
    });
    test('grammar', () {
      final parser = grammarDefinition.build();
      expect(parser, isParseSuccess('1,2', ['1', ',', '2']));
      expect(
          parser,
          isParseSuccess('1,2,3', [
            '1',
            ',',
            ['2', ',', '3']
          ]));
    });
    test('parser', () {
      final parser = parserDefinition.build();
      expect(parser, isParseSuccess('1,2', [1, ',', 2]));
      expect(
          parser,
          isParseSuccess('1,2,3', [
            1,
            ',',
            [2, ',', 3]
          ]));
    });
    test('token', () {
      final parser = tokenDefinition.build();
      expect(parser, isParseSuccess('1, 2', ['1', ',', '2']));
      expect(
          parser,
          isParseSuccess('1, 2, 3', [
            '1',
            ',',
            ['2', ',', '3']
          ]));
    });
    test('direct recursion', () {
      expect(
          () =>
              buggedDefinition.build(start: buggedDefinition.directRecursion1),
          throwsStateError);
    });
    test('indirect recursion', () {
      expect(
          () => buggedDefinition.build(
              start: buggedDefinition.indirectRecursion1),
          throwsStateError);
      expect(
          () => buggedDefinition.build(
              start: buggedDefinition.indirectRecursion2),
          throwsStateError);
      expect(
          () => buggedDefinition.build(
              start: buggedDefinition.indirectRecursion3),
          throwsStateError);
    });
    test('delegation', () {
      expect(
          buggedDefinition.build(start: buggedDefinition.delegation1)
              is EpsilonParser,
          isTrue);
      expect(
          buggedDefinition.build(start: buggedDefinition.delegation2)
              is EpsilonParser,
          isTrue);
      expect(
          buggedDefinition.build(start: buggedDefinition.delegation3)
              is EpsilonParser,
          isTrue);
    });
    test('lambda example', () {
      final definition = LambdaGrammarDefinition();
      final parser = definition.build();
      expect(parser.accept('x'), isTrue);
      expect(parser.accept('xy'), isTrue);
      expect(parser.accept('x12'), isTrue);
      expect(parser.accept('\\x.y'), isTrue);
      expect(parser.accept('\\x.\\y.z'), isTrue);
      expect(parser.accept('(x x)'), isTrue);
      expect(parser.accept('(x y)'), isTrue);
      expect(parser.accept('(x (y z))'), isTrue);
      expect(parser.accept('((x y) z)'), isTrue);
    });
    test('expression example', () {
      final definition = ExpressionGrammarDefinition();
      final parser = definition.build();
      expect(parser.accept('1'), isTrue);
      expect(parser.accept('12'), isTrue);
      expect(parser.accept('1.23'), isTrue);
      expect(parser.accept('-12.3'), isTrue);
      expect(parser.accept('1 + 2'), isTrue);
      expect(parser.accept('1 + 2 + 3'), isTrue);
      expect(parser.accept('1 - 2'), isTrue);
      expect(parser.accept('1 - 2 - 3'), isTrue);
      expect(parser.accept('1 * 2'), isTrue);
      expect(parser.accept('1 * 2 * 3'), isTrue);
      expect(parser.accept('1 / 2'), isTrue);
      expect(parser.accept('1 / 2 / 3'), isTrue);
      expect(parser.accept('1 ^ 2'), isTrue);
      expect(parser.accept('1 ^ 2 ^ 3'), isTrue);
      expect(parser.accept('1 + (2 * 3)'), isTrue);
      expect(parser.accept('(1 + 2) * 3'), isTrue);
    });
  });
}
