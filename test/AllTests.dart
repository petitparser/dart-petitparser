// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('AllTests');

#import('dart:core');
#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../lib/PetitParser.dart');

void expectSuccess(Parser parser, Dynamic input, Dynamic expected, [int position]) {
  Result result = parser.parse(input);
  expect(result.isSuccess()).isTrue();
  expect(result.isFailure()).isFalse();
  expect(result.getResult()).equals(expected);
  expect(result.position).equals(position != null ? position : input.length);
}

void expectFailure(Parser parser, Dynamic input, [int position = 0, String message]) {
  Result result = parser.parse(input);
  expect(result.isFailure()).isTrue();
  expect(result.isSuccess()).isFalse();
  expect(result.position).equals(position);
  if (message != null) {
    expect(result.getMessage()).equals(message);
  }
}

main() {

  group('Parser', () {
    test('and', () {
      Parser parser = char('a').and();
      expectSuccess(parser, 'a', 'a', 0);
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '');
    });
    test('choice of two', () {
      Parser parser = char('a').or(char('b'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, 'c');
      expectFailure(parser, '');
    });
    test('choice of three', () {
      Parser parser = char('a').or(char('b')).or(char('c'));
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectSuccess(parser, 'c', 'c');
      expectFailure(parser, 'd');
      expectFailure(parser, '');
    });
    test('end of input', () {
      Parser parser = char('a').end();
      expectFailure(parser, '', 0, 'a expected');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'aa', 1, 'end of input expected');
    });
    test('flatten', () {
      Parser parser = digit().plus().flatten();
      expectFailure(parser, '');
      expectFailure(parser, 'a');
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '12', '12');
      expectSuccess(parser, '123', '123');
      expectSuccess(parser, '1234', '1234');
    });
    test('action', () {
      Parser parser = digit().map((String each) {
        return each.charCodeAt(0) - '0'.charCodeAt(0);
      });
      expectSuccess(parser, '1', 1);
      expectSuccess(parser, '4', 4);
      expectSuccess(parser, '9', 9);
      expectFailure(parser, '');
      expectFailure(parser, 'a');
    });
    test('not', () {
      Parser parser = char('a').not('not a expected');
      expectFailure(parser, 'a', message: 'not a expected');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('optional', () {
      Parser parser = char('a').optional();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', null, 0);
      expectSuccess(parser, '', null);
    });
    test('plus', () {
      Parser parser = char('a').plus();
      expectFailure(parser, '', message: 'a expected');
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('times', () {
      Parser parser = char('a').times(2);
      expectFailure(parser, '', 0, 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a'], 2);
    });
    test('repeat', () {
      Parser parser = char('a').repeat(2, 3);
      expectFailure(parser, '', message: 'a expected');
      expectFailure(parser, 'a', 1, 'a expected');
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
      expectSuccess(parser, 'aaaa', ['a', 'a', 'a'], 3);
    });
    test('sequence of two', () {
      Parser parser = char('a').seq(char('b'));
      expectSuccess(parser, 'ab', ['a', 'b']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
    });
    test('sequence of three', () {
      Parser parser = char('a').seq(char('b')).seq(char('c'));
      expectSuccess(parser, 'abc', ['a', 'b', 'c']);
      expectFailure(parser, '');
      expectFailure(parser, 'x');
      expectFailure(parser, 'a', 1);
      expectFailure(parser, 'ax', 1);
      expectFailure(parser, 'ab', 2);
      expectFailure(parser, 'abx', 2);
    });
    test('star', () {
      Parser parser = char('a').star();
      expectSuccess(parser, '', []);
      expectSuccess(parser, 'a', ['a']);
      expectSuccess(parser, 'aa', ['a', 'a']);
      expectSuccess(parser, 'aaa', ['a', 'a', 'a']);
    });
    test('trim', () {
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
    test('trim custom', () {
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
    test('wrapped', () {
      Parser parser = char('a').wrapped();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b', message: 'a expected');
      expectFailure(parser, '');
    });
    test('epsilon', () {
      Parser parser = new EpsilonParser();
      expectSuccess(parser, '', null);
      expectSuccess(parser, 'a', null, 0);
    });
    test('failure', () {
      Parser parser = new FailureParser('failure');
      expectFailure(parser, '', 0, 'failure');
      expectFailure(parser, 'a', 0, 'failure');
    });
  });

  group('Predicate', () {
    test('any', () {
      Parser parser = any();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'b', 'b');
      expectFailure(parser, '', message: 'input expected');
    });
    test('char', () {
      Parser parser = char('a');
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'b');
      expectFailure(parser, '');
    });
    test('digit', () {
      Parser parser = digit();
      expectSuccess(parser, '1', '1');
      expectSuccess(parser, '9', '9');
      expectFailure(parser, 'a', message: 'digit expected');
      expectFailure(parser, '');
    });
    test('letter', () {
      Parser parser = letter();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, 'X', 'X');
      expectFailure(parser, '0', message: 'letter expected');
      expectFailure(parser, '');
    });
    test('lowercase', () {
      Parser parser = lowercase();
      expectSuccess(parser, 'a', 'a');
      expectFailure(parser, 'A', message: 'lowercase letter expected');
      expectFailure(parser, '0', message: 'lowercase letter expected');
      expectFailure(parser, '');
    });
    test('range', () {
      Parser parser = range('e', 'o');
      expectFailure(parser, 'd', message: 'e..o expected');
      expectSuccess(parser, 'e', 'e');
      expectSuccess(parser, 'i', 'i');
      expectSuccess(parser, 'o', 'o');
      expectFailure(parser, 'p', message: 'e..o expected');
    });
    test('uppercase', () {
      Parser parser = uppercase();
      expectSuccess(parser, 'Z', 'Z');
      expectFailure(parser, 'z', message: 'uppercase letter expected');
      expectFailure(parser, '0', message: 'uppercase letter expected');
      expectFailure(parser, '');
    });
    test('whitespace', () {
      Parser parser = whitespace();
      expectSuccess(parser, ' ', ' ');
      expectFailure(parser, 'z', message: 'whitespace expected');
      expectFailure(parser, '-', message: 'whitespace expected');
      expectFailure(parser, '');
    });
    test('word', () {
      Parser parser = word();
      expectSuccess(parser, 'a', 'a');
      expectSuccess(parser, '0', '0');
      expectFailure(parser, '-', message: 'letter or digit expected');
      expectFailure(parser, '');
    });
  });

  group('Parsing', () {
    test('parse', () {
      Parser parser = char('a');
      expect(parser.parse('a').isSuccess()).isTrue();
      expect(parser.parse('b').isSuccess()).isFalse();
    });
    test('accept', () {
      Parser parser = char('a');
      expect(parser.accept('a')).isTrue();
      expect(parser.accept('b')).isFalse();
    });
    test('matches', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(['12', '23', '45']).equals(parser.matches('a123b45'));
    });
    test('matches skipping', () {
      Parser parser = digit().seq(digit()).flatten();
      expect(['12', '45']).equals(parser.matchesSkipping('a123b45'));
    });
  });

}