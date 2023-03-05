import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

Parser buildParser() {
  final builder = ExpressionBuilder<Object>();
  builder.primitive(seq3(digit().plus(), cut(),
          seq3(char('.'), cut(), digit().plus()).optional())
      .flatten('number expected')
      .trim());
  builder.group()
    ..wrapper(char('(').trim(), char(')').trim(),
        (left, value, right) => [left, value, right])
    ..wrapper(string('sqrt(').trim(), char(')').trim(),
        (left, value, right) => [left, value, right]);
  builder.group().prefix(char('-').trim(), (op, a) => [op, a]);
  builder.group()
    ..postfix(string('++').trim(), (a, op) => [a, op])
    ..postfix(string('--').trim(), (a, op) => [a, op]);
  builder.group().right(char('^').trim(), (a, op, b) => [a, op, b]);
  builder.group()
    ..left(char('*').trim(), (a, op, b) => [a, op, b])
    ..left(char('/').trim(), (a, op, b) => [a, op, b]);
  builder.group()
    ..left(char('+').trim(), (a, op, b) => [a, op, b])
    ..left(char('-').trim(), (a, op, b) => [a, op, b]);
  return builder.build().end();
}

Parser<num> buildEvaluator() {
  final builder = ExpressionBuilder<num>();
  builder.primitive(seq3(digit().plus(), cut(),
          seq3(char('.'), cut(), digit().plus()).optional())
      .flatten('number expected')
      .map(num.parse)
      .trim());
  builder.group()
    ..wrapper(char('(').trim(), char(')').trim(), (left, value, right) => value)
    ..wrapper(string('sqrt(').trim(), char(')').trim(),
        (left, value, right) => math.sqrt(value));
  builder.group().prefix(char('-').trim(), (op, a) => -a);
  builder.group()
    ..postfix(string('++').trim(), (a, op) => ++a)
    ..postfix(string('--').trim(), (a, op) => --a);
  builder.group().right(char('^').trim(), (a, op, b) => math.pow(a, b));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => a * b)
    ..left(char('/').trim(), (a, op, b) => a / b);
  builder.group()
    ..left(char('+').trim(), (a, op, b) => a + b)
    ..left(char('-').trim(), (a, op, b) => a - b);
  return builder.build().end();
}

