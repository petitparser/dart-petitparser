import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

class ListGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(list).end();
  Parser list() => ref(element) & char(',') & ref(list) | ref(element);
  Parser element() => digit().plus().flatten();
}

class ListParserDefinition extends ListGrammarDefinition {
  Parser element() => super.element().map((value) => int.parse(value));
}

class TokenizedListGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(list).end();
  Parser list() =>
      ref(element) & ref(token, char(',')) & ref(list) | ref(element);
  Parser element() => ref(token, digit().plus());
  Parser token(Parser parser) => parser.flatten().trim();
}

class ReferencesGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(f0);
  Parser f0() => ref(f1, 1);
  Parser f1(int a1) => ref(f2, a1, 2);
  Parser f2(int a1, int a2) => ref(f3, a1, a2, 3);
  Parser f3(int a1, int a2, int a3) => [
        a1.toString().toParser(),
        a2.toString().toParser(),
        a3.toString().toParser(),
      ].toSequenceParser();
}

class BuggedGrammarDefinition extends GrammarDefinition {
  Parser start() => epsilon();

  Parser directRecursion1() => ref(directRecursion1);

  Parser indirectRecursion1() => ref(indirectRecursion2);
  Parser indirectRecursion2() => ref(indirectRecursion3);
  Parser indirectRecursion3() => ref(indirectRecursion1);

  Parser delegation1() => ref(delegation2);
  Parser delegation2() => ref(delegation3);
  Parser delegation3() => epsilon();
}

class LambdaGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(expression).end();
  Parser expression() => ref(variable) | ref(abstraction) | ref(application);

  Parser variable() => (letter() & word().star()).flatten().trim();
  Parser abstraction() =>
      token('\\') & ref(variable) & token('.') & ref(expression);
  Parser application() =>
      token('(') & ref(expression) & ref(expression) & token(')');

  Parser token(String value) => char(value).trim();
}

class ExpressionGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(terms).end();
  Parser terms() => ref(addition) | ref(factors);

  Parser addition() => ref(factors).separatedBy(token(char('+') | char('-')));
  Parser factors() => ref(multiplication) | ref(power);

  Parser multiplication() =>
      ref(power).separatedBy(token(char('*') | char('/')));
  Parser power() => ref(primary).separatedBy(char('^').trim());

  Parser primary() => ref(number) | ref(parentheses);
  Parser number() => token(char('-').optional() &
      digit().plus() &
      (char('.') & digit().plus()).optional());

  Parser parentheses() => token('(') & ref(terms) & token(')');
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
    final firstReference = grammarDefinition.ref(grammarDefinition.start);
    final secondReference = grammarDefinition.ref(grammarDefinition.start);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isTrue);
  });
  test('reference with different production', () {
    final firstReference = grammarDefinition.ref(grammarDefinition.start);
    final secondReference = grammarDefinition.ref(grammarDefinition.element);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isFalse);
  });
  test('reference with same parameters', () {
    final firstReference = referenceDefinition.ref(referenceDefinition.f1, 42);
    final secondReference = referenceDefinition.ref(referenceDefinition.f1, 42);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isTrue);
  });
  test('reference with different parameters', () {
    final firstReference = referenceDefinition.ref(referenceDefinition.f1, 42);
    final secondReference = referenceDefinition.ref(referenceDefinition.f1, 43);
    expect(firstReference, isNot(same(secondReference)));
    expect(firstReference == secondReference, isFalse);
  });
  test('reference with multiple arguments', () {
    final parser = referenceDefinition.build();
    expectSuccess(parser, '123', ['1', '2', '3']);
  });
  test('reference unsupported methods', () {
    final reference = grammarDefinition.ref(grammarDefinition.start);
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
