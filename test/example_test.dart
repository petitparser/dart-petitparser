import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import '../example/calc.dart';
import 'utils/checks.dart';

void main() {
  final identifier = letter().seq(word().star()).flatten();
  final number = char('-')
      .optional()
      .seq(digit().plus())
      .seq(char('.').seq(digit().plus()).optional())
      .flatten();
  final quoted = char('"').seq(char('"').neg().star()).seq(char('"')).flatten();
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
    check(identifier).parseSuccess('a', result: 'a');
    check(identifier).parseSuccess('a1', result: 'a1');
    check(identifier).parseSuccess('a12', result: 'a12');
    check(identifier).parseSuccess('ab', result: 'ab');
    check(identifier).parseSuccess('a1b', result: 'a1b');
  });
  test('incomplete identifier', () {
    check(identifier).parseSuccess('a=', result: 'a', position: 1);
    check(identifier).parseSuccess('a1-', result: 'a1', position: 2);
    check(identifier).parseSuccess('a12+', result: 'a12', position: 3);
    check(identifier).parseSuccess('ab ', result: 'ab', position: 2);
  });
  test('invalid identifier', () {
    check(identifier).parseFailure('', message: 'letter expected');
    check(identifier).parseFailure('1', message: 'letter expected');
    check(identifier).parseFailure('1a', message: 'letter expected');
  });
  test('positive number', () {
    check(number).parseSuccess('1', result: '1');
    check(number).parseSuccess('12', result: '12');
    check(number).parseSuccess('12.3', result: '12.3');
    check(number).parseSuccess('12.34', result: '12.34');
  });
  test('negative number', () {
    check(number).parseSuccess('-1', result: '-1');
    check(number).parseSuccess('-12', result: '-12');
    check(number).parseSuccess('-12.3', result: '-12.3');
    check(number).parseSuccess('-12.34', result: '-12.34');
  });
  test('incomplete number', () {
    check(number).parseSuccess('1..', result: '1', position: 1);
    check(number).parseSuccess('12-', result: '12', position: 2);
    check(number).parseSuccess('12.3.', result: '12.3', position: 4);
    check(number).parseSuccess('12.34.', result: '12.34', position: 5);
  });
  test('invalid number', () {
    check(number).parseFailure('', position: 0, message: 'digit expected');
    check(number).parseFailure('-', position: 1, message: 'digit expected');
    check(number).parseFailure('-x', position: 1, message: 'digit expected');
    check(number).parseFailure('.', message: 'digit expected');
    check(number).parseFailure('.1', message: 'digit expected');
  });
  test('valid string', () {
    check(quoted).parseSuccess('""', result: '""');
    check(quoted).parseSuccess('"a"', result: '"a"');
    check(quoted).parseSuccess('"ab"', result: '"ab"');
    check(quoted).parseSuccess('"abc"', result: '"abc"');
  });
  test('incomplete string', () {
    check(quoted).parseSuccess('""x', result: '""', position: 2);
    check(quoted).parseSuccess('"a"x', result: '"a"', position: 3);
    check(quoted).parseSuccess('"ab"x', result: '"ab"', position: 4);
    check(quoted).parseSuccess('"abc"x', result: '"abc"', position: 5);
  });
  test('invalid string', () {
    check(quoted).parseFailure('"', position: 1, message: '"\\"" expected');
    check(quoted).parseFailure('"a', position: 2, message: '"\\"" expected');
    check(quoted).parseFailure('"ab', position: 3, message: '"\\"" expected');
    check(quoted).parseFailure('a"', message: '"\\"" expected');
    check(quoted).parseFailure('ab"', message: '"\\"" expected');
  });
  test('return statement', () {
    check(keyword).parseSuccess('return f', result: 'f');
    check(keyword).parseSuccess('return  f', result: 'f');
    check(keyword).parseSuccess('return foo', result: 'foo');
    check(keyword).parseSuccess('return    foo', result: 'foo');
    check(keyword).parseSuccess('return 1', result: '1');
    check(keyword).parseSuccess('return  1', result: '1');
    check(keyword).parseSuccess('return -2.3', result: '-2.3');
    check(keyword).parseSuccess('return    -2.3', result: '-2.3');
    check(keyword).parseSuccess('return "a"', result: '"a"');
    check(keyword).parseSuccess('return  "a"', result: '"a"');
  });
  test('invalid statement', () {
    check(keyword).parseFailure('retur f', message: '"return" expected');
    check(keyword)
        .parseFailure('return1', position: 6, message: 'whitespace expected');
    check(keyword)
        .parseFailure('return  _', position: 8, message: '"\\"" expected');
  });
  test('javadoc', () {
    check(javadoc).parseSuccess('/** foo */', result: '/** foo */');
    check(javadoc).parseSuccess('/** * * */', result: '/** * * */');
  });
  test('multiline', () {
    check(multiLine).parseSuccess(r'"""abc"""', result: r'abc');
    check(multiLine).parseSuccess(r'"""abc\n"""', result: r'abc\n');
    check(multiLine).parseSuccess(r'"""abc\"""def"""', result: r'abc\"""def');
  });
  group('calc', () {
    final parser = buildParser();
    group('parse', () {
      test('integer', () {
        check(parser).parseSuccess('42', result: 42);
      });
      test('float', () {
        check(parser).parseSuccess('3.14', result: 3.14);
      });
      test('scientific notation', () {
        check(parser).parseSuccess('1.5e3', result: 1500);
        check(parser).parseSuccess('2.5E-2', result: 0.025);
      });
      test('negative number', () {
        check(parser).parseSuccess('-5', result: -5);
      });
      test('prefix negation', () {
        check(parser).parseSuccess('--5', result: 5);
      });
      test('parentheses', () {
        check(parser).parseSuccess('(42)', result: 42);
        check(parser).parseSuccess('((42))', result: 42);
      });
      test('addition', () {
        check(parser).parseSuccess('1 + 2', result: 3);
        check(parser).parseSuccess('1 + 2 + 3', result: 6);
      });
      test('subtraction', () {
        check(parser).parseSuccess('5 - 2', result: 3);
        check(parser).parseSuccess('10 - 3 - 2', result: 5);
      });
      test('multiplication', () {
        check(parser).parseSuccess('3 * 4', result: 12);
        check(parser).parseSuccess('2 * 3 * 4', result: 24);
      });
      test('division', () {
        check(parser).parseSuccess('12 / 3', result: 4);
        check(parser).parseSuccess('24 / 4 / 2', result: 3);
      });
      test('power', () {
        check(parser).parseSuccess('2 ^ 3', result: 8);
        check(parser).parseSuccess('2 ^ 2 ^ 3', result: 256);
      });
      test('precedence', () {
        check(parser).parseSuccess('1 + 2 * 3', result: 7);
        check(parser).parseSuccess('(1 + 2) * 3', result: 9);
        check(parser).parseSuccess('2 * 3 ^ 2', result: 18);
        check(parser).parseSuccess('-2 * (3 + 4)', result: -14);
      });
      test('whitespace', () {
        check(parser).parseSuccess('  1   +   2  ', result: 3);
      });
    });
    group('failure & caret position', () {
      void expectFailureWithCaret(
        String input,
        int expectedPosition,
        String expectedMessage,
      ) {
        check(parser).parseFailure(
          input,
          position: expectedPosition,
          message: expectedMessage,
        );
        final result = parser.parse(input);
        check(result).isA<Failure>();
        final failure = result as Failure;
        final caretLine = '${' ' * failure.position}^-- ${failure.message}';
        check(caretLine.indexOf('^')).equals(expectedPosition);
        check(caretLine)
            .equals('${' ' * expectedPosition}^-- $expectedMessage');
      }

      test('empty input', () {
        expectFailureWithCaret('', 0, 'number expected');
      });
      test('invalid character at start', () {
        expectFailureWithCaret('abc', 0, 'number expected');
      });
      test('leading space with invalid character', () {
        expectFailureWithCaret('  x', 2, 'number expected');
      });
      test('missing operand after operator', () {
        expectFailureWithCaret('1 + ', 2, 'end of input expected');
      });
      test('invalid trailing token', () {
        expectFailureWithCaret('1 + 2 x', 6, 'end of input expected');
      });
      test('unclosed parenthesis', () {
        expectFailureWithCaret('(1 + 2', 0, 'number expected');
      });
    });
  });
}
