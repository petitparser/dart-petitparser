library petitparser.test.core_test;

import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

void expectSuccess(Parser parser, String input, Object expected,
    [int position]) {
  final result = parser.parse(input);
  expect(result.isSuccess, isTrue,
      reason: 'Expected Result.isSuccess to be true.');
  expect(result.isFailure, isFalse,
      reason: 'Expected Result.isFailure to be false.');
  expect(result.value, expected,
      reason: 'Expected Result.value to match $expected.');
  expect(result.position, position ?? input.length,
      reason: 'Expected Result.position to match ${position ?? input.length}.');
  expect(parser.fastParseOn(input, 0), result.position,
      reason: 'Expected fast parsed result to succeed at same position.');
}

void expectFailure(Parser parser, String input,
    [int position = 0, String message]) {
  final result = parser.parse(input);
  expect(result.isFailure, isTrue,
      reason: 'Expected Result.isFailure to be true.');
  expect(result.isSuccess, isFalse,
      reason: 'Expected Result.isSuccess to be false.');
  expect(result.position, position,
      reason: 'Expected Result.position to match $position.');
  if (message != null) {
    expect(result.message, message,
        reason: 'Expected Result.message to match $message.');
  }
  expect(parser.fastParseOn(input, 0), -1,
      reason: 'Expected fast parse to fail.');
}

class ListGrammarDefinition extends GrammarDefinition {
  start() => ref(list).end();
  list() => ref(element) & char(',') & ref(list) | ref(element);
  element() => digit().plus().flatten();
}

class ListParserDefinition extends ListGrammarDefinition {
  element() => super.element().map(int.parse);
}

class TokenizedListGrammarDefinition extends GrammarDefinition {
  start() => ref(list).end();
  list() => ref(element) & ref(token, char(',')) & ref(list) | ref(element);
  element() => ref(token, digit().plus());
  token(p) => p.flatten().trim();
}

class BuggedGrammarDefinition extends GrammarDefinition {
  start() => epsilon();

  directRecursion1() => ref(directRecursion1);

  indirectRecursion1() => ref(indirectRecursion2);
  indirectRecursion2() => ref(indirectRecursion3);
  indirectRecursion3() => ref(indirectRecursion1);

  delegation1() => ref(delegation2);
  delegation2() => ref(delegation3);
  delegation3() => epsilon();
}

class LambdaGrammarDefinition extends GrammarDefinition {
  start() => ref(expression).end();
  expression() => ref(variable) | ref(abstraction) | ref(application);

  variable() => (letter() & word().star()).flatten().trim();
  abstraction() => token('\\') & ref(variable) & token('.') & ref(expression);
  application() => token('(') & ref(expression) & ref(expression) & token(')');

  token(value) => char(value).trim();
}

class ExpressionGrammarDefinition extends GrammarDefinition {
  start() => ref(terms).end();
  terms() => ref(addition) | ref(factors);

  addition() => ref(factors).separatedBy(token(char('+') | char('-')));
  factors() => ref(multiplication) | ref(power);

  multiplication() => ref(power).separatedBy(token(char('*') | char('/')));
  power() => ref(primary).separatedBy(char('^').trim());

  primary() => ref(number) | ref(parentheses);
  number() => token(char('-').optional() &
      digit().plus() &
      (char('.') & digit().plus()).optional());

  parentheses() => token('(') & ref(terms) & token(')');
  token(value) => value is String ? char(value).trim() : value.flatten().trim();
}

