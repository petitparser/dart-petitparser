library core_test;

import 'dart:math' as math;

import 'package:unittest/unittest.dart';

import 'package:petitparser/petitparser.dart';

void expectSuccess(Parser parser, dynamic input, dynamic expected, [int position]) {
  var result = parser.parse(input);
  expect(result.isSuccess, isTrue);
  expect(result.isFailure, isFalse);
  expect(result.value, expected);
  expect(result.position, position != null ? position : input.length);
}

void expectFailure(Parser parser, dynamic input, [int position = 0, String message]) {
  var result = parser.parse(input);
  expect(result.isFailure, isTrue);
  expect(result.isSuccess, isFalse);
  expect(result.position, position);
  if (message != null) {
    expect(result.message, message);
  }
}

class ListGrammarDefinition extends GrammarDefinition {
  start()   => ref(list).end();
  list()    => ref(element) & char(',') & ref(list)
             | ref(element);
  element() => digit().plus().flatten();
}

class ListParserDefinition extends ListGrammarDefinition {
  element() => super.element().map((value) => int.parse(value));
}

class TokenizedListGrammarDefinition extends GrammarDefinition {
  start()   => ref(list).end();
  list()    => ref(element) & ref(token, char(',')) & ref(list)
             | ref(element);
  element() => ref(token, digit().plus());
  token(p)  => p.flatten().trim();
}

class PluggableCompositeParser extends CompositeParser {
  final Function _function;
  PluggableCompositeParser(this._function) : super();
  void initialize() { _function(this); }
}