void main() {
  const epsilon = 1e-5;
  final parser = buildParser();
  final evaluator = buildEvaluator();
  group('add', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 + 2', ['1', '+', '2']));
      expect(
          parser,
          isParseSuccess('1 + 2 + 3', [
            ['1', '+', '2'],
            '+',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1 + 2', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('2 + 1', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('1 + 2.3', closeTo(3.3, epsilon)));
      expect(evaluator, isParseSuccess('2.3 + 1', closeTo(3.3, epsilon)));
      expect(evaluator, isParseSuccess('1 + -2', closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('-2 + 1', closeTo(-1, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1 + 2', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('1 + 2 + 3', closeTo(6, epsilon)));
      expect(evaluator, isParseSuccess('1 + 2 + 3 + 4', closeTo(10, epsilon)));
      expect(
          evaluator, isParseSuccess('1 + 2 + 3 + 4 + 5', closeTo(15, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 +', message: 'number expected', position: 3));
      expect(evaluator,
          isParseFailure('1 + 2 +', message: 'number expected', position: 7));
    });
  });
  group('sub', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 - 2', ['1', '-', '2']));
      expect(
          parser,
          isParseSuccess('1 - 2 - 3', [
            ['1', '-', '2'],
            '-',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1 - 2', closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('1.2 - 1.2', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('1 - -2', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('-1 - -2', closeTo(1, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1 - 2', closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('1 - 2 - 3', closeTo(-4, epsilon)));
      expect(evaluator, isParseSuccess('1 - 2 - 3 - 4', closeTo(-8, epsilon)));
      expect(evaluator,
          isParseSuccess('1 - 2 - 3 - 4 - 5', closeTo(-13, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 -', message: 'number expected', position: 3));
      expect(evaluator,
          isParseFailure('1 - 2 -', message: 'number expected', position: 7));
    });
  });
  group('mul', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 * 2', ['1', '*', '2']));
      expect(
          parser,
          isParseSuccess('1 * 2 * 3', [
            ['1', '*', '2'],
            '*',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('2 * 3', closeTo(6, epsilon)));
      expect(evaluator, isParseSuccess('2 * -4', closeTo(-8, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1 * 2', closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('1 * 2 * 3', closeTo(6, epsilon)));
      expect(evaluator, isParseSuccess('1 * 2 * 3 * 4', closeTo(24, epsilon)));
      expect(evaluator,
          isParseSuccess('1 * 2 * 3 * 4 * 5', closeTo(120, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 *', message: 'number expected', position: 3));
      expect(evaluator,
          isParseFailure('1 * 2 *', message: 'number expected', position: 7));
    });
  });
  group('div', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 / 2', ['1', '/', '2']));
      expect(
          parser,
          isParseSuccess('1 / 2 / 3', [
            ['1', '/', '2'],
            '/',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('12 / 3', closeTo(4, epsilon)));
      expect(evaluator, isParseSuccess('-16 / -4', closeTo(4, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('100 / 2', closeTo(50, epsilon)));
      expect(evaluator, isParseSuccess('100 / 2 / 2', closeTo(25, epsilon)));
      expect(evaluator, isParseSuccess('100 / 2 / 2 / 5', closeTo(5, epsilon)));
      expect(evaluator,
          isParseSuccess('100 / 2 / 2 / 5 / 5', closeTo(1, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 /', message: 'number expected', position: 3));
      expect(evaluator,
          isParseFailure('1 / 2 /', message: 'number expected', position: 7));
    });
  });
  group('pow', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 ^ 2', ['1', '^', '2']));
      expect(
          parser,
          isParseSuccess('1 ^ 2 ^ 3', [
            '1',
            '^',
            ['2', '^', '3']
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('2 ^ 3', closeTo(8, epsilon)));
      expect(evaluator, isParseSuccess('-2 ^ 3', closeTo(-8, epsilon)));
      expect(evaluator, isParseSuccess('-2 ^ -3', closeTo(-0.125, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('4 ^ 3', closeTo(64, epsilon)));
      expect(evaluator, isParseSuccess('4 ^ 3 ^ 2', closeTo(262144, epsilon)));
      expect(
          evaluator, isParseSuccess('4 ^ 3 ^ 2 ^ 1', closeTo(262144, epsilon)));
      expect(evaluator,
          isParseSuccess('4 ^ 3 ^ 2 ^ 1 ^ 0', closeTo(262144, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 ^', message: 'number expected', position: 3));
      expect(evaluator,
          isParseFailure('1 ^ 2 ^', message: 'number expected', position: 7));
    });
  });
  group('parens', () {
    test('parser', () {
      expect(parser, isParseSuccess('(1)', ['(', '1', ')']));
      expect(
          parser,
          isParseSuccess('(1 + 2)', [
            '(',
            ['1', '+', '2'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('((1))', [
            '(',
            ['(', '1', ')'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('((1 + 2))', [
            '(',
            [
              '(',
              ['1', '+', '2'],
              ')'
            ],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('2 * (3 + 4)', [
            '2',
            '*',
            [
              '(',
              ['3', '+', '4'],
              ')'
            ]
          ]));
      expect(
          parser,
          isParseSuccess('(2 + 3) * 4', [
            [
              '(',
              ['2', '+', '3'],
              ')'
            ],
            '*',
            '4'
          ]));
      expect(
          parser,
          isParseSuccess('6 / (2 + 4)', [
            '6',
            '/',
            [
              '(',
              ['2', '+', '4'],
              ')'
            ]
          ]));
      expect(
          parser,
          isParseSuccess('(2 + 6) / 2', [
            [
              '(',
              ['2', '+', '6'],
              ')'
            ],
            '/',
            '2'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('(1)', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('(1 + 2)', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('((1))', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('((1 + 2))', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('2 * (3 + 4)', closeTo(14, epsilon)));
      expect(evaluator, isParseSuccess('(2 + 3) * 4', closeTo(20, epsilon)));
      expect(evaluator, isParseSuccess('6 / (2 + 4)', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('(2 + 6) / 2', closeTo(4, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('(', message: 'number expected', position: 1));
      expect(evaluator,
          isParseFailure('()', message: 'number expected', position: 1));
      expect(evaluator,
          isParseFailure('(1', message: '")" expected', position: 2));
      expect(evaluator,
          isParseFailure('((', message: 'number expected', position: 2));
      expect(evaluator,
          isParseFailure('((2', message: '")" expected', position: 3));
      expect(evaluator,
          isParseFailure('((2)', message: '")" expected', position: 4));
    });
  });
  group('sqrt', () {
    test('parser', () {
      expect(parser, isParseSuccess('sqrt(4)', ['sqrt(', '4', ')']));
      expect(
          parser,
          isParseSuccess('sqrt(1 + 3)', [
            'sqrt(',
            ['1', '+', '3'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('1 + sqrt(16)', [
            '1',
            '+',
            ['sqrt(', '16', ')']
          ]));
      expect(
          parser,
          isParseSuccess('sqrt(sqrt(16))', [
            'sqrt(',
            ['sqrt(', '16', ')'],
            ')'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('sqrt(4)', closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('sqrt(1 + 3)', closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('1 + sqrt(16)', closeTo(5, epsilon)));
      expect(evaluator, isParseSuccess('sqrt(sqrt(16))', closeTo(2, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('sqrt(', message: 'number expected', position: 5));
      expect(evaluator,
          isParseFailure('sqrt()', message: 'number expected', position: 5));
      expect(evaluator,
          isParseFailure('sqrt(1', message: '")" expected', position: 6));
      expect(
          evaluator,
          isParseFailure('sqrt(sqrt(',
              message: 'number expected', position: 10));
      expect(evaluator,
          isParseFailure('sqrt(sqrt(1', message: '")" expected', position: 11));
      expect(
          evaluator,
          isParseFailure('sqrt(sqrt(1)',
              message: '")" expected', position: 12));
    });
  });
  group('postfix add', () {
    test('parser', () {
      expect(parser, isParseSuccess('0++', ['0', '++']));
      expect(
          parser,
          isParseSuccess('0++++', [
            ['0', '++'],
            '++'
          ]));
      expect(
          parser,
          isParseSuccess('0++++++', [
            [
              ['0', '++'],
              '++'
            ],
            '++'
          ]));
      expect(
          parser,
          isParseSuccess('0+++1', [
            ['0', '++'],
            '+',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0+++++1', [
            [
              ['0', '++'],
              '++'
            ],
            '+',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0+++++++1', [
            [
              [
                ['0', '++'],
                '++'
              ],
              '++'
            ],
            '+',
            '1'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('0++', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('0++++', closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('0++++++', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('0+++1', closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('0+++++1', closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('0+++++++1', closeTo(4, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('++', message: 'number expected'));
      expect(evaluator,
          isParseFailure('0+++', message: 'number expected', position: 4));
    });
  });
  group('postfix sub', () {
    test('parser', () {
      expect(parser, isParseSuccess('0--', ['0', '--']));
      expect(
          parser,
          isParseSuccess('0----', [
            ['0', '--'],
            '--'
          ]));
      expect(
          parser,
          isParseSuccess('0------', [
            [
              ['0', '--'],
              '--'
            ],
            '--'
          ]));
      expect(
          parser,
          isParseSuccess('0---1', [
            ['0', '--'],
            '-',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0-----1', [
            [
              ['0', '--'],
              '--'
            ],
            '-',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0-------1', [
            [
              [
                ['0', '--'],
                '--'
              ],
              '--'
            ],
            '-',
            '1'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1--', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('2----', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('3------', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('2---1', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('3-----1', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('4-------1', closeTo(0, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('--', message: 'number expected', position: 2));
      expect(evaluator,
          isParseFailure('0---', message: 'number expected', position: 4));
    });
  });
  group('negate', () {
    test('parser', () {
      expect(parser, isParseSuccess('1', '1'));
      expect(parser, isParseSuccess('-1', ['-', '1']));
      expect(
          parser,
          isParseSuccess('--1', [
            '-',
            ['-', '1']
          ]));
      expect(
          parser,
          isParseSuccess('---1', [
            '-',
            [
              '-',
              ['-', '1']
            ]
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('-1', closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('--1', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('---1', closeTo(-1, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('-', message: 'number expected', position: 1));
      expect(evaluator,
          isParseFailure('--', message: 'number expected', position: 2));
      expect(evaluator,
          isParseFailure('+2', message: 'number expected', position: 0));
    });
  });
  group('number', () {
    test('parser', () {
      expect(parser, isParseSuccess('0', '0'));
      expect(parser, isParseSuccess('0.1', '0.1'));
      expect(parser, isParseSuccess('-1', ['-', '1']));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('0', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('0.0', closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('1', closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1.2', closeTo(1.2, epsilon)));
      expect(evaluator, isParseSuccess('34', closeTo(34, epsilon)));
      expect(evaluator, isParseSuccess('34.7', closeTo(34.7, epsilon)));
      expect(evaluator, isParseSuccess('56.78', closeTo(56.78, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('', message: 'number expected'));
      expect(evaluator,
          isParseFailure('-', message: 'number expected', position: 1));
      expect(evaluator,
          isParseFailure('0.', message: 'number expected', position: 0));
    });
  });
  group('priority', () {
    test('parser', () {
      expect(
          parser,
          isParseSuccess('2 * 3 + 4', [
            ['2', '*', '3'],
            '+',
            '4'
          ]));
      expect(
          parser,
          isParseSuccess('2 + 3 * 4', [
            '2',
            '+',
            ['3', '*', '4']
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('2 * 3 + 4', closeTo(10, epsilon)));
      expect(evaluator, isParseSuccess('2 + 3 * 4', closeTo(14, epsilon)));
      expect(evaluator, isParseSuccess('6 / 3 + 4', closeTo(6, epsilon)));
      expect(evaluator, isParseSuccess('2 + 6 / 2', closeTo(5, epsilon)));
    });
  });
  group('builder', () {
    test('empty', () {
      final builder = ExpressionBuilder<String>();
      expect(
          () => builder.build(),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'At least one primitive parser expected')));
    }, skip: !hasAssertionsEnabled());
    test('missing primitive', () {
      final builder = ExpressionBuilder<String>();
      builder.group().wrapper(char('('), char(')'), (l, v, r) => '[$v]');
      expect(
          () => builder.build(),
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'At least one primitive parser expected')));
    }, skip: !hasAssertionsEnabled());
    test('primitive', () {
      final builder = ExpressionBuilder<String>();
      builder.primitive(digit());
      builder.group().wrapper(char('('), char(')'), (l, v, r) => '[$v]');
      final parser = builder.build();
      expect(parser, isParseSuccess('2', '2'));
      expect(parser, isParseSuccess('(2)', '[2]'));
      expect(parser, isParseSuccess('((2))', '[[2]]'));
    });
  });
  test('linter', () {
    expect(linter(parser), isEmpty);
    expect(linter(evaluator), isEmpty);
  });
}
