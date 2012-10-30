// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

library petitparser_tests;

import 'package:petitparser/petitparser.dart';
import 'package:unittest/unittest.dart';

void expectSuccess(Parser parser, dynamic input, dynamic expected, [int position]) {
  Result result = parser.parse(input);
  expect(result.isSuccess(), isTrue);
  expect(result.isFailure(), isFalse);
  expect(result.result, expected);
  expect(result.position, position != null ? position : input.length);
}

void expectFailure(Parser parser, dynamic input, [int position = 0, String message]) {
  Result result = parser.parse(input);
  expect(result.isFailure(), isTrue);
  expect(result.isSuccess(), isFalse);
  expect(result.position, position);
  if (message != null) {
    expect(result.message, message);
  }
}

main() {

  group('parsers', () {
    test('and()', () {
      Parser parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('or() of two', () {
      Parser parser = char('a').or(char('b'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('or() of three', () {
      Parser parser = char('a').or(char('b')).or(char('c'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd');
      expectFailure(parser, '');
    });
    test('end()', () {
      Parser parser = char('a').end();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'aa', 1, 'end of input expected');
    });
    test('epsilon()', () {
      Parser parser = epsilon();
      expectSuccess(parser, '', null);
      expectSuccess(parser, 'a', null, 0);
    });
    test('failure()', () {
      Parser parser = failure('failure');
      expectFailure(parser, '', 0, 'failure');
      expectFailure(parser, 'a', 0, 'failure');
    });
    test('flatten()', () {
      Parser parser = digit().plus().flatten();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('token()', () {
      Parser parser = digit().plus().token().trim();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      Token token = parser.parse('  123 ').result;
      expect(token.length, 3);
      expect(token.start, 2);
      expect(token.stop, 5);
      expect(token.value, '123');
      expect(token.toString(), 'Token[start: 2, stop: 5, value: 123]');
    });
    test('token() line', () {
      Parser parser = any().token().star().map((List list) => list.map((Token token) => token.line));
      expect(parser.parse('1\r12\r\n123\n1234').result,
             [1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4]);
    });
    test('token() column', () {
      Parser parser = any().token().star().map((list) => list.map((token) => token.column));
      expect(parser.parse('1\r12\r\n123\n1234').result,
             [1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]);
    });
    test('action()', () {
      Parser parser = digit().map((String each) {
        return each.charCodeAt(0) - '0'.charCodeAt(0);
      });
      expectSuccess(parser, '1', 1);
      expectSuccess(parser, '4', 4);
      expectSuccess(parser, '9', 9);
      expectFailure(parser, '');
      expectFailure(parser, 'a');
    });
    test('not()', () {
      Parser parser = char('a').not('not a expected');
      expectFailure(parser, 'a', 0, 'not a expected');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('neg()', () {
      Parser parser = digit().wrapper().neg('no digit expected');
      expectFailure(parser, '1', 0, 'no digit expected');
      expectFailure(parser, '9', 0, 'no digit expected');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('optional()', () {
      Parser parser = char('a').optional();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('plus()', () {
      Parser parser = char('a').plus();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('times()', () {
      Parser parser = char('a').times(2);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('repeat()', () {
      Parser parser = char('a').repeat(2, 3);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
    });
    test('separatedBy()', () {
      Parser parser = char('a').separatedBy(char('b'));
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a'], 5);
    });
    test('seq() of two', () {
      Parser parser = char('a').seq(char('b'));
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('seq() of three', () {
      Parser parser = char('a').seq(char('b')).seq(char('c'));
      expectSuccess(parser, 'abc', ['a', 'b', 'c']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
      expectFailure(parser, 'ab', 2);
      expectFailure(parser, 'abx', 2);
    });
    test('star()', () {
      Parser parser = char('a').star();
      expectSuccess(parser, '', []);
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('trim()', () {
      Parser parser = char('a').trim();
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
      Parser parser = char('a').trim(char('*'));
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
    test('wrapped()', () {
      Parser parser = char('a').wrapper();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
  });

  group('characters', () {
    test('char()', () {
      Parser parser = char('a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', 0, 'a expected');
      expectFailure(parser, '');
    });
    test('char().neg()', () {
      Parser parser = char('a').neg();
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, 'no a expected');
      expectFailure(parser, '');
    });
    test('digit()', () {
      Parser parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', 0, 'digit expected');
      expectFailure(parser, '');
    });
    test('digit().neg()', () {
      Parser parser = digit().neg();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, '0', 0, 'no digit expected');
      expectFailure(parser, '');
    });
    test('letter()', () {
      Parser parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', 0, 'letter expected');
      expectFailure(parser, '');
    });
    test('letter().neg()', () {
      Parser parser = letter().neg();
      expectSuccess(parser, '0', '0');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, 'f', 0, 'no letter expected');
      expectFailure(parser, '');
    });
    test('lowercase', () {
      Parser parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'lowercase letter expected');
      expectFailure(parser, '0', 0, 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('lowercase().neg()', () {
      Parser parser = lowercase().neg();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, 'a', 0, 'no lowercase letter expected');
      expectFailure(parser, 'z', 0, 'no lowercase letter expected');
      expectFailure(parser, '');
    });
    test('pattern() with simple', () {
      Parser parser = pattern('abc');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[abc] expected');
      expectFailure(parser, '');
    });
    test('pattern() with range', () {
      Parser parser = pattern('a-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', 0, '[a-c] expected');
      expectFailure(parser, '');
    });
    test('pattern() with composed', () {
      Parser parser = pattern('ac-df-');
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
      Parser parser = pattern('^a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', 0, '[^a] expected');
      expectFailure(parser, '');
    });
    test('range()', () {
      Parser parser = range('e', 'o');
      expectSuccess(parser, 'e', 'e');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectFailure(parser, 'p', 0, 'e..o expected');
      expectFailure(parser, 'd', 0, 'e..o expected');
      expectFailure(parser, '');
    });
    test('range().neg()', () {
      Parser parser = range('e', 'o').neg();
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'p', 'p');
      expectFailure(parser, 'e', 0, 'no e..o expected');
      expectFailure(parser, 'i', 0, 'no e..o expected');
      expectFailure(parser, 'o', 0, 'no e..o expected');
      expectFailure(parser, '');
    });
    test('uppercase()', () {
      Parser parser = uppercase();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectFailure(parser, 'a', 0, 'uppercase letter expected');
      expectFailure(parser, '0', 0, 'uppercase letter expected');
      expectFailure(parser, '');
    });
    test('uppercase().neg()', () {
      Parser parser = uppercase().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', 0, 'no uppercase letter expected');
      expectFailure(parser, 'Z', 0, 'no uppercase letter expected');
      expectFailure(parser, '');
    });
    test('whitespace()', () {
      Parser parser = whitespace();
      expectSuccess(parser, ' ', ' ');
      expectSuccess(parser, '\t', '\t');
      expectSuccess(parser, '\r', '\r');
      expectSuccess(parser, '\f', '\f');
      expectFailure(parser, 'z', 0, 'whitespace expected');
      expectFailure(parser, '');
    });
    test('whitespace().neg()', () {
      Parser parser = whitespace().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, ' ', 0, 'no whitespace expected');
      expectFailure(parser, '');
    });
    test('word()', () {
      Parser parser = word();
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
      Parser parser = word().neg();
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
      Parser parser = any();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('anyIn()', () {
      Parser parser = anyIn(['a', 'b']);
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('string()', () {
      Parser parser = string('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'fo');
      expectFailure(parser, 'Foo');
    });
    test('stringIgnoreCase()', () {
      Parser parser = stringIgnoreCase('foo');
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
      Parser parser = char('a');
      expect(parser.parse('a').isSuccess(), isTrue);
      expect(parser.parse('b').isSuccess(), isFalse);
    });
    test('accept()', () {
      Parser parser = char('a');
      expect(parser.accept('a'), isTrue);
      expect(parser.accept('b'), isFalse);
    });
    test('matches()', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(parser.matches('a123b45'), ['12', '23', '45']);
    });
    test('matchesSkipping()', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(parser.matchesSkipping('a123b45'), ['12', '45']);
    });
  });
  group('examples', () {
    final Parser IDENTIFIER = letter().seq(word().star()).flatten();
    final Parser NUMBER = char('-').optional().seq(digit().plus())
        .seq(char('.').seq(digit().plus()).optional()).flatten();
    final Parser STRING = char('"')
        .seq(char('"').neg().star()).seq(char('"')).flatten();
    final Parser KEYWORD = string('return')
        .seq(whitespace().plus().flatten()).seq(IDENTIFIER.or(NUMBER).or(STRING))
        .map((list) => list.last);
    final Parser JAVADOC = string('/**')
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
      var parsers = new List.from(new ParserIterable(parser1));
      expect(parsers, [parser1]);
    });
    test('iterator nested', () {
      var parser3 = lowercase();
      var parser2 = parser3.star();
      var parser1 = parser2.flatten();
      var parsers = new List.from(new ParserIterable(parser1));
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('iterator branched', () {
      var parser3 = lowercase();
      var parser2 = uppercase();
      var parser1 = parser2.seq(parser3);
      var parsers = new List.from(new ParserIterable(parser1));
      expect(parsers, [parser1, parser3, parser2]);
    });
    test('iterator looping', () {
      var parser1 = new WrapperParser(null);
      var parser2 = new WrapperParser(null);
      var parser3 = new WrapperParser(null);
      parser1.replace(null, parser2);
      parser2.replace(null, parser3);
      parser3.replace(null, parser1);
      var parsers = new List.from(new ParserIterable(parser1));
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('iterator over end', () {
      var parser1 = lowercase();
      var iterator = new ParserIterator(parser1);
      expect(iterator.next(), parser1);
      expect(iterator.hasNext, isFalse);
      expect(() => iterator.next(), throws);
    });
    test('remove wrappers', () {
      var parser2 = lowercase();
      var parser1 = parser2.wrapper();
      var root = Transformations.removeWrappers(parser1);
      expect(root, parser2);
    });
  });

}