main() {
  group('parsers', () {
    test('and()', () {
      final parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', 0, '"a" expected');
      expectFailure(parser, '');
    });
    test('or() operator', () {
      final parser = char('a') | char('b');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('or() of two', () {
      final parser = char('a').or(char('b'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('or() of three', () {
      final parser = char('a').or(char('b')).or(char('c'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd');
      expectFailure(parser, '');
    });
    test('or() empty', () {
      expect(() => ChoiceParser([]), throwsArgumentError);
    });
    test('position()', () {
      final parser = (any().star() & position()).pick(-1);
      expectSuccess(parser, '', 0);
      expectSuccess(parser, 'a', 1);
      expectSuccess(parser, 'aa', 2);
      expectSuccess(parser, 'aaa', 3);
    });
    test('end()', () {
      final parser = char('a').end();
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'aa', 1, 'end of input expected');
    });
    test('epsilon()', () {
      final parser = epsilon();
      expectSuccess(parser, '', null);
      expectSuccess(parser, 'a', null, 0);
    });
    test('failure()', () {
      final parser = failure('failure');
      expectFailure(parser, '', 0, 'failure');
      expectFailure(parser, 'a', 0, 'failure');
    });
    test('flatten()', () {
      final parser = digit().repeat(2, unbounded).flatten();
      expectFailure(parser, '', 0, 'digit expected');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, '1', 1, 'digit expected');
      expectFailure(parser, '1a', 1, 'digit expected');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('flatten()', () {
      final parser = digit().repeat(2, unbounded).flatten('gimme a number');
      expectFailure(parser, '', 0, 'gimme a number');
      expectFailure(parser, 'a', 0, 'gimme a number');
      expectFailure(parser, '1', 0, 'gimme a number');
      expectFailure(parser, '1a', 0, 'gimme a number');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('token()', () {
      final parser = digit().plus().token();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      final token = parser.parse('123').value;
      expect(token.value, ['1', '2', '3']);
      expect(token.buffer, '123');
      expect(token.start, 0);
      expect(token.stop, 3);
      expect(token.input, '123');
      expect(token.length, 3);
      expect(token.line, 1);
      expect(token.column, 1);
      expect(token.toString(), 'Token[1:1]: [1, 2, 3]');
    });
    test('map()', () {
      final parser = digit().map((each) {
        return each.codeUnitAt(0) - '0'.codeUnitAt(0);
      });
      expectSuccess(parser, '1', 1);
      expectSuccess(parser, '4', 4);
      expectSuccess(parser, '9', 9);
      expectFailure(parser, '');
      expectFailure(parser, 'a');
    });
    test('pick(1)', () {
      final parser = digit().seq(letter()).pick(1);
      expectSuccess(parser, '1a', 'a');
      expectSuccess(parser, '2b', 'b');
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('pick(-1)', () {
      final parser = digit().seq(letter()).pick(-1);
      expectSuccess(parser, '1a', 'a');
      expectSuccess(parser, '2b', 'b');
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('permute([1, 0])', () {
      final parser = digit().seq(letter()).permute([1, 0]);
      expectSuccess(parser, '1a', ['a', '1']);
      expectSuccess(parser, '2b', ['b', '2']);
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('permute([-1, 0])', () {
      final parser = digit().seq(letter()).permute([-1, 0]);
      expectSuccess(parser, '1a', ['a', '1']);
      expectSuccess(parser, '2b', ['b', '2']);
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('not()', () {
      final parser = char('a').not('not "a" expected');
      expectFailure(parser, 'a', 0, 'not "a" expected');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('neg()', () {
      final parser = digit().neg('no digit expected');
      expectFailure(parser, '1', 0, 'no digit expected');
      expectFailure(parser, '9', 0, 'no digit expected');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('optional()', () {
      final parser = char('a').optional();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('plus()', () {
      final parser = char('a').plus();
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('plusGreedy()', () {
      final parser = word().plusGreedy(digit());
      expectFailure(parser, '', 0, 'letter or digit expected');
      expectFailure(parser, 'a', 1, 'digit expected');
      expectFailure(parser, 'ab', 1, 'digit expected');
      expectFailure(parser, '1', 1, 'digit expected');
      expectSuccess(parser, 'a1', ['a'], 1);
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '12', ['1'], 1);
      expectSuccess(parser, 'a12', ['a', '1'], 2);
      expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
      expectSuccess(parser, '123', ['1', '2'], 2);
      expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
      expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1', '2'], 5);
    });
    test('plusLazy()', () {
      final parser = word().plusLazy(digit());
      expectFailure(parser, '');
      expectFailure(parser, 'a', 1, 'digit expected');
      expectFailure(parser, 'ab', 2, 'digit expected');
      expectFailure(parser, '1', 1, 'digit expected');
      expectSuccess(parser, 'a1', ['a'], 1);
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '12', ['1'], 1);
      expectSuccess(parser, 'a12', ['a'], 1);
      expectSuccess(parser, 'ab12', ['a', 'b'], 2);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '123', ['1'], 1);
      expectSuccess(parser, 'a123', ['a'], 1);
      expectSuccess(parser, 'ab123', ['a', 'b'], 2);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
    });
    test('times()', () {
      final parser = char('a').times(2);
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'a', 1, '"a" expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('repeat()', () {
      final parser = char('a').repeat(2, 3);
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'a', 1, '"a" expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
    });
    test('repeat() exact', () {
      final parser = char('a').repeat(2);
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'a', 1, '"a" expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('repeat() unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = char('a').repeat(2, unbounded);
      expectSuccess(parser, input.join(), input);
    });
    test('repeat() errorous', () {
      expect(() => char('a').repeat(-1, 1), throwsArgumentError);
      expect(() => char('a').repeat(2, 1), throwsArgumentError);
    });
    test('repeatGreedy()', () {
      final parser = word().repeatGreedy(digit(), 2, 4);
      expectFailure(parser, '', 0, 'letter or digit expected');
      expectFailure(parser, 'a', 1, 'letter or digit expected');
      expectFailure(parser, 'ab', 2, 'digit expected');
      expectFailure(parser, 'abc', 2, 'digit expected');
      expectFailure(parser, 'abcd', 2, 'digit expected');
      expectFailure(parser, 'abcde', 2, 'digit expected');
      expectFailure(parser, '1', 1, 'letter or digit expected');
      expectFailure(parser, 'a1', 2, 'digit expected');
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, 'abcd1', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde1', 2, 'digit expected');
      expectFailure(parser, '12', 2, 'digit expected');
      expectSuccess(parser, 'a12', ['a', '1'], 2);
      expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
      expectSuccess(parser, 'abcd12', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde12', 2, 'digit expected');
      expectSuccess(parser, '123', ['1', '2'], 2);
      expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
      expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1'], 4);
      expectSuccess(parser, 'abcd123', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde123', 2, 'digit expected');
    });
    test('repeatGreedy() unbounded', () {
      final inputLetter = List.filled(100000, 'a');
      final inputDigit = List.filled(100000, '1');
      final parser = word().repeatGreedy(digit(), 2, unbounded);
      expectSuccess(
          parser, '${inputLetter.join()}1', inputLetter, inputLetter.length);
      expectSuccess(
          parser, '${inputDigit.join()}1', inputDigit, inputDigit.length);
    });
    test('repeatLazy()', () {
      final parser = word().repeatLazy(digit(), 2, 4);
      expectFailure(parser, '', 0, 'letter or digit expected');
      expectFailure(parser, 'a', 1, 'letter or digit expected');
      expectFailure(parser, 'ab', 2, 'digit expected');
      expectFailure(parser, 'abc', 3, 'digit expected');
      expectFailure(parser, 'abcd', 4, 'digit expected');
      expectFailure(parser, 'abcde', 4, 'digit expected');
      expectFailure(parser, '1', 1, 'letter or digit expected');
      expectFailure(parser, 'a1', 2, 'digit expected');
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, 'abcd1', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde1', 4, 'digit expected');
      expectFailure(parser, '12', 2, 'digit expected');
      expectSuccess(parser, 'a12', ['a', '1'], 2);
      expectSuccess(parser, 'ab12', ['a', 'b'], 2);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
      expectSuccess(parser, 'abcd12', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde12', 4, 'digit expected');
      expectSuccess(parser, '123', ['1', '2'], 2);
      expectSuccess(parser, 'a123', ['a', '1'], 2);
      expectSuccess(parser, 'ab123', ['a', 'b'], 2);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
      expectSuccess(parser, 'abcd123', ['a', 'b', 'c', 'd'], 4);
      expectFailure(parser, 'abcde123', 4, 'digit expected');
    });
    test('repeatLazy() unbounded', () {
      final input = List.filled(100000, 'a');
      final parser = word().repeatLazy(digit(), 2, unbounded);
      expectSuccess(parser, '${input.join()}1111', input, input.length);
    });
    test('separatedBy()', () {
      final parser = char('a').separatedBy(char('b'));
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a'], 5);
    });
    test('separatedBy() without separators', () {
      final parser = char('a').separatedBy(char('b'), includeSeparators: false);
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'a']);
      expectSuccess(parser, 'abab', ['a', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'a', 'a'], 5);
    });
    test('separatedBy() separator at end', () {
      final parser =
          char('a').separatedBy(char('b'), optionalSeparatorAtEnd: true);
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a', 'b']);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a', 'b']);
    });
    test('separatedBy() without separators & separator at end', () {
      final parser = char('a').separatedBy(char('b'),
          includeSeparators: false, optionalSeparatorAtEnd: true);
      expectFailure(parser, '', 0, '"a" expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a']);
      expectSuccess(parser, 'aba', ['a', 'a']);
      expectSuccess(parser, 'abab', ['a', 'a']);
      expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'a', 'a']);
    });
    test('seq() operator', () {
      final parser = char('a') & char('b');
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('seq() of two', () {
      final parser = char('a').seq(char('b'));
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('seq() of three', () {
      final parser = char('a').seq(char('b')).seq(char('c'));
      expectSuccess(parser, 'abc', ['a', 'b', 'c']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
      expectFailure(parser, 'ab', 2);
      expectFailure(parser, 'abx', 2);
    });
    test('star()', () {
      final parser = char('a').star();
      expectSuccess(parser, '', []);
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('starGreedy()', () {
      final parser = word().starGreedy(digit());
      expectFailure(parser, '', 0, 'digit expected');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, 'ab', 0, 'digit expected');
      expectSuccess(parser, '1', [], 0);
      expectSuccess(parser, 'a1', ['a'], 1);
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '12', ['1'], 1);
      expectSuccess(parser, 'a12', ['a', '1'], 2);
      expectSuccess(parser, 'ab12', ['a', 'b', '1'], 3);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c', '1'], 4);
      expectSuccess(parser, '123', ['1', '2'], 2);
      expectSuccess(parser, 'a123', ['a', '1', '2'], 3);
      expectSuccess(parser, 'ab123', ['a', 'b', '1', '2'], 4);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c', '1', '2'], 5);
    });
    test('starLazy()', () {
      final parser = word().starLazy(digit());
      expectFailure(parser, '');
      expectFailure(parser, 'a', 1, 'digit expected');
      expectFailure(parser, 'ab', 2, 'digit expected');
      expectSuccess(parser, '1', [], 0);
      expectSuccess(parser, 'a1', ['a'], 1);
      expectSuccess(parser, 'ab1', ['a', 'b'], 2);
      expectSuccess(parser, 'abc1', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '12', [], 0);
      expectSuccess(parser, 'a12', ['a'], 1);
      expectSuccess(parser, 'ab12', ['a', 'b'], 2);
      expectSuccess(parser, 'abc12', ['a', 'b', 'c'], 3);
      expectSuccess(parser, '123', [], 0);
      expectSuccess(parser, 'a123', ['a'], 1);
      expectSuccess(parser, 'ab123', ['a', 'b'], 2);
      expectSuccess(parser, 'abc123', ['a', 'b', 'c'], 3);
    });
    test('trim()', () {
      final parser = char('a').trim();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' a', 'a');
      expectSuccess(parser, 'a ', 'a');
      expectSuccess(parser, ' a ', 'a');
      expectSuccess(parser, '  a', 'a');
      expectSuccess(parser, 'a  ', 'a');
      expectSuccess(parser, '  a  ', 'a');
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'b', 0, '"a" expected');
      expectFailure(parser, ' b', 1, '"a" expected');
      expectFailure(parser, '  b', 2, '"a" expected');
    });
    test('trim() both', () {
      final parser = char('a').trim(char('*'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '*a', 'a');
      expectSuccess(parser, 'a*', 'a');
      expectSuccess(parser, '*a*', 'a');
      expectSuccess(parser, '**a', 'a');
      expectSuccess(parser, 'a**', 'a');
      expectSuccess(parser, '**a**', 'a');
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'b', 0, '"a" expected');
      expectFailure(parser, '*b', 1, '"a" expected');
      expectFailure(parser, '**b', 2, '"a" expected');
    });
    test('trim() left/right', () {
      final parser = char('a').trim(char('*'), char('#'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '*a', 'a');
      expectSuccess(parser, 'a#', 'a');
      expectSuccess(parser, '*a#', 'a');
      expectSuccess(parser, '**a', 'a');
      expectSuccess(parser, 'a##', 'a');
      expectSuccess(parser, '**a##', 'a');
      expectFailure(parser, '', 0, '"a" expected');
      expectFailure(parser, 'b', 0, '"a" expected');
      expectFailure(parser, '*b', 1, '"a" expected');
      expectFailure(parser, '**b', 2, '"a" expected');
      expectFailure(parser, '#a', 0, '"a" expected');
      expectSuccess(parser, 'a*', 'a', 1);
    });
    test('undefined()', () {
      final parser = undefined();
      expectFailure(parser, '', 0, 'undefined parser');
      expectFailure(parser, 'a', 0, 'undefined parser');
      parser.set(char('a'));
      expectSuccess(parser, 'a', 'a');
    });
    test('setable()', () {
      final parser = char('a').settable();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, '"a" expected');
      expectFailure(parser, '');
    });
    test('cast()', () {
      final parser = digit().map(int.parse).cast<num>();
      expectSuccess(parser, '1', 1);
      expectFailure(parser, 'a', 0, 'digit expected');
    });
    test('castList()', () {
      final parser = digit().map(int.parse).repeat(3).castList<num>();
      expectSuccess(parser, '123', <num>[1, 2, 3]);
      expectFailure(parser, 'abc', 0, 'digit expected');
    });
  });
  group('characters', () {
    test('anyOf()', () {
      final parser = anyOf('uncopyrightable');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'g', 'g');
      expectSuccess(parser, 'h', 'h');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectSuccess(parser, 'p', 'p');
      expectSuccess(parser, 'r', 'r');
      expectSuccess(parser, 't', 't');
      expectSuccess(parser, 'y', 'y');
      expectFailure(parser, 'x', 0, 'any of "uncopyrightable" expected');
    });
    test('noneOf()', () {
      final parser = noneOf('uncopyrightable');
      expectSuccess(parser, 'x', 'x');
      expectFailure(parser, 'c', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'g', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'h', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'i', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'o', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'p', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'r', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 't', 0, 'none of "uncopyrightable" expected');
      expectFailure(parser, 'y', 0, 'none of "uncopyrightable" expected');
    });
    test('char() with number', () {
      final parser = char(97, 'lowercase a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'lowercase a');
      expectFailure(parser, '');
    });
    test('char() invalid', () {
      expect(() => char('ab'), throwsArgumentError);
    });
    final specialChars = {
      '\\x00': '\x00',
      '\\b': '\b',
      '\\t': '\t',
      '\\n': '\n',
      '\\v': '\v',
      '\\f': '\f',
      '\\r': '\r',
      '\\"': '\"',
      '\\\'': '\'',
      '\\\\': '\\',
      '☠': '\u2620',
      ' ': ' ',
    };
    specialChars.forEach((key, value) {
      test('char("$key")', () {
        final parser = char(value);
        expectSuccess(parser, value, value);
        expectFailure(parser, 'a', 0, '"$key" expected');
      });
    });
    test('digit()', () {
      final parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, '');
    });
    test('letter()', () {
      final parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', 0, 'letter expected');
      expectFailure(parser, '');
    });
    test('lowercase()', () {
      final parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'lowercase letter expected');
      expectFailure(parser, '0', 0, 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('pattern() with single', () {
      final parser = pattern('abc');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[abc] expected');
      expectFailure(parser, '');
    });
    test('pattern() with range', () {
      final parser = pattern('a-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[a-c] expected');
      expectFailure(parser, '');
    });
    test('pattern() with overlapping range', () {
      final parser = pattern('b-da-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectFailure(parser, 'e', 0, '[b-da-c] expected');
      expectFailure(parser, '', 0, '[b-da-c] expected');
    });
    test('pattern() with adjacent range', () {
      final parser = pattern('c-ea-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'e', 'e');
      expectFailure(parser, 'f', 0, '[c-ea-c] expected');
      expectFailure(parser, '', 0, '[c-ea-c] expected');
    });
    test('pattern() with prefix range', () {
      final parser = pattern('a-ea-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'e', 'e');
      expectFailure(parser, 'f', 0, '[a-ea-c] expected');
      expectFailure(parser, '', 0, '[a-ea-c] expected');
    });
    test('pattern() with postfix range', () {
      final parser = pattern('a-ec-e');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'e', 'e');
      expectFailure(parser, 'f', 0, '[a-ec-e] expected');
      expectFailure(parser, '', 0, '[a-ec-e] expected');
    });
    test('pattern() with repeated range', () {
      final parser = pattern('a-ea-e');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'e', 'e');
      expectFailure(parser, 'f', 0, '[a-ea-e] expected');
      expectFailure(parser, '', 0, '[a-ea-e] expected');
    });
    test('pattern() with composed range', () {
      final parser = pattern('ac-df-');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'f', 'f');
      expectSuccess(parser, '-', '-');
      expectFailure(parser, 'b', 0, '[ac-df-] expected');
      expectFailure(parser, 'e', 0, '[ac-df-] expected');
      expectFailure(parser, 'g', 0, '[ac-df-] expected');
      expectFailure(parser, '');
    });
    test('pattern() with negated single', () {
      final parser = pattern('^a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, '[^a] expected');
      expectFailure(parser, '');
    });
    test('pattern() with negated range', () {
      final parser = pattern('^a-c');
      expectSuccess(parser, 'd', 'd');
      expectFailure(parser, 'a', 0, '[^a-c] expected');
      expectFailure(parser, 'b', 0, '[^a-c] expected');
      expectFailure(parser, 'c', 0, '[^a-c] expected');
      expectFailure(parser, '');
    });
    test('pattern() with error', () {
      expect(() => pattern('c-a'), throwsArgumentError);
    });
    test('range()', () {
      final parser = range('e', 'o');
      expectSuccess(parser, 'e', 'e');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectFailure(parser, 'p', 0, 'e..o expected');
      expectFailure(parser, 'd', 0, 'e..o expected');
      expectFailure(parser, '');
      expect(() => range('o', 'e'), throwsArgumentError);
    });
    test('uppercase()', () {
      final parser = uppercase();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectFailure(parser, 'a', 0, 'uppercase letter expected');
      expectFailure(parser, '0', 0, 'uppercase letter expected');
      expectFailure(parser, '');
    });
    test('whitespace()', () {
      final parser = whitespace();
      expectSuccess(parser, ' ', ' ');
      expectSuccess(parser, '\t', '\t');
      expectSuccess(parser, '\r', '\r');
      expectSuccess(parser, '\f', '\f');
      expectFailure(parser, 'z', 0, 'whitespace expected');
      expectFailure(parser, '');
    });
    test('whitespace() unicode', () {
      final string = String.fromCharCodes([
        9,
        10,
        11,
        12,
        13,
        32,
        133,
        160,
        5760,
        8192,
        8193,
        8194,
        8195,
        8196,
        8197,
        8198,
        8199,
        8200,
        8201,
        8202,
        8232,
        8233,
        8239,
        8287,
        12288,
        65279
      ]);
      final parser = whitespace().star().flatten().end();
      expectSuccess(parser, string, string);
    });
    test('word()', () {
      final parser = word();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectSuccess(parser, '0', '0');
      expectSuccess(parser, '9', '9');
      expectSuccess(parser, '_', '_');
      expectFailure(parser, '-', 0, 'letter or digit expected');
      expectFailure(parser, '');
    });
  });
  group('predicates', () {
    test('any()', () {
      final parser = any();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('anyIn()', () {
      final parser = anyIn('ab');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('string()', () {
      final parser = string('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'fo');
      expectFailure(parser, 'Foo');
    });
    test('stringIgnoreCase()', () {
      final parser = stringIgnoreCase('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectSuccess(parser, 'FOO', 'FOO');
      expectSuccess(parser, 'fOo', 'fOo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'Fo');
    });
  });
  group('token', () {
    const buffer = '1\r12\r\n123\n1234';
    final parser = any().map((value) => value.codeUnitAt(0)).token().star();
    final result = parser.parse(buffer).value;
    test('value', () {
      final expected = [49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52];
      expect(result.map((token) => token.value), expected);
    });
    test('buffer', () {
      final expected = List.filled(buffer.length, buffer);
      expect(result.map((token) => token.buffer), expected);
    });
    test('start', () {
      final expected = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
      expect(result.map((token) => token.start), expected);
    });
    test('stop', () {
      final expected = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
      expect(result.map((token) => token.stop), expected);
    });
    test('length', () {
      final expected = List.filled(buffer.length, 1);
      expect(result.map((token) => token.length), expected);
    });
    test('line', () {
      final expected = [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4];
      expect(result.map((token) => token.line), expected);
    });
    test('column', () {
      final expected = [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4];
      expect(result.map((token) => token.column), expected);
    });
    test('input', () {
      final expected = [
        '1',
        '\r',
        '1',
        '2',
        '\r',
        '\n',
        '1',
        '2',
        '3',
        '\n',
        '1',
        '2',
        '3',
        '4'
      ];
      expect(result.map((token) => token.input), expected);
    });
    test('unique', () {
      expect(Set.of(result).length, result.length);
    });
    test('equals', () {
      for (var i = 0; i < result.length; i++) {
        for (var j = 0; j < result.length; j++) {
          final condition = i == j ? isTrue : isFalse;
          expect(result[i] == result[j], condition);
          expect(result[i].hashCode == result[j].hashCode, condition);
        }
      }
    });
  });
  group('context', () {
    const buffer = 'a\nc';
    const context = Context(buffer, 0);
    test('context', () {
      expect(context.buffer, buffer);
      expect(context.position, 0);
      expect(context.toString(), 'Context[1:1]');
    });
    test('success', () {
      final success = context.success('result');
      expect(success.buffer, buffer);
      expect(success.position, 0);
      expect(success.value, 'result');
      expect(success.message, isNull);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.toString(), 'Success[1:1]: result');
    });
    test('success with position', () {
      final success = context.success('result', 2);
      expect(success.buffer, buffer);
      expect(success.position, 2);
      expect(success.value, 'result');
      expect(success.message, isNull);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.toString(), 'Success[2:1]: result');
    });
    test('sucess with mapping', () {
      final success = context.success('result', 2).map((value) {
        expect(value, 'result');
        return 123;
      });
      expect(success.buffer, buffer);
      expect(success.position, 2);
      expect(success.value, 123);
      expect(success.message, isNull);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.toString(), 'Success[2:1]: 123');
    });
    test('failure', () {
      final failure = context.failure('error');
      expect(failure.buffer, buffer);
      expect(failure.position, 0);
      try {
        failure.value;
        fail('Expected ParserError to be thrown');
      } on ParserException catch (error) {
        expect(error.failure, same(failure));
        expect(error.toString(), 'error at 1:1');
      }
      expect(failure.message, 'error');
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.toString(), 'Failure[1:1]: error');
    });
    test('failure with position', () {
      final failure = context.failure('error', 2);
      expect(failure.buffer, buffer);
      expect(failure.position, 2);
      try {
        failure.value;
        fail('Expected ParserError to be thrown');
      } on ParserException catch (error) {
        expect(error.failure, same(failure));
        expect(error.toString(), 'error at 2:1');
      }
      expect(failure.message, 'error');
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.toString(), 'Failure[2:1]: error');
    });
    test('failure with mapping', () {
      final failure = context
          .failure('error', 2)
          .map((value) => fail('Not expected to be called'));
      expect(failure.buffer, buffer);
      expect(failure.position, 2);
      try {
        failure.value;
        fail('Expected ParserError to be thrown');
      } on ParserException catch (error) {
        expect(error.failure, same(failure));
        expect(error.toString(), 'error at 2:1');
      }
      expect(failure.message, 'error');
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.toString(), 'Failure[2:1]: error');
    });
  });
  group('parsing', () {
    test('parse()', () {
      final parser = char('a');
      expect(parser.parse('a').isSuccess, isTrue);
      expect(parser.parse('b').isSuccess, isFalse);
    });
    test('accept()', () {
      final parser = char('a');
      expect(parser.accept('a'), isTrue);
      expect(parser.accept('b'), isFalse);
    });
    test('matches()', () {
      final parser = digit().seq(digit()).flatten();
      expect(parser.matches('a123b45'), ['12', '23', '45']);
    });
    test('matchesSkipping()', () {
      final parser = digit().seq(digit()).flatten();
      expect(parser.matchesSkipping('a123b45'), ['12', '45']);
    });
    group('pattern', () {
      const input = 'a123b45';
      final pattern = digit().seq(digit());
      test('allMatches()', () {
        final matches = pattern.allMatches(input);
        expect(matches.map((matcher) => matcher.pattern), [pattern, pattern]);
        expect(matches.map((matcher) => matcher.input), [input, input]);
        expect(matches.map((matcher) => matcher.start), [1, 5]);
        expect(matches.map((matcher) => matcher.end), [3, 7]);
        expect(matches.map((matcher) => matcher.groupCount), [1, 1]);
        expect(matches.map((matcher) => matcher[0]), ['12', '45']);
        expect(matches.map((matcher) => matcher.group(0)), ['12', '45']);
        expect(matches.map((matcher) => matcher.groups([0, 1])), [
          ['12', null],
          ['45', null],
        ]);
      });
      test('allMatches() (empty match)', () {
        final pattern = digit().star();
        final matches = pattern.allMatches(input);
        expect(matches.map((matcher) => matcher[0]), ['', '123', '', '45', '']);
      });
      test('matchAsPrefix()', () {
        final match1 = pattern.matchAsPrefix(input, 0);
        expect(match1, isNull);
        final match2 = pattern.matchAsPrefix(input, 2);
        expect(match2.pattern, pattern);
        expect(match2.input, input);
        expect(match2.start, 2);
        expect(match2.end, 4);
        expect(match2.groupCount, 1);
        expect(match2[0], '23');
        expect(match2.group(0), '23');
        expect(match2.groups([0, 1]), ['23', null]);
      });
      test('startsWith()', () {
        expect(input.startsWith(pattern), isFalse);
        expect(input.startsWith(pattern, 1), isTrue);
        expect(input.startsWith(pattern, 2), isTrue);
        expect(input.startsWith(pattern, 3), isFalse);
      });
      test('indexOf()', () {
        expect(input.indexOf(pattern), 1);
        expect(input.indexOf(pattern, 1), 1);
        expect(input.indexOf(pattern, 2), 2);
        expect(input.indexOf(pattern, 3), 5);
      });
      test('lastIndexOf()', () {
        expect(input.lastIndexOf(pattern), 5);
      });
      test('contains()', () {
        expect(input.contains(pattern), isTrue);
      });
      test('replaceFirst()', () {
        expect(input.replaceFirst(pattern, '!'), 'a!3b45');
      });
      test('replaceFirstMapped()', () {
        expect(input.replaceFirstMapped(pattern, (match) => '!${match[0]}!'),
            'a!12!3b45');
      });
      test('replaceAll()', () {
        expect(input.replaceAll(pattern, '!'), 'a!3b!');
      }, onPlatform: {
        'js': const Skip('String.replaceAll(Pattern) UNIMPLEMENTED')
      });
      test('replaceAllMapped()', () {
        expect(input.replaceAllMapped(pattern, (match) => '!${match[0]}!'),
            'a!12!3b!45!');
      });
      test('split()', () {
        expect(input.split(pattern), ['a', '3b', '']);
      });
      test('splitMapJoin()', () {
        expect(
            input.splitMapJoin(pattern,
                onMatch: (match) => '!${match[0]}!',
                onNonMatch: (nonMatch) => '?$nonMatch?'),
            '?a?!12!?3b?!45!??');
      });
    });
  });
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
  group('copying, matching, replacing', () {
    final immutableParsers = {PositionParser};
    void verify(Parser parser) {
      final copy = parser.copy();
      if (immutableParsers.contains(copy.runtimeType)) {
        // check immutable
        expect(copy, same(parser));
        expect(parser.children, isEmpty);
      } else {
        // check copying
        expect(copy, isNot(same(parser)));
        expect(copy.toString(), parser.toString());
        expect(copy.runtimeType, parser.runtimeType);
        expect(copy.children,
            pairwiseCompare(parser.children, identical, 'same children'));
      }
      // check equality
      expect(copy.isEqualTo(copy), isTrue);
      expect(parser.isEqualTo(parser), isTrue);
      expect(copy.isEqualTo(parser), isTrue);
      expect(parser.isEqualTo(copy), isTrue);
      // check replacing
      final replaced = <Parser>[];
      for (var i = 0; i < copy.children.length; i++) {
        final source = copy.children[i], target = any();
        copy.replace(source, target);
        expect(copy.children[i], same(target));
        replaced.add(target);
      }
      expect(copy.children,
          pairwiseCompare(replaced, identical, 'replaced children'));
    }

    test('and()', () => verify(any().and()));
    test('any()', () => verify(any()));
    test('cast()', () => verify(any().cast()));
    test('castList()', () => verify(any().castList()));
    test('char()', () => verify(char('a')));
    test('delegate()', () => verify(DelegateParser(any())));
    test('digit()', () => verify(digit()));
    test('endOfInput()', () => verify(endOfInput()));
    test('epsilon()', () => verify(epsilon()));
    test('failure()', () => verify(failure()));
    test('flatten()', () => verify(any().flatten()));
    test('letter()', () => verify(letter()));
    test('lowercase()', () => verify(lowercase()));
    test('map()', () => verify(any().map((a) => a)));
    test('not()', () => verify(any().not()));
    test('optional()', () => verify(any().optional()));
    test('or()', () => verify(any().or(word())));
    test('pattern()', () => verify(pattern('^a-cz')));
    test('plus()', () => verify(any().plus()));
    test('plusGreedy()', () => verify(any().plusGreedy(word())));
    test('plusLazy()', () => verify(any().plusLazy(word())));
    test('position()', () => verify(const PositionParser()));
    test('range()', () => verify(range('a', 'z')));
    test('repeat()', () => verify(any().repeat(2, 3)));
    test('repeatGreedy()', () => verify(any().repeatGreedy(word(), 2, 3)));
    test('repeatLazy()', () => verify(any().repeatLazy(word(), 2, 3)));
    test('seq()', () => verify(any().seq(word())));
    test('setable()', () => verify(any().settable()));
    test('star()', () => verify(any().star()));
    test('starGreedy()', () => verify(any().starGreedy(word())));
    test('starLazy()', () => verify(any().starLazy(word())));
    test('string()', () => verify(string('ab')));
    test('times()', () => verify(any().times(2)));
    test('token()', () => verify(any().token()));
    test('trim()', () => verify(any().trim(char('a'), char('b'))));
    test('undefined()', () => verify(undefined()));
    test('uppercase()', () => verify(uppercase()));
    test('whitespace()', () => verify(whitespace()));
    test('word()', () => verify(word()));

    test('map() compare (different signature)', () {
      final a = digit().map((a) => 42);
      final b = digit().map((a) => '42');
      expect(a.isEqualTo(b), isFalse);
    });
    test('map() compare (different code)', () {
      final a = digit().map((a) => 42);
      final b = digit().map((a) => 43);
      expect(a.isEqualTo(b), isFalse);
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
      testWith(String name, Parser<List<T>> Function<T>(Parser<T>) builder) {
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
  group('definition', () {
    final grammarDefinition = ListGrammarDefinition();
    final parserDefinition = ListParserDefinition();
    final tokenDefinition = TokenizedListGrammarDefinition();
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
      final firstReference =
          grammarDefinition.ref(grammarDefinition.start, 'a');
      final secondReference =
          grammarDefinition.ref(grammarDefinition.start, 'a');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different parameters', () {
      final firstReference =
          grammarDefinition.ref(grammarDefinition.start, 'a');
      final secondReference =
          grammarDefinition.ref(grammarDefinition.start, 'b');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
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
  group('expression', () {
    Parser build({bool attachAction = true}) {
      final action = attachAction ? (func) => func : (func) => null;
      final root = failure().settable();
      final builder = ExpressionBuilder();
      builder.group()
        ..primitive(char('(').trim().seq(root).seq(char(')').trim()).pick(1))
        ..primitive(
          digit()
              .plus()
              .seq(char('.').seq(digit().plus()).optional())
              .flatten()
              .trim(),
          action(double.parse),
        );
      builder.group()..prefix(char('-').trim(), action((op, a) => -a));
      builder.group()
        ..postfix(string('++').trim(), action((a, op) => ++a))
        ..postfix(string('--').trim(), action((a, op) => --a));
      builder.group()
        ..right(char('^').trim(), action((a, op, b) => math.pow(a, b)));
      builder.group()
        ..left(char('*').trim(), action((a, op, b) => a * b))
        ..left(char('/').trim(), action((a, op, b) => a / b));
      builder.group()
        ..left(char('+').trim(), action((a, op, b) => a + b))
        ..left(char('-').trim(), action((a, op, b) => a - b));
      root.set(builder.build());
      return root.end();
    }

    const epsilon = 1e-5;
    final parser = build(attachAction: false);
    final evaluator = build(attachAction: true);
    test('number', () {
      expect(evaluator.parse('0').value, closeTo(0, epsilon));
      expect(evaluator.parse('0.0').value, closeTo(0, epsilon));
      expect(evaluator.parse('1').value, closeTo(1, epsilon));
      expect(evaluator.parse('1.2').value, closeTo(1.2, epsilon));
      expect(evaluator.parse('34').value, closeTo(34, epsilon));
      expect(evaluator.parse('34.7').value, closeTo(34.7, epsilon));
      expect(evaluator.parse('56.78').value, closeTo(56.78, epsilon));
    });
    test('number negative', () {
      expect(evaluator.parse('-1').value, closeTo(-1, epsilon));
      expect(evaluator.parse('-1.2').value, closeTo(-1.2, epsilon));
    });
    test('number parse', () {
      expect(parser.parse('0').value, '0');
      expect(parser.parse('-1').value, ['-', '1']);
    });
    test('add', () {
      expect(evaluator.parse('1 + 2').value, closeTo(3, epsilon));
      expect(evaluator.parse('2 + 1').value, closeTo(3, epsilon));
      expect(evaluator.parse('1 + 2.3').value, closeTo(3.3, epsilon));
      expect(evaluator.parse('2.3 + 1').value, closeTo(3.3, epsilon));
      expect(evaluator.parse('1 + -2').value, closeTo(-1, epsilon));
      expect(evaluator.parse('-2 + 1').value, closeTo(-1, epsilon));
    });
    test('add many', () {
      expect(evaluator.parse('1').value, closeTo(1, epsilon));
      expect(evaluator.parse('1 + 2').value, closeTo(3, epsilon));
      expect(evaluator.parse('1 + 2 + 3').value, closeTo(6, epsilon));
      expect(evaluator.parse('1 + 2 + 3 + 4').value, closeTo(10, epsilon));
      expect(evaluator.parse('1 + 2 + 3 + 4 + 5').value, closeTo(15, epsilon));
    });
    test('add parse', () {
      expect(parser.parse('1 + 2 + 3').value, [
        ['1', '+', '2'],
        '+',
        '3'
      ]);
    });
    test('sub', () {
      expect(evaluator.parse('1 - 2').value, closeTo(-1, epsilon));
      expect(evaluator.parse('1.2 - 1.2').value, closeTo(0, epsilon));
      expect(evaluator.parse('1 - -2').value, closeTo(3, epsilon));
      expect(evaluator.parse('-1 - -2').value, closeTo(1, epsilon));
    });
    test('sub many', () {
      expect(evaluator.parse('1').value, closeTo(1, epsilon));
      expect(evaluator.parse('1 - 2').value, closeTo(-1, epsilon));
      expect(evaluator.parse('1 - 2 - 3').value, closeTo(-4, epsilon));
      expect(evaluator.parse('1 - 2 - 3 - 4').value, closeTo(-8, epsilon));
      expect(evaluator.parse('1 - 2 - 3 - 4 - 5').value, closeTo(-13, epsilon));
    });
    test('sub parse', () {
      expect(parser.parse('1 - 2 - 3').value, [
        ['1', '-', '2'],
        '-',
        '3'
      ]);
    });
    test('mul', () {
      expect(evaluator.parse('2 * 3').value, closeTo(6, epsilon));
      expect(evaluator.parse('2 * -4').value, closeTo(-8, epsilon));
    });
    test('mul many', () {
      expect(evaluator.parse('1 * 2').value, closeTo(2, epsilon));
      expect(evaluator.parse('1 * 2 * 3').value, closeTo(6, epsilon));
      expect(evaluator.parse('1 * 2 * 3 * 4').value, closeTo(24, epsilon));
      expect(evaluator.parse('1 * 2 * 3 * 4 * 5').value, closeTo(120, epsilon));
    });
    test('mul parse', () {
      expect(parser.parse('1 * 2 * 3').value, [
        ['1', '*', '2'],
        '*',
        '3'
      ]);
    });
    test('div', () {
      expect(evaluator.parse('12 / 3').value, closeTo(4, epsilon));
      expect(evaluator.parse('-16 / -4').value, closeTo(4, epsilon));
    });
    test('div many', () {
      expect(evaluator.parse('100 / 2').value, closeTo(50, epsilon));
      expect(evaluator.parse('100 / 2 / 2').value, closeTo(25, epsilon));
      expect(evaluator.parse('100 / 2 / 2 / 5').value, closeTo(5, epsilon));
      expect(evaluator.parse('100 / 2 / 2 / 5 / 5').value, closeTo(1, epsilon));
    });
    test('mul parse', () {
      expect(parser.parse('1 / 2 / 3').value, [
        ['1', '/', '2'],
        '/',
        '3'
      ]);
    });
    test('pow', () {
      expect(evaluator.parse('2 ^ 3').value, closeTo(8, epsilon));
      expect(evaluator.parse('-2 ^ 3').value, closeTo(-8, epsilon));
      expect(evaluator.parse('-2 ^ -3').value, closeTo(-0.125, epsilon));
    });
    test('pow many', () {
      expect(evaluator.parse('4 ^ 3').value, closeTo(64, epsilon));
      expect(evaluator.parse('4 ^ 3 ^ 2').value, closeTo(262144, epsilon));
      expect(evaluator.parse('4 ^ 3 ^ 2 ^ 1').value, closeTo(262144, epsilon));
      expect(
          evaluator.parse('4 ^ 3 ^ 2 ^ 1 ^ 0').value, closeTo(262144, epsilon));
    });
    test('pow parse', () {
      expect(parser.parse('1 ^ 2 ^ 3').value, [
        '1',
        '^',
        ['2', '^', '3']
      ]);
    });
    test('parens', () {
      expect(evaluator.parse('(1)').value, closeTo(1, epsilon));
      expect(evaluator.parse('(1 + 2)').value, closeTo(3, epsilon));
      expect(evaluator.parse('((1))').value, closeTo(1, epsilon));
      expect(evaluator.parse('((1 + 2))').value, closeTo(3, epsilon));
      expect(evaluator.parse('2 * (3 + 4)').value, closeTo(14, epsilon));
      expect(evaluator.parse('(2 + 3) * 4').value, closeTo(20, epsilon));
      expect(evaluator.parse('6 / (2 + 4)').value, closeTo(1, epsilon));
      expect(evaluator.parse('(2 + 6) / 2').value, closeTo(4, epsilon));
    });
    test('priority', () {
      expect(evaluator.parse('2 * 3 + 4').value, closeTo(10, epsilon));
      expect(evaluator.parse('2 + 3 * 4').value, closeTo(14, epsilon));
      expect(evaluator.parse('6 / 3 + 4').value, closeTo(6, epsilon));
      expect(evaluator.parse('2 + 6 / 2').value, closeTo(5, epsilon));
    });
    test('priority parse', () {
      expect(parser.parse('2 * 3 + 4').value, [
        ['2', '*', '3'],
        '+',
        '4'
      ]);
      expect(parser.parse('2 + 3 * 4').value, [
        '2',
        '+',
        ['3', '*', '4']
      ]);
    });
    test('postfix add', () {
      expect(evaluator.parse('0++').value, closeTo(1, epsilon));
      expect(evaluator.parse('0++++').value, closeTo(2, epsilon));
      expect(evaluator.parse('0++++++').value, closeTo(3, epsilon));
      expect(evaluator.parse('0+++1').value, closeTo(2, epsilon));
      expect(evaluator.parse('0+++++1').value, closeTo(3, epsilon));
      expect(evaluator.parse('0+++++++1').value, closeTo(4, epsilon));
    });
    test('postfix add parse', () {
      expect(parser.parse('0++').value, ['0', '++']);
      expect(parser.parse('0++++').value, [
        ['0', '++'],
        '++'
      ]);
      expect(parser.parse('0++++++').value, [
        [
          ['0', '++'],
          '++'
        ],
        '++'
      ]);
      expect(parser.parse('0+++1').value, [
        ['0', '++'],
        '+',
        '1'
      ]);
      expect(parser.parse('0+++++1').value, [
        [
          ['0', '++'],
          '++'
        ],
        '+',
        '1'
      ]);
      expect(parser.parse('0+++++++1').value, [
        [
          [
            ['0', '++'],
            '++'
          ],
          '++'
        ],
        '+',
        '1'
      ]);
    });
    test('postfix sub', () {
      expect(evaluator.parse('1--').value, closeTo(0, epsilon));
      expect(evaluator.parse('2----').value, closeTo(0, epsilon));
      expect(evaluator.parse('3------').value, closeTo(0, epsilon));
      expect(evaluator.parse('2---1').value, closeTo(0, epsilon));
      expect(evaluator.parse('3-----1').value, closeTo(0, epsilon));
      expect(evaluator.parse('4-------1').value, closeTo(0, epsilon));
    });
    test('postfix sub parse', () {
      expect(parser.parse('0--').value, ['0', '--']);
      expect(parser.parse('0----').value, [
        ['0', '--'],
        '--'
      ]);
      expect(parser.parse('0------').value, [
        [
          ['0', '--'],
          '--'
        ],
        '--'
      ]);
      expect(parser.parse('0---1').value, [
        ['0', '--'],
        '-',
        '1'
      ]);
      expect(parser.parse('0-----1').value, [
        [
          ['0', '--'],
          '--'
        ],
        '-',
        '1'
      ]);
      expect(parser.parse('0-------1').value, [
        [
          [
            ['0', '--'],
            '--'
          ],
          '--'
        ],
        '-',
        '1'
      ]);
    });
    test('negate', () {
      expect(evaluator.parse('1').value, closeTo(1, epsilon));
      expect(evaluator.parse('-1').value, closeTo(-1, epsilon));
      expect(evaluator.parse('--1').value, closeTo(1, epsilon));
      expect(evaluator.parse('---1').value, closeTo(-1, epsilon));
    });
    test('negate parse', () {
      expect(parser.parse('1').value, '1');
      expect(parser.parse('-1').value, ['-', '1']);
      expect(parser.parse('--1').value, [
        '-',
        ['-', '1']
      ]);
      expect(parser.parse('---1').value, [
        '-',
        [
          '-',
          ['-', '1']
        ]
      ]);
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
