import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

class ListGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(list).end();
  Parser list() => ref0(element) & char(',') & ref0(list) | ref0(element);
  Parser element() => digit().plus().flatten();
}

class ListParserDefinition extends ListGrammarDefinition {
  Parser element() => super.element().map((value) => int.parse(value));
}

class TokenizedListGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(list).end();
  Parser list() =>
      ref0(element) & ref1(token, char(',')) & ref0(list) | ref0(element);
  Parser element() => ref1(token, digit().plus());
  Parser token(Parser parser) => parser.flatten().trim();
}

class ReferencesGrammarDefinition extends GrammarDefinition {
  Parser start() => ref0(f0);
  Parser f0() => ref1(f1, 1);
  Parser f1(int a1) => ref2(f2, a1, 2);
  Parser f2(int a1, int a2) => ref3(f3, a1, a2, 3);
  Parser f3(int a1, int a2, int a3) => [
        a1.toString().toParser(),
        a2.toString().toParser(),
        a3.toString().toParser(),
      ].toSequenceParser();
}

class BuggedGrammarDefinition extends GrammarDefinition {
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
  final grammarDefinition = ListGrammarDefinition();
  final parserDefinition = ListParserDefinition();
  final tokenDefinition = TokenizedListGrammarDefinition();
  final referenceDefinition = ReferencesGrammarDefinition();
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
    final firstReference = referenceDefinition.ref1(referenceDefinition.f1, 42);
    final secondReference =
        referenceDefinition.ref1(referenceDefinition.f1, 42);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isTrue);
  });
  test('reference with different parameters', () {
    final firstReference = referenceDefinition.ref1(referenceDefinition.f1, 42);
    final secondReference =
        referenceDefinition.ref1(referenceDefinition.f1, 43);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isFalse);
  });
  test('reference with multiple arguments', () {
    final parser = referenceDefinition.build();
    expectSuccess(parser, '123', ['1', '2', '3']);
  });
  test('reference unsupported methods', () {
    final reference = grammarDefinition.ref0(grammarDefinition.start);
    expect(() => reference.copy(), throwsUnsupportedError);
    expect(() => reference.parse(''), throwsUnsupportedError);
  });
  test('grammar', () {
    final parser = grammarDefinition.build();
    expectSuccess(parser, '1,2', ['1', ',', '2']);
    expectSuccess(parser, '1,2,3', [
      '1',
      ',',
      ['2', ',', '3']
    ]);
  });
  test('parser', () {
    final parser = parserDefinition.build();
    expectSuccess(parser, '1,2', [1, ',', 2]);
    expectSuccess(parser, '1,2,3', [
      1,
      ',',
      [2, ',', 3]
    ]);
  });
  test('parser wrapped', () {
    final parser = GrammarParser(parserDefinition);
    expectSuccess(parser, '1,2', [1, ',', 2]);
    expectSuccess(parser, '1,2,3', [
      1,
      ',',
      [2, ',', 3]
    ]);
  });
  test('token', () {
    final parser = tokenDefinition.build();
    expectSuccess(parser, '1, 2', ['1', ',', '2']);
    expectSuccess(parser, '1, 2, 3', [
      '1',
      ',',
      ['2', ',', '3']
    ]);
  });
  test('direct recursion', () {
    expect(
        () => buggedDefinition.build(start: buggedDefinition.directRecursion1),
        throwsStateError);
  });
  test('indirect recursion', () {
    expect(
        () =>
            buggedDefinition.build(start: buggedDefinition.indirectRecursion1),
        throwsStateError);
    expect(
        () =>
            buggedDefinition.build(start: buggedDefinition.indirectRecursion2),
        throwsStateError);
    expect(
        () =>
            buggedDefinition.build(start: buggedDefinition.indirectRecursion3),
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
}