main() {
  group('parsers', () {
    test('and()', () {
      var parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('or() operator', () {
      var parser = char('a') | char('b');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('or() of two', () {
      var parser = char('a').or(char('b'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('or() of three', () {
      var parser = char('a').or(char('b')).or(char('c'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd');
      expectFailure(parser, '');
    });
    test('end()', () {
      var parser = char('a').end();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'aa', 1, 'end of input expected');
    });
    test('epsilon()', () {
      var parser = epsilon();
      expectSuccess(parser, '', null);
      expectSuccess(parser, 'a', null, 0);
    });
    test('failure()', () {
      var parser = failure('failure');
      expectFailure(parser, '', 0, 'failure');
      expectFailure(parser, 'a', 0, 'failure');
    });
    test('flatten()', () {
      var parser = digit().plus().flatten();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('token()', () {
      var parser = digit().plus().token();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      var token = parser.parse('123').value;
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
      var parser = digit().map((String each) {
        return each.codeUnitAt(0) - '0'.codeUnitAt(0);
      });
      expectSuccess(parser, '1', 1);
      expectSuccess(parser, '4', 4);
      expectSuccess(parser, '9', 9);
      expectFailure(parser, '');
      expectFailure(parser, 'a');
    });
    test('pick(1)', () {
      var parser = digit().seq(letter()).pick(1);
      expectSuccess(parser, '1a', 'a');
      expectSuccess(parser, '2b', 'b');
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('pick(-1)', () {
      var parser = digit().seq(letter()).pick(-1);
      expectSuccess(parser, '1a', 'a');
      expectSuccess(parser, '2b', 'b');
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('permute([1, 0])', () {
      var parser = digit().seq(letter()).permute([1, 0]);
      expectSuccess(parser, '1a', ['a', '1']);
      expectSuccess(parser, '2b', ['b', '2']);
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('permute([-1, 0])', () {
      var parser = digit().seq(letter()).permute([-1, 0]);
      expectSuccess(parser, '1a', ['a', '1']);
      expectSuccess(parser, '2b', ['b', '2']);
      expectFailure(parser, '');
      expectFailure(parser, '1', 1, 'letter expected');
      expectFailure(parser, '12', 1, 'letter expected');
    });
    test('not()', () {
      var parser = char('a').not('not a expected');
      expectFailure(parser, 'a', 0, 'not a expected');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('neg()', () {
      var parser = digit().neg('no digit expected');
      expectFailure(parser, '1', 0, 'no digit expected');
      expectFailure(parser, '9', 0, 'no digit expected');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('optional()', () {
      var parser = char('a').optional();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('plus()', () {
      var parser = char('a').plus();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('plusGreedy()', () {
      var parser = word().plusGreedy(digit());
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
      var parser = word().plusLazy(digit());
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
      var parser = char('a').times(2);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('repeat()', () {
      var parser = char('a').repeat(2, 3);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
    });
    test('repeat() unbounded', () {
      var input = new List.filled(100000, 'a');
      var parser = char('a').repeat(2, unbounded);
      expectSuccess(parser, input.join(), input);
    });
    test('repeatGreedy()', () {
      var parser = word().repeatGreedy(digit(), 2, 4);
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
      var inputLetter = new List.filled(100000, 'a');
      var inputDigit = new List.filled(100000, '1');
      var parser = word().repeatGreedy(digit(), 2, unbounded);
      expectSuccess(parser, inputLetter.join() + '1', inputLetter, inputLetter.length);
      expectSuccess(parser, inputDigit.join() + '1', inputDigit, inputDigit.length);
    });
    test('repeatLazy()', () {
      var parser = word().repeatLazy(digit(), 2, 4);
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
      var input = new List.filled(100000, 'a');
      var parser = word().repeatLazy(digit(), 2, unbounded);
      expectSuccess(parser, input.join() + '1111', input, input.length);
    });
    test('separatedBy()', () {
      var parser = char('a').separatedBy(char('b'));
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a'], 5);
    });
    test('separatedBy() without separators', () {
      var parser = char('a').separatedBy(char('b'), includeSeparators: false);
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'a']);
      expectSuccess(parser, 'abab', ['a', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'a', 'a'], 5);
    });
    test('separatedBy() separator at end', () {
      var parser = char('a').separatedBy(char('b'), optionalSeparatorAtEnd: true);
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a', 'b']);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a', 'b']);
    });
    test('separatedBy() without separators & separator at end', () {
      var parser = char('a').separatedBy(char('b'), includeSeparators: false, optionalSeparatorAtEnd: true);
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a']);
      expectSuccess(parser, 'aba', ['a', 'a']);
      expectSuccess(parser, 'abab', ['a', 'a']);
      expectSuccess(parser, 'ababa', ['a', 'a', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'a', 'a']);
    });
    test('seq() operator', () {
      var parser = char('a') & char('b');
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('seq() of two', () {
      var parser = char('a').seq(char('b'));
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('seq() of three', () {
      var parser = char('a').seq(char('b')).seq(char('c'));
      expectSuccess(parser, 'abc', ['a', 'b', 'c']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
      expectFailure(parser, 'ab', 2);
      expectFailure(parser, 'abx', 2);
    });
    test('star()', () {
      var parser = char('a').star();
      expectSuccess(parser, '', []);
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('starGreedy()', () {
      var parser = word().starGreedy(digit());
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
      var parser = word().starLazy(digit());
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
      var parser = char('a').trim();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' a', 'a');
      expectSuccess(parser, 'a ', 'a');
      expectSuccess(parser, ' a ', 'a');
      expectSuccess(parser, '  a', 'a');
      expectSuccess(parser, 'a  ', 'a');
      expectSuccess(parser, '  a  ', 'a');
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, ' b', 1, 'a expected');
      expectFailure(parser, '  b', 2, 'a expected');
    });
    test('trim() custom', () {
      var parser = char('a').trim(char('*'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '*a', 'a');
      expectSuccess(parser, 'a*', 'a');
      expectSuccess(parser, '*a*', 'a');
      expectSuccess(parser, '**a', 'a');
      expectSuccess(parser, 'a**', 'a');
      expectSuccess(parser, '**a**', 'a');
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '*b', 1, 'a expected');
      expectFailure(parser, '**b', 2, 'a expected');
    });
    test('undefined()', () {
      var parser = undefined();
      expectFailure(parser, '', 0, 'undefined parser');
      expectFailure(parser, 'a', 0, 'undefined parser');
      parser.set(char('a'));
      expectSuccess(parser, 'a', 'a');
    });
    test('setable()', () {
      var parser = char('a').setable();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
  });
  group('characters', () {
    test('char()', () {
      var parser = char('a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('char() with number', () {
      var parser = char(97, 'lowercase a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'lowercase a');
      expectFailure(parser, '');
    });
    test('char() invalid', () {
      expect(() => char('ab'), throwsArgumentError);
    });
    test('digit()', () {
      var parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, '');
    });
    test('letter()', () {
      var parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', 0, 'letter expected');
      expectFailure(parser, '');
    });
    test('lowercase()', () {
      var parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'lowercase letter expected');
      expectFailure(parser, '0', 0, 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('pattern() with single', () {
      var parser = pattern('abc');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[abc] expected');
      expectFailure(parser, '');
    });
    test('pattern() with range', () {
      var parser = pattern('a-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[a-c] expected');
      expectFailure(parser, '');
    });
    test('pattern() with composed', () {
      var parser = pattern('ac-df-');
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
      var parser = pattern('^a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, '[^a] expected');
      expectFailure(parser, '');
    });
    test('pattern() with negated range', () {
      var parser = pattern('^a-c');
      expectSuccess(parser, 'd', 'd');
      expectFailure(parser, 'a', 0, '[^a-c] expected');
      expectFailure(parser, 'b', 0, '[^a-c] expected');
      expectFailure(parser, 'c', 0, '[^a-c] expected');
      expectFailure(parser, '');
    });
    test('range()', () {
      var parser = range('e', 'o');
      expectSuccess(parser, 'e', 'e');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectFailure(parser, 'p', 0, 'e..o expected');
      expectFailure(parser, 'd', 0, 'e..o expected');
      expectFailure(parser, '');
    });
    test('uppercase()', () {
      var parser = uppercase();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectFailure(parser, 'a', 0, 'uppercase letter expected');
      expectFailure(parser, '0', 0, 'uppercase letter expected');
      expectFailure(parser, '');
    });
    test('whitespace()', () {
      var parser = whitespace();
      expectSuccess(parser, ' ', ' ');
      expectSuccess(parser, '\t', '\t');
      expectSuccess(parser, '\r', '\r');
      expectSuccess(parser, '\f', '\f');
      expectFailure(parser, 'z', 0, 'whitespace expected');
      expectFailure(parser, '');
    });
    test('whitespace() unicode', () {
      var string = new String.fromCharCodes([0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0x85, 0xA0,
        0x1680, 0x180E, 0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007, 0x2008,
        0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF]);
      var parser = whitespace().star().flatten().end();
      expectSuccess(parser, string, string);
    });
    test('word()', () {
      var parser = word();
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
      var parser = any();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('anyIn()', () {
      var parser = anyIn(['a', 'b']);
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('string()', () {
      var parser = string('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'fo');
      expectFailure(parser, 'Foo');
    });
    test('stringIgnoreCase()', () {
      var parser = stringIgnoreCase('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectSuccess(parser, 'FOO', 'FOO');
      expectSuccess(parser, 'fOo', 'fOo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'Fo');
    });
  });
  group('token', () {
    var parser = any()
        .map((value) => value.codeUnitAt(0))
        .token().star();
    var buffer = '1\r12\r\n123\n1234';
    var result = parser.parse(buffer).value;
    test('value', () {
      expect(
          result.map((token) => token.value),
          [49, 13, 49, 50, 13, 10, 49, 50, 51, 10, 49, 50, 51, 52]);
    });
    test('buffer', () {
      expect(
          result.map((token) => token.buffer),
          new List.filled(buffer.length, buffer));
    });
    test('start', () {
      expect(
          result.map((token) => token.start),
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]);
    });
    test('stop', () {
      expect(
          result.map((token) => token.stop),
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
    });
    test('length', () {
      expect(
          result.map((token) => token.length),
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]);
    });
    test('line', () {
      expect(
          result.map((token) => token.line),
          [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]);
    });
    test('column', () {
      expect(
          result.map((token) => token.column),
          [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]);
    });
    test('input', () {
      expect(
          result.map((token) => token.input),
          ['1', '\r', '1', '2', '\r', '\n', '1', '2', '3', '\n', '1', '2', '3', '4']);
    });
    test('unique', () {
      expect(new Set.from(result).length, result.length);
    });
  });
  group('context', () {
    var buffer = 'a\nc';
    var context = new Context(buffer, 0);
    test('context', () {
      expect(context.buffer, buffer);
      expect(context.position, 0);
      expect(context.isSuccess, isFalse);
      expect(context.isFailure, isFalse);
      expect(context.toString(), 'Context[1:1]');
    });
    test('success', () {
      var success = context.success('result');
      expect(success.buffer, buffer);
      expect(success.position, 0);
      expect(success.value, 'result');
      expect(success.message, isNull);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.toString(), 'Success[1:1]: result');
    });
    test('success with position', () {
      var success = context.success('result', 2);
      expect(success.buffer, buffer);
      expect(success.position, 2);
      expect(success.value, 'result');
      expect(success.message, isNull);
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.toString(), 'Success[2:1]: result');
    });
    test('failure', () {
      var failure = context.failure('error');
      expect(failure.buffer, buffer);
      expect(failure.position, 0);
      try {
        failure.value;
        fail('Expected ParserError to be thrown');
      } on ParserError catch (error, stack) {
        expect(error.failure, same(failure));
        expect(error.toString(), 'error at 1:1');
      }
      expect(failure.message, 'error');
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.toString(), 'Failure[1:1]: error');
    });
    test('failure with position', () {
      var failure = context.failure('error', 2);
      expect(failure.buffer, buffer);
      expect(failure.position, 2);
      try {
        failure.value;
        fail('Expected ParserError to be thrown');
      } on ParserError catch (error, stack) {
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
      var parser = char('a');
      expect(parser.parse('a').isSuccess, isTrue);
      expect(parser.parse('b').isSuccess, isFalse);
    });
    test('accept()', () {
      var parser = char('a');
      expect(parser.accept('a'), isTrue);
      expect(parser.accept('b'), isFalse);
    });
    test('matches()', () {
      var parser = digit().seq(digit()).flatten();
      expect(parser.matches('a123b45'), ['12', '23', '45']);
    });
    test('matchesSkipping()', () {
      var parser = digit().seq(digit()).flatten();
      expect(parser.matchesSkipping('a123b45'), ['12', '45']);
    });
  });
  group('examples', () {
    final IDENTIFIER = letter().seq(word().star()).flatten();
    final NUMBER = char('-').optional().seq(digit().plus())
        .seq(char('.').seq(digit().plus()).optional()).flatten();
    final STRING = char('"')
        .seq(char('"').neg().star()).seq(char('"')).flatten();
    final KEYWORD = string('return')
        .seq(whitespace().plus().flatten()).seq(IDENTIFIER.or(NUMBER).or(STRING))
        .map((list) => list.last);
    final JAVADOC = string('/**')
        .seq(string('*/').neg().star())
        .seq(string('*/'))
        .flatten();
    test('valid identifier', () {
      expectSuccess(IDENTIFIER, 'a', 'a');
      expectSuccess(IDENTIFIER, 'a1', 'a1');
      expectSuccess(IDENTIFIER, 'a12', 'a12');
      expectSuccess(IDENTIFIER, 'ab', 'ab');
      expectSuccess(IDENTIFIER, 'a1b', 'a1b');
    });
    test('incomplete identifier', () {
      expectSuccess(IDENTIFIER, 'a=', 'a', 1);
      expectSuccess(IDENTIFIER, 'a1-', 'a1', 2);
      expectSuccess(IDENTIFIER, 'a12+', 'a12', 3);
      expectSuccess(IDENTIFIER, 'ab ', 'ab', 2);
    });
    test('invalid identifier', () {
      expectFailure(IDENTIFIER, '', 0, 'letter expected');
      expectFailure(IDENTIFIER, '1', 0, 'letter expected');
      expectFailure(IDENTIFIER, '1a', 0, 'letter expected');
    });
    test('positive number', () {
      expectSuccess(NUMBER, '1', '1');
      expectSuccess(NUMBER, '12', '12');
      expectSuccess(NUMBER, '12.3', '12.3');
      expectSuccess(NUMBER, '12.34', '12.34');
    });
    test('negative number', () {
      expectSuccess(NUMBER, '-1', '-1');
      expectSuccess(NUMBER, '-12', '-12');
      expectSuccess(NUMBER, '-12.3', '-12.3');
      expectSuccess(NUMBER, '-12.34', '-12.34');
    });
    test('incomplete number', () {
      expectSuccess(NUMBER, '1..', '1', 1);
      expectSuccess(NUMBER, '12-', '12', 2);
      expectSuccess(NUMBER, '12.3.', '12.3', 4);
      expectSuccess(NUMBER, '12.34.', '12.34', 5);
    });
    test('invalid number', () {
      expectFailure(NUMBER, '', 0, 'digit expected');
      expectFailure(NUMBER, '-', 1, 'digit expected');
      expectFailure(NUMBER, '-x', 1, 'digit expected');
      expectFailure(NUMBER, '.', 0, 'digit expected');
      expectFailure(NUMBER, '.1', 0, 'digit expected');
    });
    test('valid string', () {
      expectSuccess(STRING, '""', '""');
      expectSuccess(STRING, '"a"', '"a"');
      expectSuccess(STRING, '"ab"', '"ab"');
      expectSuccess(STRING, '"abc"', '"abc"');
    });
    test('incomplete string', () {
      expectSuccess(STRING, '""x', '""', 2);
      expectSuccess(STRING, '"a"x', '"a"', 3);
      expectSuccess(STRING, '"ab"x', '"ab"', 4);
      expectSuccess(STRING, '"abc"x', '"abc"', 5);
    });
    test('invalid string', () {
      expectFailure(STRING, '"', 1, '" expected');
      expectFailure(STRING, '"a', 2, '" expected');
      expectFailure(STRING, '"ab', 3, '" expected');
      expectFailure(STRING, 'a"', 0, '" expected');
      expectFailure(STRING, 'ab"', 0, '" expected');
    });
    test('return statement', () {
      expectSuccess(KEYWORD, 'return f', 'f');
      expectSuccess(KEYWORD, 'return  f', 'f');
      expectSuccess(KEYWORD, 'return foo', 'foo');
      expectSuccess(KEYWORD, 'return    foo', 'foo');
      expectSuccess(KEYWORD, 'return 1', '1');
      expectSuccess(KEYWORD, 'return  1', '1');
      expectSuccess(KEYWORD, 'return -2.3', '-2.3');
      expectSuccess(KEYWORD, 'return    -2.3', '-2.3');
      expectSuccess(KEYWORD, 'return "a"', '"a"');
      expectSuccess(KEYWORD, 'return  "a"', '"a"');
    });
    test('invalid statement', () {
      expectFailure(KEYWORD, 'retur f', 0, 'return expected');
      expectFailure(KEYWORD, 'return1', 6, 'whitespace expected');
      expectFailure(KEYWORD, 'return  _', 8, '" expected');
    });
    test('javadoc', () {
      expectSuccess(JAVADOC, '/** foo */', '/** foo */');
      expectSuccess(JAVADOC, '/** * * */', '/** * * */');
    });
  });
  group('copying, matching, replacing', () {
    void verify(Parser parser) {
      var copy = parser.copy();
      // check copying
      expect(copy, isNot(same(parser)));
      expect(copy.toString(), parser.toString());
      expect(copy.runtimeType, parser.runtimeType);
      expect(copy.children, pairwiseCompare(parser.children, identical, 'same children'));
      // check equality
      expect(copy.equals(copy), isTrue);
      expect(parser.equals(parser), isTrue);
      expect(copy.equals(parser), isTrue);
      expect(parser.equals(copy), isTrue);
      // check replacing
      var replaced = new List();
      for (var i = 0; i < copy.children.length; i++) {
        var source = copy.children[i], target = any();
        copy.replace(source, target);
        expect(copy.children[i], same(target));
        replaced.add(target);
      }
      expect(copy.children, pairwiseCompare(replaced, identical, 'replaced children'));
    }
    test('any()', () => verify(any()));
    test('and()', () => verify(digit().and()));
    test('char()', () => verify(char('a')));
    test('digit()', () => verify(digit()));
    test('delegate()', () => verify(new DelegateParser(any())));
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
  group('regressions', () {
    test('flatten().trim()', () {
      var parser = word().plus().flatten().trim();
      expectSuccess(parser, 'ab1', 'ab1');
      expectSuccess(parser, ' ab1 ', 'ab1');
      expectSuccess(parser, '  ab1  ', 'ab1');
    });
    test('trim().flatten()', () {
      var parser = word().plus().trim().flatten();
      expectSuccess(parser, 'ab1', 'ab1');
      expectSuccess(parser, ' ab1 ', ' ab1 ');
      expectSuccess(parser, '  ab1  ', '  ab1  ');
    });
  });
  group('definition', () {
    var grammarDefinition = new ListGrammarDefinition();
    var parserDefinition = new ListParserDefinition();
    var tokenDefinition = new TokenizedListGrammarDefinition();
    test('reference without parameters', () {
      var firstReference = grammarDefinition.ref(grammarDefinition.start);
      var secondReference = grammarDefinition.ref(grammarDefinition.start);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different production', () {
      var firstReference = grammarDefinition.ref(grammarDefinition.start);
      var secondReference = grammarDefinition.ref(grammarDefinition.element);
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
    });
    test('reference with same parameters', () {
      var firstReference = grammarDefinition.ref(grammarDefinition.start, 'a');
      var secondReference = grammarDefinition.ref(grammarDefinition.start, 'a');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isTrue);
    });
    test('reference with different parameters', () {
      var firstReference = grammarDefinition.ref(grammarDefinition.start, 'a');
      var secondReference = grammarDefinition.ref(grammarDefinition.start, 'b');
      expect(firstReference, isNot(same(secondReference)));
      expect(firstReference == secondReference, isFalse);
    });
    test('grammar', () {
      var parser = grammarDefinition.build();
      expectSuccess(parser, '1,2', ['1', ',', '2']);
      expectSuccess(parser, '1,2,3', ['1', ',', ['2', ',', '3']]);
    });
    test('parser', () {
      var parser = parserDefinition.build();
      expectSuccess(parser, '1,2', [1, ',', 2]);
      expectSuccess(parser, '1,2,3', [1, ',', [2, ',', 3]]);
    });
    test('token', () {
      var parser = tokenDefinition.build();
      expectSuccess(parser, '1, 2', ['1', ',', '2']);
      expectSuccess(parser, '1, 2, 3', ['1', ',', ['2', ',', '3']]);
    });
  });
  group('composite', () {
    test('start', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', char('a'));
      });
      expectSuccess(parser, 'a', 'a', 1);
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('circular', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', self.ref('loop').or(char('b')));
        self.def('loop', char('a').seq(self.ref('start')));
      });
      expect(parser.accept('b'), isTrue);
      expect(parser.accept('ab'), isTrue);
      expect(parser.accept('aab'), isTrue);
      expect(parser.accept('aaab'), isTrue);
    });
    test('redefine parser', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', char('b'));
        self.redef('start', char('a'));
      });
      expectSuccess(parser, 'a', 'a', 1);
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('redefine function', () {
      var parser = new PluggableCompositeParser((self) {
        var b = char('b');
        self.def('start', b);
        self.redef('start', (old) {
          expect(b, old);
          return char('a');
        });
      });
      expectSuccess(parser, 'a', 'a', 1);
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('define completed', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', char('a'));
      });
      expect(() => parser.def('other', char('b')), throws);
      expect(() => parser.redef('start', char('b')), throws);
      expect(() => parser.action('start', (each) => each), throws);
    });
    test('reference completed', () {
      var parsers = {
          'start': char('a'),
          'for_b': char('b'),
          'for_c': char('c')
      };
      var parser = new PluggableCompositeParser((self) {
        for (var key in parsers.keys) {
          self.def(key, parsers[key]);
        }
      });
      for (var key in parsers.keys) {
        expect(parsers[key], parser[key]);
        expect(parsers[key], parser.ref(key));
      }
    });
    test('reference unknown', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', char('a'));
      });
      try {
        parser.ref('star1');
        fail('Expected UndefinedProductionError to be thrown');
      } on UndefinedProductionError catch (error, stack) {
        expect(error.toString(), 'Undefined production: star1');
      }
    });
    test('duplicated start', () {
      new PluggableCompositeParser((self) {
        self.def('start', char('a'));
        try {
          self.def('start', char('b'));
          fail('Expected UndefinedProductionError to be thrown');
        } on RedefinedProductionError catch (error, stack) {
          expect(error.toString(), 'Redefined production: start');
        }
      });
    });
    test('undefined start', () {
      expect(() => new PluggableCompositeParser((self) { }), throws);
    });
    test('undefined redef', () {
      new PluggableCompositeParser((self) {
        self.def('start', char('a'));
        expect(() => self.redef('star1', char('b')), throws);
      });
    });
    test('example (lambda)', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', self.ref('expression').end());
        self.def('variable', letter().seq(word().star()).flatten().trim());
        self.def('expression', self.ref('variable')
            .or(self.ref('abstraction'))
            .or(self.ref('application')));
        self.def('abstraction', char('\\').trim()
            .seq(self.ref('variable'))
            .seq(char('.').trim())
            .seq(self.ref('expression')));
        self.def('application', char('(').trim()
            .seq(self.ref('expression'))
            .seq(self.ref('expression'))
            .seq(char(')').trim()));
      });
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
    test('example (expression)', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', self.ref('terms').end());
        self.def('terms', self.ref('addition')
            .or(self.ref('factors')));
        self.def('addition', self.ref('factors')
            .separatedBy(char('+').or(char('-')).trim()));
        self.def('factors', self.ref('multiplication')
            .or(self.ref('power')));
        self.def('multiplication', self.ref('power')
            .separatedBy(char('*').or(char('/')).trim()));
        self.def('power', self.ref('primary')
            .separatedBy(char('^').trim()));
        self.def('primary', self.ref('number')
            .or(self.ref('parentheses')));
        self.def('number', char('-').optional()
            .seq(digit().plus())
            .seq(char('.').seq(digit().plus()).optional())
            .flatten().trim());
        self.def('parentheses', char('(').trim()
            .seq(self.ref('terms'))
            .seq(char(')').trim()));
      });
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
    var root = failure().setable();
    var builder = new ExpressionBuilder();
    builder.group()
      ..primitive(char('(').trim()
          .seq(root)
          .seq(char(')').trim())
          .pick(1))
      ..primitive(digit().plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten().trim().map((a) => double.parse(a)));
    builder.group()
      ..prefix(char('-').trim(), (op, a) => -a);
    builder.group()
      ..postfix(string('++').trim(), (a, op) => ++a)
      ..postfix(string('--').trim(), (a, op) => --a);
    builder.group()
      ..right(char('^').trim(), (a, op, b) => math.pow(a, b));
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b);
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);
    root.set(builder.build());
    var parser = root.end();
    var epsilon = 1e-5;
    test('number', () {
      expect(parser.parse('0').value, closeTo(0, epsilon));
      expect(parser.parse('0.0').value, closeTo(0, epsilon));
      expect(parser.parse('1').value, closeTo(1, epsilon));
      expect(parser.parse('1.2').value, closeTo(1.2, epsilon));
      expect(parser.parse('34').value, closeTo(34, epsilon));
      expect(parser.parse('34.7').value, closeTo(34.7, epsilon));
      expect(parser.parse('56.78').value, closeTo(56.78, epsilon));
    });
    test('negative number', () {
      expect(parser.parse('-1').value, closeTo(-1, epsilon));
      expect(parser.parse('-1.2').value, closeTo(-1.2, epsilon));
    });
    test('add', () {
      expect(parser.parse('1 + 2').value, closeTo(3, epsilon));
      expect(parser.parse('2 + 1').value, closeTo(3, epsilon));
      expect(parser.parse('1 + 2.3').value, closeTo(3.3, epsilon));
      expect(parser.parse('2.3 + 1').value, closeTo(3.3, epsilon));
      expect(parser.parse('1 + -2').value, closeTo(-1, epsilon));
      expect(parser.parse('-2 + 1').value, closeTo(-1, epsilon));
    });
    test('add many', () {
      expect(parser.parse('1').value, closeTo(1, epsilon));
      expect(parser.parse('1 + 2').value, closeTo(3, epsilon));
      expect(parser.parse('1 + 2 + 3').value, closeTo(6, epsilon));
      expect(parser.parse('1 + 2 + 3 + 4').value, closeTo(10, epsilon));
      expect(parser.parse('1 + 2 + 3 + 4 + 5').value, closeTo(15, epsilon));
    });
    test('sub', () {
      expect(parser.parse('1 - 2').value, closeTo(-1, epsilon));
      expect(parser.parse('1.2 - 1.2').value, closeTo(0, epsilon));
      expect(parser.parse('1 - -2').value, closeTo(3, epsilon));
      expect(parser.parse('-1 - -2').value, closeTo(1, epsilon));
    });
    test('sub many', () {
      expect(parser.parse('1').value, closeTo(1, epsilon));
      expect(parser.parse('1 - 2').value, closeTo(-1, epsilon));
      expect(parser.parse('1 - 2 - 3').value, closeTo(-4, epsilon));
      expect(parser.parse('1 - 2 - 3 - 4').value, closeTo(-8, epsilon));
      expect(parser.parse('1 - 2 - 3 - 4 - 5').value, closeTo(-13, epsilon));
    });
    test('mul', () {
      expect(parser.parse('2 * 3').value, closeTo(6, epsilon));
      expect(parser.parse('2 * -4').value, closeTo(-8, epsilon));
    });
    test('mul many', () {
      expect(parser.parse('1 * 2').value, closeTo(2, epsilon));
      expect(parser.parse('1 * 2 * 3').value, closeTo(6, epsilon));
      expect(parser.parse('1 * 2 * 3 * 4').value, closeTo(24, epsilon));
      expect(parser.parse('1 * 2 * 3 * 4 * 5').value, closeTo(120, epsilon));
    });
    test('div', () {
      expect(parser.parse('12 / 3').value, closeTo(4, epsilon));
      expect(parser.parse('-16 / -4').value, closeTo(4, epsilon));
    });
    test('div many', () {
      expect(parser.parse('100 / 2').value, closeTo(50, epsilon));
      expect(parser.parse('100 / 2 / 2').value, closeTo(25, epsilon));
      expect(parser.parse('100 / 2 / 2 / 5').value, closeTo(5, epsilon));
      expect(parser.parse('100 / 2 / 2 / 5 / 5').value, closeTo(1, epsilon));
    });
    test('pow', () {
      expect(parser.parse('2 ^ 3').value, closeTo(8, epsilon));
      expect(parser.parse('-2 ^ 3').value, closeTo(-8, epsilon));
      expect(parser.parse('-2 ^ -3').value, closeTo(-0.125, epsilon));
    });
    test('pow many', () {
      expect(parser.parse('4 ^ 3').value, closeTo(64, epsilon));
      expect(parser.parse('4 ^ 3 ^ 2').value, closeTo(262144, epsilon));
      expect(parser.parse('4 ^ 3 ^ 2 ^ 1').value, closeTo(262144, epsilon));
      expect(parser.parse('4 ^ 3 ^ 2 ^ 1 ^ 0').value, closeTo(262144, epsilon));
    });
    test('parens', () {
      expect(parser.parse('(1)').value, closeTo(1, epsilon));
      expect(parser.parse('(1 + 2)').value, closeTo(3, epsilon));
      expect(parser.parse('((1))').value, closeTo(1, epsilon));
      expect(parser.parse('((1 + 2))').value, closeTo(3, epsilon));
      expect(parser.parse('2 * (3 + 4)').value, closeTo(14, epsilon));
      expect(parser.parse('(2 + 3) * 4').value, closeTo(20, epsilon));
      expect(parser.parse('6 / (2 + 4)').value, closeTo(1, epsilon));
      expect(parser.parse('(2 + 6) / 2').value, closeTo(4, epsilon));
    });
    test('priority', () {
      expect(parser.parse('2 * 3 + 4').value, closeTo(10, epsilon));
      expect(parser.parse('2 + 3 * 4').value, closeTo(14, epsilon));
      expect(parser.parse('6 / 3 + 4').value, closeTo(6, epsilon));
      expect(parser.parse('2 + 6 / 2').value, closeTo(5, epsilon));
    });
    test('postfix add', () {
      expect(parser.parse('0++').value, closeTo(1, epsilon));
      expect(parser.parse('0++++').value, closeTo(2, epsilon));
      expect(parser.parse('0++++++').value, closeTo(3, epsilon));
      expect(parser.parse('0+++1').value, closeTo(2, epsilon));
      expect(parser.parse('0+++++1').value, closeTo(3, epsilon));
      expect(parser.parse('0+++++++1').value, closeTo(4, epsilon));
    });
    test('postfix sub', () {
      expect(parser.parse('1--').value, closeTo(0, epsilon));
      expect(parser.parse('2----').value, closeTo(0, epsilon));
      expect(parser.parse('3------').value, closeTo(0, epsilon));
      expect(parser.parse('2---1').value, closeTo(0, epsilon));
      expect(parser.parse('3-----1').value, closeTo(0, epsilon));
      expect(parser.parse('4-------1').value, closeTo(0, epsilon));
    });
    test('prefix negate', () {
      expect(parser.parse('1').value, closeTo(1, epsilon));
      expect(parser.parse('-1').value, closeTo(-1, epsilon));
      expect(parser.parse('--1').value, closeTo(1, epsilon));
      expect(parser.parse('---1').value, closeTo(-1, epsilon));
    });
  });
  group('tutorial', () {
    test('simple grammar', () {
      var id = letter().seq(letter().or(digit()).star());
      var id1 = id.parse('yeah');
      var id2 = id.parse('f12');
      expect(id1.value, ['y', ['e', 'a', 'h']]);
      expect(id2.value, ['f', ['1', '2']]);
      var id3 = id.parse('123');
      expect(id3.message, 'letter expected');
      expect(id3.position, 0);
      expect(id.accept('foo'), isTrue);
      expect(id.accept('123'), isFalse);
    });
    test('different parsers', () {
      var id = letter().seq(word().star()).flatten();
      var matches = id.matchesSkipping('foo 123 bar4');
      expect(matches, ['foo', 'bar4']);
    });
    test('complicated grammar', () {
      var number = digit().plus().flatten().trim().map(int.parse);
      var term = undefined();
      var prod = undefined();
      var prim = undefined();
      term.set(prod.seq(char('+').trim()).seq(term).map((values) {
        return values[0] + values[2];
      }).or(prod));
      prod.set(prim.seq(char('*').trim()).seq(prod).map((values) {
        return values[0] * values[2];
      }).or(prim));
      prim.set(char('(').trim().seq(term).seq(char(')'.trim())).map((values) {
        return values[1];
      }).or(number));
      var start = term.end();
      expect(7, start.parse('1 + 2 * 3').value);
      expect(9, start.parse('(1 + 2) * 3').value);
    });
    test('composite grammar', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', self.ref('list').end());
        self.def('list', self.ref('element').separatedBy(char(','),
            includeSeparators: false));
        self.def('element', digit().plus().flatten());
      });
      expect(['1', '23', '456'], parser.parse('1,23,456').value);
    });
    test('composite parser', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', self.ref('list').end());
        self.def('list', self.ref('element').separatedBy(char(','),
            includeSeparators: false));
        self.def('element', digit().plus().flatten());
        self.action('element', (value) => int.parse(value));
      });
      expect([1, 23, 456], parser.parse('1,23,456').value);
    });
  });
}
