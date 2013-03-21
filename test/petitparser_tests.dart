// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library petitparser_tests;

import 'package:petitparser/petitparser.dart';
import 'package:unittest/unittest.dart';

void expectSuccess(Parser parser, dynamic input, dynamic expected, [int position]) {
  var result = parser.parse(input);
  expect(result.isSuccess, isTrue);
  expect(result.isFailure, isFalse);
  expect(result.result, expected);
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

class PluggableCompositeParser extends CompositeParser {
  Function _function;
  PluggableCompositeParser(this._function) : super();
  void initialize() => _function(this);
}

main() {

  group('parsers', () {
    test('and()', () {
      var parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', 0, 'a expected');
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
      var parser = digit().plus().flatten().token().trim();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      var token = parser.parse('  123 ').result;
      expect(token.length, 3);
      expect(token.start, 2);
      expect(token.stop, 5);
      expect(token.value, '123');
      expect(token.toString(), 'Token[start: 2, stop: 5, value: 123]');
    });
    test('token() line', () {
      var parser = any().token().star().map((list) => list.map((token) => token.line));
      expect(parser.parse('1\r12\r\n123\n1234').result,
             [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]);
    });
    test('token() column', () {
      var parser = any().token().star().map((list) => list.map((token) => token.column));
      expect(parser.parse('1\r12\r\n123\n1234').result,
             [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]);
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
      expectFailure(parser, '', 0, 'no digit expected');
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
    test('char().neg()', () {
      var parser = char('a').neg();
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, 'no a expected');
      expectFailure(parser, '');
    });
    test('digit()', () {
      var parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, '');
    });
    test('digit().neg()', () {
      var parser = digit().neg();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, '0', 0, 'no digit expected');
      expectFailure(parser, '');
    });
    test('letter()', () {
      var parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', 0, 'letter expected');
      expectFailure(parser, '');
    });
    test('letter().neg()', () {
      var parser = letter().neg();
      expectSuccess(parser, '0', '0');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, 'f', 0, 'no letter expected');
      expectFailure(parser, '');
    });
    test('lowercase', () {
      var parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'lowercase letter expected');
      expectFailure(parser, '0', 0, 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('lowercase().neg()', () {
      var parser = lowercase().neg();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, 'a', 0, 'no lowercase letter expected');
      expectFailure(parser, 'z', 0, 'no lowercase letter expected');
      expectFailure(parser, '');
    });
    test('pattern() with simple', () {
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
    test('pattern() with negation', () {
      var parser = pattern('^a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, '[^a] expected');
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
    test('range().neg()', () {
      var parser = range('e', 'o').neg();
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'p', 'p');
      expectFailure(parser, 'e', 0, 'no e..o expected');
      expectFailure(parser, 'i', 0, 'no e..o expected');
      expectFailure(parser, 'o', 0, 'no e..o expected');
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
    test('uppercase().neg()', () {
      var parser = uppercase().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'no uppercase letter expected');
      expectFailure(parser, 'Z', 0, 'no uppercase letter expected');
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
    test('whitespace().neg()', () {
      var parser = whitespace().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, ' ', 0, 'no whitespace expected');
      expectFailure(parser, '');
    });
    test('word()', () {
      var parser = word();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectSuccess(parser, '0', '0');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, '-', 0, 'letter or digit expected');
      expectFailure(parser, '');
    });
    test('word().neg()', () {
      var parser = word().neg();
      expectSuccess(parser, '-', '-');
      expectSuccess(parser, '!', '!');
      expectFailure(parser, 'e', 0, 'no letter or digit expected');
      expectFailure(parser, 'E', 0, 'no letter or digit expected');
      expectFailure(parser, '5', 0, 'no letter or digit expected');
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
  group('reflection', () {
    test('iterator single', () {
      var parser1 = lowercase();
      var parsers = new ParserIterable(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('iterator nested', () {
      var parser3 = lowercase();
      var parser2 = parser3.star();
      var parser1 = parser2.flatten();
      var parsers = new ParserIterable(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('iterator branched', () {
      var parser3 = lowercase();
      var parser2 = uppercase();
      var parser1 = parser2.seq(parser3);
      var parsers = new ParserIterable(parser1).toList();
      expect(parsers, [parser1, parser3, parser2]);
    });
    test('iterator looping', () {
      var parser1 = undefined();
      var parser2 = undefined();
      var parser3 = undefined();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      var parsers = new ParserIterable(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('iterator basic', () {
      var parser1 = lowercase();
      var iterator = new ParserIterator(parser1);
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, parser1);
      expect(iterator.current, parser1);
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isFalse);
    });
    test('remove setables', () {
      var parser2 = lowercase();
      var parser1 = parser2.setable();
      var root = Transformations.removeSetables(parser1);
      expect(root, parser2);
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
        Parser b = char('b');
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
        expect(parsers[key], parser.ref(key));
      }
    });
    test('reference unknown', () {
      var parser = new PluggableCompositeParser((self) {
        self.def('start', char('a'));
      });
      expect(() => parser.ref('star1'), throwsStateError);
    });
    test('duplicated start', () {
      new PluggableCompositeParser((self) {
        self.def('start', char('a'));
        expect(() => self.def('start', char('b')), throwsStateError);
      });
    });
    test('undefined start', () {
      expect(() => new PluggableCompositeParser((self) { }), throwsStateError);
    });
    test('undefined redef', () {
      new PluggableCompositeParser((self) {
        self.def('start', char('a'));
        expect(() => self.redef('star1', char('b')), throwsStateError);
      });
    });
  });
  group('tutorial', () {
    test('simple grammar', () {
      var id = letter().seq(letter().or(digit()).star());
      var id1 = id.parse('yeah');
      var id2 = id.parse('f12');
      expect(id1.result, ['y', ['e', 'a', 'h']]);
      expect(id2.result, ['f', ['1', '2']]);
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
      expect(7, start.parse('1 + 2 * 3').result);
      expect(9, start.parse('(1 + 2) * 3').result);
    });
  });

}
