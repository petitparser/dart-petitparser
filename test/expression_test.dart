import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

Parser buildParser() {
  final builder = ExpressionBuilder<Object>();
  builder.primitive(digit()
      .plus()
      .seq(char('.').seq(digit().plus()).optional())
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
  builder.primitive(digit()
      .plus()
      .seq(char('.').seq(digit().plus()).optional())
      .flatten('number expected')
      .trim()
      .map(num.parse));
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
      expect(parser, isParseSuccess('1 + 2', result: ['1', '+', '2']));
      expect(
          parser,
          isParseSuccess('1 + 2 + 3', result: [
            ['1', '+', '2'],
            '+',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1 + 2', result: closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('2 + 1', result: closeTo(3, epsilon)));
      expect(
          evaluator, isParseSuccess('1 + 2.3', result: closeTo(3.3, epsilon)));
      expect(
          evaluator, isParseSuccess('2.3 + 1', result: closeTo(3.3, epsilon)));
      expect(evaluator, isParseSuccess('1 + -2', result: closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('-2 + 1', result: closeTo(-1, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1 + 2', result: closeTo(3, epsilon)));
      expect(
          evaluator, isParseSuccess('1 + 2 + 3', result: closeTo(6, epsilon)));
      expect(evaluator,
          isParseSuccess('1 + 2 + 3 + 4', result: closeTo(10, epsilon)));
      expect(evaluator,
          isParseSuccess('1 + 2 + 3 + 4 + 5', result: closeTo(15, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 +', message: 'end of input expected', position: 2));
      expect(
          evaluator,
          isParseFailure('1 + 2 +',
              message: 'end of input expected', position: 6));
    });
  });
  group('sub', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 - 2', result: ['1', '-', '2']));
      expect(
          parser,
          isParseSuccess('1 - 2 - 3', result: [
            ['1', '-', '2'],
            '-',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1 - 2', result: closeTo(-1, epsilon)));
      expect(
          evaluator, isParseSuccess('1.2 - 1.2', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('1 - -2', result: closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('-1 - -2', result: closeTo(1, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1 - 2', result: closeTo(-1, epsilon)));
      expect(
          evaluator, isParseSuccess('1 - 2 - 3', result: closeTo(-4, epsilon)));
      expect(evaluator,
          isParseSuccess('1 - 2 - 3 - 4', result: closeTo(-8, epsilon)));
      expect(evaluator,
          isParseSuccess('1 - 2 - 3 - 4 - 5', result: closeTo(-13, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 -', message: 'end of input expected', position: 2));
      expect(
          evaluator,
          isParseFailure('1 - 2 -',
              message: 'end of input expected', position: 6));
    });
  });
  group('mul', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 * 2', result: ['1', '*', '2']));
      expect(
          parser,
          isParseSuccess('1 * 2 * 3', result: [
            ['1', '*', '2'],
            '*',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('2 * 3', result: closeTo(6, epsilon)));
      expect(evaluator, isParseSuccess('2 * -4', result: closeTo(-8, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('1 * 2', result: closeTo(2, epsilon)));
      expect(
          evaluator, isParseSuccess('1 * 2 * 3', result: closeTo(6, epsilon)));
      expect(evaluator,
          isParseSuccess('1 * 2 * 3 * 4', result: closeTo(24, epsilon)));
      expect(evaluator,
          isParseSuccess('1 * 2 * 3 * 4 * 5', result: closeTo(120, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 *', message: 'end of input expected', position: 2));
      expect(
          evaluator,
          isParseFailure('1 * 2 *',
              message: 'end of input expected', position: 6));
    });
  });
  group('div', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 / 2', result: ['1', '/', '2']));
      expect(
          parser,
          isParseSuccess('1 / 2 / 3', result: [
            ['1', '/', '2'],
            '/',
            '3'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('12 / 3', result: closeTo(4, epsilon)));
      expect(
          evaluator, isParseSuccess('-16 / -4', result: closeTo(4, epsilon)));
    });
    test('evaluator many', () {
      expect(
          evaluator, isParseSuccess('100 / 2', result: closeTo(50, epsilon)));
      expect(evaluator,
          isParseSuccess('100 / 2 / 2', result: closeTo(25, epsilon)));
      expect(evaluator,
          isParseSuccess('100 / 2 / 2 / 5', result: closeTo(5, epsilon)));
      expect(evaluator,
          isParseSuccess('100 / 2 / 2 / 5 / 5', result: closeTo(1, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 /', message: 'end of input expected', position: 2));
      expect(
          evaluator,
          isParseFailure('1 / 2 /',
              message: 'end of input expected', position: 6));
    });
  });
  group('pow', () {
    test('parser', () {
      expect(parser, isParseSuccess('1 ^ 2', result: ['1', '^', '2']));
      expect(
          parser,
          isParseSuccess('1 ^ 2 ^ 3', result: [
            '1',
            '^',
            ['2', '^', '3']
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('2 ^ 3', result: closeTo(8, epsilon)));
      expect(evaluator, isParseSuccess('-2 ^ 3', result: closeTo(-8, epsilon)));
      expect(evaluator,
          isParseSuccess('-2 ^ -3', result: closeTo(-0.125, epsilon)));
    });
    test('evaluator many', () {
      expect(evaluator, isParseSuccess('4 ^ 3', result: closeTo(64, epsilon)));
      expect(evaluator,
          isParseSuccess('4 ^ 3 ^ 2', result: closeTo(262144, epsilon)));
      expect(evaluator,
          isParseSuccess('4 ^ 3 ^ 2 ^ 1', result: closeTo(262144, epsilon)));
      expect(
          evaluator,
          isParseSuccess('4 ^ 3 ^ 2 ^ 1 ^ 0',
              result: closeTo(262144, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('1 ^', message: 'end of input expected', position: 2));
      expect(
          evaluator,
          isParseFailure('1 ^ 2 ^',
              message: 'end of input expected', position: 6));
    });
  });
  group('parens', () {
    test('parser', () {
      expect(parser, isParseSuccess('(1)', result: ['(', '1', ')']));
      expect(
          parser,
          isParseSuccess('(1 + 2)', result: [
            '(',
            ['1', '+', '2'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('((1))', result: [
            '(',
            ['(', '1', ')'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('((1 + 2))', result: [
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
          isParseSuccess('2 * (3 + 4)', result: [
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
          isParseSuccess('(2 + 3) * 4', result: [
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
          isParseSuccess('6 / (2 + 4)', result: [
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
          isParseSuccess('(2 + 6) / 2', result: [
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
      expect(evaluator, isParseSuccess('(1)', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('(1 + 2)', result: closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('((1))', result: closeTo(1, epsilon)));
      expect(
          evaluator, isParseSuccess('((1 + 2))', result: closeTo(3, epsilon)));
      expect(evaluator,
          isParseSuccess('2 * (3 + 4)', result: closeTo(14, epsilon)));
      expect(evaluator,
          isParseSuccess('(2 + 3) * 4', result: closeTo(20, epsilon)));
      expect(evaluator,
          isParseSuccess('6 / (2 + 4)', result: closeTo(1, epsilon)));
      expect(evaluator,
          isParseSuccess('(2 + 6) / 2', result: closeTo(4, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('(', message: 'number expected'));
      expect(evaluator, isParseFailure('()', message: 'number expected'));
      expect(evaluator, isParseFailure('(1', message: 'number expected'));
      expect(evaluator, isParseFailure('((', message: 'number expected'));
      expect(evaluator, isParseFailure('((2', message: 'number expected'));
      expect(evaluator, isParseFailure('((2)', message: 'number expected'));
    });
  });
  group('sqrt', () {
    test('parser', () {
      expect(parser, isParseSuccess('sqrt(4)', result: ['sqrt(', '4', ')']));
      expect(
          parser,
          isParseSuccess('sqrt(1 + 3)', result: [
            'sqrt(',
            ['1', '+', '3'],
            ')'
          ]));
      expect(
          parser,
          isParseSuccess('1 + sqrt(16)', result: [
            '1',
            '+',
            ['sqrt(', '16', ')']
          ]));
      expect(
          parser,
          isParseSuccess('sqrt(sqrt(16))', result: [
            'sqrt(',
            ['sqrt(', '16', ')'],
            ')'
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('sqrt(4)', result: closeTo(2, epsilon)));
      expect(evaluator,
          isParseSuccess('sqrt(1 + 3)', result: closeTo(2, epsilon)));
      expect(evaluator,
          isParseSuccess('1 + sqrt(16)', result: closeTo(5, epsilon)));
      expect(evaluator,
          isParseSuccess('sqrt(sqrt(16))', result: closeTo(2, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('sqrt(', message: 'number expected'));
      expect(evaluator, isParseFailure('sqrt()', message: 'number expected'));
      expect(evaluator, isParseFailure('sqrt(1', message: 'number expected'));
      expect(
          evaluator, isParseFailure('sqrt(sqrt(', message: 'number expected'));
      expect(
          evaluator, isParseFailure('sqrt(sqrt(1', message: 'number expected'));
      expect(evaluator,
          isParseFailure('sqrt(sqrt(1)', message: 'number expected'));
    });
  });
  group('postfix add', () {
    test('parser', () {
      expect(parser, isParseSuccess('0++', result: ['0', '++']));
      expect(
          parser,
          isParseSuccess('0++++', result: [
            ['0', '++'],
            '++'
          ]));
      expect(
          parser,
          isParseSuccess('0++++++', result: [
            [
              ['0', '++'],
              '++'
            ],
            '++'
          ]));
      expect(
          parser,
          isParseSuccess('0+++1', result: [
            ['0', '++'],
            '+',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0+++++1', result: [
            [
              ['0', '++'],
              '++'
            ],
            '+',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0+++++++1', result: [
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
      expect(evaluator, isParseSuccess('0++', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('0++++', result: closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('0++++++', result: closeTo(3, epsilon)));
      expect(evaluator, isParseSuccess('0+++1', result: closeTo(2, epsilon)));
      expect(evaluator, isParseSuccess('0+++++1', result: closeTo(3, epsilon)));
      expect(
          evaluator, isParseSuccess('0+++++++1', result: closeTo(4, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('++', message: 'number expected'));
      expect(
          evaluator,
          isParseFailure('0+++',
              message: 'end of input expected', position: 3));
    });
  });
  group('postfix sub', () {
    test('parser', () {
      expect(parser, isParseSuccess('0--', result: ['0', '--']));
      expect(
          parser,
          isParseSuccess('0----', result: [
            ['0', '--'],
            '--'
          ]));
      expect(
          parser,
          isParseSuccess('0------', result: [
            [
              ['0', '--'],
              '--'
            ],
            '--'
          ]));
      expect(
          parser,
          isParseSuccess('0---1', result: [
            ['0', '--'],
            '-',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0-----1', result: [
            [
              ['0', '--'],
              '--'
            ],
            '-',
            '1'
          ]));
      expect(
          parser,
          isParseSuccess('0-------1', result: [
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
      expect(evaluator, isParseSuccess('1--', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('2----', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('3------', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('2---1', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('3-----1', result: closeTo(0, epsilon)));
      expect(
          evaluator, isParseSuccess('4-------1', result: closeTo(0, epsilon)));
    });
    test('error', () {
      expect(evaluator,
          isParseFailure('--', message: 'number expected', position: 2));
      expect(
          evaluator,
          isParseFailure('0---',
              message: 'end of input expected', position: 3));
    });
  });
  group('negate', () {
    test('parser', () {
      expect(parser, isParseSuccess('1', result: '1'));
      expect(parser, isParseSuccess('-1', result: ['-', '1']));
      expect(
          parser,
          isParseSuccess('--1', result: [
            '-',
            ['-', '1']
          ]));
      expect(
          parser,
          isParseSuccess('---1', result: [
            '-',
            [
              '-',
              ['-', '1']
            ]
          ]));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('1', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('-1', result: closeTo(-1, epsilon)));
      expect(evaluator, isParseSuccess('--1', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('---1', result: closeTo(-1, epsilon)));
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
      expect(parser, isParseSuccess('0', result: '0'));
      expect(parser, isParseSuccess('0.1', result: '0.1'));
      expect(parser, isParseSuccess('-1', result: ['-', '1']));
    });
    test('evaluator', () {
      expect(evaluator, isParseSuccess('0', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('0.0', result: closeTo(0, epsilon)));
      expect(evaluator, isParseSuccess('1', result: closeTo(1, epsilon)));
      expect(evaluator, isParseSuccess('1.2', result: closeTo(1.2, epsilon)));
      expect(evaluator, isParseSuccess('34', result: closeTo(34, epsilon)));
      expect(evaluator, isParseSuccess('34.7', result: closeTo(34.7, epsilon)));
      expect(
          evaluator, isParseSuccess('56.78', result: closeTo(56.78, epsilon)));
    });
    test('error', () {
      expect(evaluator, isParseFailure('', message: 'number expected'));
      expect(evaluator,
          isParseFailure('-', message: 'number expected', position: 1));
      expect(evaluator, isParseFailure('(', message: 'number expected'));
      expect(evaluator,
          isParseFailure('0.', message: 'end of input expected', position: 1));
    });
  });
  group('priority', () {
    test('parser', () {
      expect(
          parser,
          isParseSuccess('2 * 3 + 4', result: [
            ['2', '*', '3'],
            '+',
            '4'
          ]));
      expect(
          parser,
          isParseSuccess('2 + 3 * 4', result: [
            '2',
            '+',
            ['3', '*', '4']
          ]));
    });
    test('evaluator', () {
      expect(
          evaluator, isParseSuccess('2 * 3 + 4', result: closeTo(10, epsilon)));
      expect(
          evaluator, isParseSuccess('2 + 3 * 4', result: closeTo(14, epsilon)));
      expect(
          evaluator, isParseSuccess('6 / 3 + 4', result: closeTo(6, epsilon)));
      expect(
          evaluator, isParseSuccess('2 + 6 / 2', result: closeTo(5, epsilon)));
    });
  });
  group('builder', () {
    test('empty', () {
      final builder = ExpressionBuilder<String>();
      expect(
          builder.build,
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'At least one primitive parser expected')));
    }, skip: !hasAssertionsEnabled());
    test('no primitive', () {
      final builder = ExpressionBuilder<String>();
      builder.group().wrapper(char('('), char(')'), (l, v, r) => '[$v]');
      expect(
          builder.build,
          throwsA(isAssertionError.having((exception) => exception.message,
              'message', 'At least one primitive parser expected')));
    }, skip: !hasAssertionsEnabled());
    test('primitive on group', () {
      final builder = ExpressionBuilder<String>();
      // ignore: deprecated_member_use_from_same_package
      builder.group().primitive(char('a'));
      final parser = builder.build();
      expect(parser, isParseSuccess('a', result: 'a'));
    });
    group('epsilon', () {
      test('primitive', () {
        final builder = ExpressionBuilder<String>();
        builder
          ..primitive(noneOf('()'))
          ..primitive(epsilonWith('*'));
        builder.group().wrapper(char('('), char(')'), (_, v, __) => '[$v]');
        final parser = builder.build().end();
        expect(parser, isParseSuccess('', result: '*'));
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('(a)', result: '[a]'));
        expect(parser, isParseSuccess('((a))', result: '[[a]]'));
        expect(parser, isParseSuccess('()', result: '[*]'));
        expect(parser, isParseSuccess('(())', result: '[[*]]'));
      });
      test('left', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(any());
        builder.group().left(epsilonWith(null), (a, _, b) => '[$a$b]');
        final parser = builder.build().end();
        expect(parser, isParseFailure(''));
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('ab', result: '[ab]'));
        expect(parser, isParseSuccess('abc', result: '[[ab]c]'));
        expect(parser, isParseSuccess('abcd', result: '[[[ab]c]d]'));
      });
      test('right', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(any());
        builder.group().right(epsilonWith(null), (a, _, b) => '[$a$b]');
        final parser = builder.build().end();
        expect(parser, isParseFailure(''));
        expect(parser, isParseSuccess('a', result: 'a'));
        expect(parser, isParseSuccess('ab', result: '[ab]'));
        expect(parser, isParseSuccess('abc', result: '[a[bc]]'));
        expect(parser, isParseSuccess('abcd', result: '[a[b[cd]]]'));
      });
    });
    group('optional', () {
      test('basic', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(digit());
        builder.group()
          ..wrapper(char('('), char(')'), (_, v, __) => '($v)')
          ..optional('∅');
        final parser = builder.build().end();
        expect(parser, isParseSuccess('', result: '∅'));
        expect(parser, isParseSuccess('()', result: '(∅)'));
        expect(parser, isParseSuccess('1', result: '1'));
        expect(parser, isParseSuccess('(1)', result: '(1)'));
      });
      test('repeated', () {
        final builder = ExpressionBuilder<String>();
        final group = builder.group();
        group.optional('foo');
        expect(
            () => group.optional('bar'),
            throwsA(isAssertionError.having((exception) => exception.message,
                'message', 'At most one optional value expected')));
      }, skip: !hasAssertionsEnabled());
    });
  });
  group('examples', () {
    test('regex', () {
      final builder = ExpressionBuilder<String>();
      builder.primitive(noneOf(')'));
      builder.group()
        ..wrapper(char('('), char(')'), (_, value, __) => '($value)')
        ..prefix(char('!'), (_, value) => '!($value)')
        ..postfix(char('?'), (value, _) => '($value)?')
        ..left(char('|'), (left, _, right) => '($left|$right)')
        ..right(char('&'), (left, _, right) => '($left&$right)');
      builder.group()
        ..left(epsilonWith(null), (a, _, b) => '[$a$b]')
        ..optional('∅');
      final parser = builder.build().end();
      expect(parser, isParseSuccess('', result: '∅'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser, isParseSuccess('ab', result: '[ab]'));
      expect(parser, isParseSuccess('abc', result: '[[ab]c]'));
      expect(parser, isParseSuccess('a&b', result: '(a&b)'));
      expect(parser, isParseSuccess('a&b&c', result: '(a&(b&c))'));
      expect(parser, isParseSuccess('a|b', result: '(a|b)'));
      expect(parser, isParseSuccess('a|b|c', result: '((a|b)|c)'));
      expect(parser, isParseSuccess('a?', result: '(a)?'));
      expect(parser, isParseSuccess('a??', result: '((a)?)?'));
      expect(parser, isParseSuccess('!a', result: '!(a)'));
      expect(parser, isParseSuccess('!!a', result: '!(!(a))'));
      expect(parser, isParseSuccess('()', result: '(∅)'));
      expect(parser, isParseSuccess('(a)', result: '(a)'));
      expect(parser, isParseSuccess('(ab)', result: '([ab])'));
      expect(parser, isParseSuccess('(abc)', result: '([[ab]c])'));
    });
  });
  test('linter', () {
    expect(linter(parser), isEmpty);
    expect(linter(evaluator), isEmpty);
  });
}
