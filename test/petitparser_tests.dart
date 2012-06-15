// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('petitparser_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../lib/petitparser.dart');

void expectSuccess(Parser parser, Dynamic input, Dynamic expected, [int position]) {
  Result result = parser.parse(input);
  expect(result.isSuccess(), isTrue);
  expect(result.isFailure(), isFalse);
  expect(result.getResult(), recursivelyMatches(expected));
  expect(result.position, equals(position != null ? position : input.length));
}

void expectFailure(Parser parser, Dynamic input, [int position = 0, String message]) {
  Result result = parser.parse(input);
  expect(result.isFailure(), isTrue);
  expect(result.isSuccess(), isFalse);
  expect(result.position, equals(position));
  if (message != null) {
    expect(result.getMessage(), equals(message));
  }
}

main() {

  group('Parser -', () {
    test('And', () {
      Parser parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '');
    });
    test('Choice of two', () {
      Parser parser = char('a').or(char('b'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('Choice of three', () {
      Parser parser = char('a').or(char('b')).or(char('c'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd');
      expectFailure(parser, '');
    });
    test('End of input', () {
      Parser parser = char('a').end();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'aa', 1, 'end of input expected');
    });
    test('Epsilon', () {
      Parser parser = new EpsilonParser();
      expectSuccess(parser, '', null);
      expectSuccess(parser, 'a', null, 0);
    });
    test('Failure', () {
      Parser parser = new FailureParser('failure');
      expectFailure(parser, '', 0, 'failure');
      expectFailure(parser, 'a', 0, 'failure');
    });
    test('Flatten', () {
      Parser parser = digit().plus().flatten();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('Action', () {
      Parser parser = digit().map((String each) {
        return each.charCodeAt(0) - '0'.charCodeAt(0);
      });
      expectSuccess(parser, '1', 1);
      expectSuccess(parser, '4', 4);
      expectSuccess(parser, '9', 9);
      expectFailure(parser, '');
      expectFailure(parser, 'a');
    });
    test('Not', () {
      Parser parser = char('a').not('not a expected');
      expectFailure(parser, 'a', message: 'not a expected');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('Neg', () {
      Parser parser = digit().wrapper().neg('no digit expected');
      expectFailure(parser, '1', 0, 'no digit expected');
      expectFailure(parser, '9', 0, 'no digit expected');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, '', 0, 'input expected');
    });
    test('Optional', () {
      Parser parser = char('a').optional();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('Plus', () {
      Parser parser = char('a').plus();
      expectFailure(parser, '', message: 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('Times', () {
      Parser parser = char('a').times(2);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('Repeat', () {
      Parser parser = char('a').repeat(2, 3);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
    });
    test('Separated by', () {
      Parser parser = char('a').separatedBy(char('b'));
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'ab', ['a'], 1);
      expectSuccess(parser, 'aba', ['a', 'b', 'a']);
      expectSuccess(parser, 'abab', ['a', 'b', 'a'], 3);
      expectSuccess(parser, 'ababa', ['a', 'b', 'a', 'b', 'a']);
      expectSuccess(parser, 'ababab', ['a', 'b', 'a', 'b', 'a'], 5);
    });
    test('Sequence of two', () {
      Parser parser = char('a').seq(char('b'));
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('Sequence of three', () {
      Parser parser = char('a').seq(char('b')).seq(char('c'));
      expectSuccess(parser, 'abc', ['a', 'b', 'c']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
      expectFailure(parser, 'ab', 2);
      expectFailure(parser, 'abx', 2);
    });
    test('Star', () {
      Parser parser = char('a').star();
      expectSuccess(parser, '', []);
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('Trim', () {
      Parser parser = char('a').trim();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, ' a', 'a');
      expectSuccess(parser, 'a ', 'a');
      expectSuccess(parser, ' a ', 'a');
      expectSuccess(parser, '  a', 'a');
      expectSuccess(parser, 'a  ', 'a');
      expectSuccess(parser, '  a  ', 'a');
      expectFailure(parser, '', message: 'a expected');
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, ' b', 1, 'a expected');
      expectFailure(parser, '  b', 2, 'a expected');
    });
    test('Trim custom', () {
      Parser parser = char('a').trim(char('*'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '*a', 'a');
      expectSuccess(parser, 'a*', 'a');
      expectSuccess(parser, '*a*', 'a');
      expectSuccess(parser, '**a', 'a');
      expectSuccess(parser, 'a**', 'a');
      expectSuccess(parser, '**a**', 'a');
      expectFailure(parser, '', message: 'a expected');
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '*b', 1, 'a expected');
      expectFailure(parser, '**b', 2, 'a expected');
    });
    test('Wrapped', () {
      Parser parser = char('a').wrapper();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '');
    });
  });

  group('characters', () {

    test('char()', () {
      Parser parser = char('a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '');
    });
    test('char().neg()', () {
      Parser parser = char('a').neg();
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', message: 'no a expected');
      expectFailure(parser, '');
    });

    test('digit()', () {
      Parser parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', message: 'digit expected');
      expectFailure(parser, '');
    });
    test('digit().neg()', () {
      Parser parser = digit().neg();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, '0', message: 'no digit expected');
      expectFailure(parser, '');
    });

    test('letter()', () {
      Parser parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', message: 'letter expected');
      expectFailure(parser, '');
    });
    test('letter().neg()', () {
      Parser parser = letter().neg();
      expectSuccess(parser, '0', '0');
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, 'f', message: 'no letter expected');
      expectFailure(parser, '');
    });

    test('lowercase', () {
      Parser parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', message: 'lowercase letter expected');
      expectFailure(parser, '0', message: 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('lowercase().neg()', () {
      Parser parser = lowercase().neg();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, 'a', message: 'no lowercase letter expected');
      expectFailure(parser, 'z', message: 'no lowercase letter expected');
      expectFailure(parser, '');
    });

    test('pattern() with simple', () {
      Parser parser = pattern('abc');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', message: '[abc] expected');
      expectFailure(parser, '');
    });
    test('pattern() with range', () {
      Parser parser = pattern('a-c');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd', message: '[a-c] expected');
      expectFailure(parser, '');
    });
    test('pattern() with composed', () {
      Parser parser = pattern('ac-df-');
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'c', 'c');
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'f', 'f');
      expectSuccess(parser, '-', '-');
      expectFailure(parser, 'b', message: '[ac-df-] expected');
      expectFailure(parser, 'e', message: '[ac-df-] expected');
      expectFailure(parser, 'g', message: '[ac-df-] expected');
      expectFailure(parser, '');
    });
    test('pattern() with negation', () {
      Parser parser = pattern('^a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'a', message: '[^a] expected');
      expectFailure(parser, '');
    });

    test('range()', () {
      Parser parser = range('e', 'o');
      expectSuccess(parser, 'e', 'e');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectFailure(parser, 'p', message: 'e..o expected');
      expectFailure(parser, 'd', message: 'e..o expected');
      expectFailure(parser, '');
    });
    test('range().neg()', () {
      Parser parser = range('e', 'o').neg();
      expectSuccess(parser, 'd', 'd');
      expectSuccess(parser, 'p', 'p');
      expectFailure(parser, 'e', message: 'no e..o expected');
      expectFailure(parser, 'i', message: 'no e..o expected');
      expectFailure(parser, 'o', message: 'no e..o expected');
      expectFailure(parser, '');
    });

    test('uppercase()', () {
      Parser parser = uppercase();
      expectSuccess(parser, 'A', 'A');
      expectSuccess(parser, 'Z', 'Z');
      expectFailure(parser, 'a', message: 'uppercase letter expected');
      expectFailure(parser, '0', message: 'uppercase letter expected');
      expectFailure(parser, '');
    });
    test('uppercase().neg()', () {
      Parser parser = uppercase().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'z', 'z');
      expectFailure(parser, 'A', message: 'no uppercase letter expected');
      expectFailure(parser, 'Z', message: 'no uppercase letter expected');
      expectFailure(parser, '');
    });

    test('whitespace()', () {
      Parser parser = whitespace();
      expectSuccess(parser, ' ', ' ');
      expectSuccess(parser, '\t', '\t');
      expectSuccess(parser, '\r', '\r');
      expectSuccess(parser, '\f', '\f');
      expectFailure(parser, 'z', message: 'whitespace expected');
      expectFailure(parser, '');
    });
    test('whitespace().neg()', () {
      Parser parser = whitespace().neg();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, ' ', message: 'no whitespace expected');
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
      expectFailure(parser, '-', message: 'letter or digit expected');
      expectFailure(parser, '');
    });
    test('word().neg()', () {
      Parser parser = word().neg();
      expectSuccess(parser, '-', '-');
      expectSuccess(parser, '!', '!');
      expectFailure(parser, 'e', message: 'no letter or digit expected');
      expectFailure(parser, 'E', message: 'no letter or digit expected');
      expectFailure(parser, '5', message: 'no letter or digit expected');
      expectFailure(parser, '');
    });

  });

  group('Predicate -', () {
    test('Any', () {
      Parser parser = any();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, '', message: 'input expected');
    });
    test('Any In', () {
      Parser parser = anyIn(['a', 'b']);
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('String', () {
      Parser parser = string('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'fo');
      expectFailure(parser, 'Foo');
    });
    test('String ignore case', () {
      Parser parser = stringIgnoreCase('foo');
      expectSuccess(parser, 'foo', 'foo');
      expectSuccess(parser, 'FOO', 'FOO');
      expectSuccess(parser, 'fOo', 'fOo');
      expectFailure(parser, '');
      expectFailure(parser, 'f');
      expectFailure(parser, 'Fo');
    });

  });

  group('Parsing -', () {
    test('Parse', () {
      Parser parser = char('a');
      expect(parser.parse('a').isSuccess(), isTrue);
      expect(parser.parse('b').isSuccess(), isFalse);
    });
    test('Accept', () {
      Parser parser = char('a');
      expect(parser.accept('a'), isTrue);
      expect(parser.accept('b'), isFalse);
    });
    test('Matches', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(parser.matches('a123b45'), recursivelyMatches(['12', '23', '45']));
    });
    test('Matches skipping', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(parser.matchesSkipping('a123b45'), recursivelyMatches(['12', '45']));
    });
  });

  group('Examples -', () {
    final Parser IDENTIFIER = letter().seq(word().star()).flatten();
    final Parser NUMBER = char('-').optional().seq(digit().plus())
        .seq(char('.').seq(digit().plus()).optional()).flatten();
    final Parser STRING = char('"')
        .seq(char('"').neg().star()).seq(char('"')).flatten();
    final Parser RETURN = string('return')
        .seq(whitespace().plus().flatten()).seq(IDENTIFIER.or(NUMBER).or(STRING))
        .map((list) => list.last());
    final Parser JAVADOC = string('/**')
        .seq(string('*/').neg().star())
        .seq(string('*/'))
        .flatten();
    test('Valid identifier', () {
      expectSuccess(IDENTIFIER, 'a', 'a');
      expectSuccess(IDENTIFIER, 'a1', 'a1');
      expectSuccess(IDENTIFIER, 'a12', 'a12');
      expectSuccess(IDENTIFIER, 'ab', 'ab');
      expectSuccess(IDENTIFIER, 'a1b', 'a1b');
    });
    test('Incomplete identifier', () {
      expectSuccess(IDENTIFIER, 'a=', 'a', 1);
      expectSuccess(IDENTIFIER, 'a1-', 'a1', 2);
      expectSuccess(IDENTIFIER, 'a12+', 'a12', 3);
      expectSuccess(IDENTIFIER, 'ab ', 'ab', 2);
    });
    test('Invalid identifier', () {
      expectFailure(IDENTIFIER, '', 0, 'letter expected');
      expectFailure(IDENTIFIER, '1', 0, 'letter expected');
      expectFailure(IDENTIFIER, '1a', 0, 'letter expected');
    });
    test('Positive number', () {
      expectSuccess(NUMBER, '1', '1');
      expectSuccess(NUMBER, '12', '12');
      expectSuccess(NUMBER, '12.3', '12.3');
      expectSuccess(NUMBER, '12.34', '12.34');
    });
    test('Negative number', () {
      expectSuccess(NUMBER, '-1', '-1');
      expectSuccess(NUMBER, '-12', '-12');
      expectSuccess(NUMBER, '-12.3', '-12.3');
      expectSuccess(NUMBER, '-12.34', '-12.34');
    });
    test('Incomplete number', () {
      expectSuccess(NUMBER, '1..', '1', 1);
      expectSuccess(NUMBER, '12-', '12', 2);
      expectSuccess(NUMBER, '12.3.', '12.3', 4);
      expectSuccess(NUMBER, '12.34.', '12.34', 5);
    });
    test('Invalid number', () {
      expectFailure(NUMBER, '', 0, 'digit expected');
      expectFailure(NUMBER, '-', 1, 'digit expected');
      expectFailure(NUMBER, '-x', 1, 'digit expected');
      expectFailure(NUMBER, '.', 0, 'digit expected');
      expectFailure(NUMBER, '.1', 0, 'digit expected');
    });
    test('Valid string', () {
      expectSuccess(STRING, '""', '""');
      expectSuccess(STRING, '"a"', '"a"');
      expectSuccess(STRING, '"ab"', '"ab"');
      expectSuccess(STRING, '"abc"', '"abc"');
    });
    test('Incomplete string', () {
      expectSuccess(STRING, '""x', '""', 2);
      expectSuccess(STRING, '"a"x', '"a"', 3);
      expectSuccess(STRING, '"ab"x', '"ab"', 4);
      expectSuccess(STRING, '"abc"x', '"abc"', 5);
    });
    test('Invalid string', () {
      expectFailure(STRING, '"', 1, '" expected');
      expectFailure(STRING, '"a', 2, '" expected');
      expectFailure(STRING, '"ab', 3, '" expected');
      expectFailure(STRING, 'a"', 0, '" expected');
      expectFailure(STRING, 'ab"', 0, '" expected');
    });
    test('Return statement', () {
      expectSuccess(RETURN, 'return f', 'f');
      expectSuccess(RETURN, 'return  f', 'f');
      expectSuccess(RETURN, 'return foo', 'foo');
      expectSuccess(RETURN, 'return    foo', 'foo');
      expectSuccess(RETURN, 'return 1', '1');
      expectSuccess(RETURN, 'return  1', '1');
      expectSuccess(RETURN, 'return -2.3', '-2.3');
      expectSuccess(RETURN, 'return    -2.3', '-2.3');
      expectSuccess(RETURN, 'return "a"', '"a"');
      expectSuccess(RETURN, 'return  "a"', '"a"');
    });
    test('Invalid statement', () {
      expectFailure(RETURN, 'retur f', 0, 'return expected');
      expectFailure(RETURN, 'return1', 6, 'whitespace expected');
      expectFailure(RETURN, 'return  _', 8, '" expected');
    });
    test('Javadoc', () {
      expectSuccess(JAVADOC, '/** foo */', '/** foo */');
      expectSuccess(JAVADOC, '/** * * */', '/** * * */');
    });
  });

  group('Reflection - ', () {
    test('', () {});
  });

}
