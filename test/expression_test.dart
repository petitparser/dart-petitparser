import 'dart:math' as math;

import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

Parser buildParser() {
  final builder = ExpressionBuilder<Object>();
  builder.primitive(
    digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten(message: 'number expected')
        .trim(),
  );
  builder.group()
    ..wrapper(
      char('(').trim(),
      char(')').trim(),
      (left, value, right) => [left, value, right],
    )
    ..wrapper(
      string('sqrt(').trim(),
      char(')').trim(),
      (left, value, right) => [left, value, right],
    );
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
  builder.primitive(
    digit()
        .plus()
        .seq(char('.').seq(digit().plus()).optional())
        .flatten(message: 'number expected')
        .trim()
        .map(num.parse),
  );
  builder.group()
    ..wrapper(char('(').trim(), char(')').trim(), (left, value, right) => value)
    ..wrapper(
      string('sqrt(').trim(),
      char(')').trim(),
      (left, value, right) => math.sqrt(value),
    );
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
      check(parser).parseSuccess('1 + 2', result: ['1', '+', '2']);
      check(parser).parseSuccess(
        '1 + 2 + 3',
        result: [
          ['1', '+', '2'],
          '+',
          '3',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('1 + 2', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('2 + 1', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('1 + 2.3', result: closeTo(3.3, epsilon));
      check(evaluator).parseSuccess('2.3 + 1', result: closeTo(3.3, epsilon));
      check(evaluator).parseSuccess('1 + -2', result: closeTo(-1, epsilon));
      check(evaluator).parseSuccess('-2 + 1', result: closeTo(-1, epsilon));
    });
    test('evaluator many', () {
      check(evaluator).parseSuccess('1', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('1 + 2', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('1 + 2 + 3', result: closeTo(6, epsilon));
      check(evaluator)
          .parseSuccess('1 + 2 + 3 + 4', result: closeTo(10, epsilon));
      check(evaluator)
          .parseSuccess('1 + 2 + 3 + 4 + 5', result: closeTo(15, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('1 +', message: 'end of input expected', position: 2);
      check(
        evaluator,
      ).parseFailure('1 + 2 +', message: 'end of input expected', position: 6);
    });
  });
  group('sub', () {
    test('parser', () {
      check(parser).parseSuccess('1 - 2', result: ['1', '-', '2']);
      check(parser).parseSuccess(
        '1 - 2 - 3',
        result: [
          ['1', '-', '2'],
          '-',
          '3',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('1 - 2', result: closeTo(-1, epsilon));
      check(evaluator).parseSuccess('1.2 - 1.2', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('1 - -2', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('-1 - -2', result: closeTo(1, epsilon));
    });
    test('evaluator many', () {
      check(evaluator).parseSuccess('1', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('1 - 2', result: closeTo(-1, epsilon));
      check(evaluator).parseSuccess('1 - 2 - 3', result: closeTo(-4, epsilon));
      check(evaluator)
          .parseSuccess('1 - 2 - 3 - 4', result: closeTo(-8, epsilon));
      check(evaluator)
          .parseSuccess('1 - 2 - 3 - 4 - 5', result: closeTo(-13, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('1 -', message: 'end of input expected', position: 2);
      check(
        evaluator,
      ).parseFailure('1 - 2 -', message: 'end of input expected', position: 6);
    });
  });
  group('mul', () {
    test('parser', () {
      check(parser).parseSuccess('1 * 2', result: ['1', '*', '2']);
      check(parser).parseSuccess(
        '1 * 2 * 3',
        result: [
          ['1', '*', '2'],
          '*',
          '3',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('2 * 3', result: closeTo(6, epsilon));
      check(evaluator).parseSuccess('2 * -4', result: closeTo(-8, epsilon));
    });
    test('evaluator many', () {
      check(evaluator).parseSuccess('1 * 2', result: closeTo(2, epsilon));
      check(evaluator).parseSuccess('1 * 2 * 3', result: closeTo(6, epsilon));
      check(evaluator)
          .parseSuccess('1 * 2 * 3 * 4', result: closeTo(24, epsilon));
      check(evaluator)
          .parseSuccess('1 * 2 * 3 * 4 * 5', result: closeTo(120, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('1 *', message: 'end of input expected', position: 2);
      check(
        evaluator,
      ).parseFailure('1 * 2 *', message: 'end of input expected', position: 6);
    });
  });
  group('div', () {
    test('parser', () {
      check(parser).parseSuccess('1 / 2', result: ['1', '/', '2']);
      check(parser).parseSuccess(
        '1 / 2 / 3',
        result: [
          ['1', '/', '2'],
          '/',
          '3',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('12 / 3', result: closeTo(4, epsilon));
      check(evaluator).parseSuccess('-16 / -4', result: closeTo(4, epsilon));
    });
    test('evaluator many', () {
      check(evaluator).parseSuccess('100 / 2', result: closeTo(50, epsilon));
      check(evaluator)
          .parseSuccess('100 / 2 / 2', result: closeTo(25, epsilon));
      check(evaluator)
          .parseSuccess('100 / 2 / 2 / 5', result: closeTo(5, epsilon));
      check(evaluator)
          .parseSuccess('100 / 2 / 2 / 5 / 5', result: closeTo(1, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('1 /', message: 'end of input expected', position: 2);
      check(
        evaluator,
      ).parseFailure('1 / 2 /', message: 'end of input expected', position: 6);
    });
  });
  group('pow', () {
    test('parser', () {
      check(parser).parseSuccess('1 ^ 2', result: ['1', '^', '2']);
      check(parser).parseSuccess(
        '1 ^ 2 ^ 3',
        result: [
          '1',
          '^',
          ['2', '^', '3'],
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('2 ^ 3', result: closeTo(8, epsilon));
      check(evaluator).parseSuccess('-2 ^ 3', result: closeTo(-8, epsilon));
      check(evaluator)
          .parseSuccess('-2 ^ -3', result: closeTo(-0.125, epsilon));
    });
    test('evaluator many', () {
      check(evaluator).parseSuccess('4 ^ 3', result: closeTo(64, epsilon));
      check(evaluator)
          .parseSuccess('4 ^ 3 ^ 2', result: closeTo(262144, epsilon));
      check(evaluator)
          .parseSuccess('4 ^ 3 ^ 2 ^ 1', result: closeTo(262144, epsilon));
      check(evaluator)
          .parseSuccess('4 ^ 3 ^ 2 ^ 1 ^ 0', result: closeTo(262144, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('1 ^', message: 'end of input expected', position: 2);
      check(
        evaluator,
      ).parseFailure('1 ^ 2 ^', message: 'end of input expected', position: 6);
    });
  });
  group('parens', () {
    test('parser', () {
      check(parser).parseSuccess('(1)', result: ['(', '1', ')']);
      check(parser).parseSuccess(
        '(1 + 2)',
        result: [
          '(',
          ['1', '+', '2'],
          ')',
        ],
      );
      check(parser).parseSuccess(
        '((1))',
        result: [
          '(',
          ['(', '1', ')'],
          ')',
        ],
      );
      check(parser).parseSuccess(
        '((1 + 2))',
        result: [
          '(',
          [
            '(',
            ['1', '+', '2'],
            ')',
          ],
          ')',
        ],
      );
      check(parser).parseSuccess(
        '2 * (3 + 4)',
        result: [
          '2',
          '*',
          [
            '(',
            ['3', '+', '4'],
            ')',
          ],
        ],
      );
      check(parser).parseSuccess(
        '(2 + 3) * 4',
        result: [
          [
            '(',
            ['2', '+', '3'],
            ')',
          ],
          '*',
          '4',
        ],
      );
      check(parser).parseSuccess(
        '6 / (2 + 4)',
        result: [
          '6',
          '/',
          [
            '(',
            ['2', '+', '4'],
            ')',
          ],
        ],
      );
      check(parser).parseSuccess(
        '(2 + 6) / 2',
        result: [
          [
            '(',
            ['2', '+', '6'],
            ')',
          ],
          '/',
          '2',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('(1)', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('(1 + 2)', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('((1))', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('((1 + 2))', result: closeTo(3, epsilon));
      check(evaluator)
          .parseSuccess('2 * (3 + 4)', result: closeTo(14, epsilon));
      check(evaluator)
          .parseSuccess('(2 + 3) * 4', result: closeTo(20, epsilon));
      check(evaluator).parseSuccess('6 / (2 + 4)', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('(2 + 6) / 2', result: closeTo(4, epsilon));
    });
    test('error', () {
      check(evaluator).parseFailure('(', message: 'number expected');
      check(evaluator).parseFailure('()', message: 'number expected');
      check(evaluator).parseFailure('(1', message: 'number expected');
      check(evaluator).parseFailure('((', message: 'number expected');
      check(evaluator).parseFailure('((2', message: 'number expected');
      check(evaluator).parseFailure('((2)', message: 'number expected');
    });
  });
  group('sqrt', () {
    test('parser', () {
      check(parser).parseSuccess('sqrt(4)', result: ['sqrt(', '4', ')']);
      check(parser).parseSuccess(
        'sqrt(1 + 3)',
        result: [
          'sqrt(',
          ['1', '+', '3'],
          ')',
        ],
      );
      check(parser).parseSuccess(
        '1 + sqrt(16)',
        result: [
          '1',
          '+',
          ['sqrt(', '16', ')'],
        ],
      );
      check(parser).parseSuccess(
        'sqrt(sqrt(16))',
        result: [
          'sqrt(',
          ['sqrt(', '16', ')'],
          ')',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('sqrt(4)', result: closeTo(2, epsilon));
      check(evaluator).parseSuccess('sqrt(1 + 3)', result: closeTo(2, epsilon));
      check(evaluator)
          .parseSuccess('1 + sqrt(16)', result: closeTo(5, epsilon));
      check(evaluator)
          .parseSuccess('sqrt(sqrt(16))', result: closeTo(2, epsilon));
    });
    test('error', () {
      check(evaluator).parseFailure('sqrt(', message: 'number expected');
      check(evaluator).parseFailure('sqrt()', message: 'number expected');
      check(evaluator).parseFailure('sqrt(1', message: 'number expected');
      check(evaluator).parseFailure('sqrt(sqrt(', message: 'number expected');
      check(evaluator).parseFailure('sqrt(sqrt(1', message: 'number expected');
      check(evaluator).parseFailure('sqrt(sqrt(1)', message: 'number expected');
    });
  });
  group('postfix add', () {
    test('parser', () {
      check(parser).parseSuccess('0++', result: ['0', '++']);
      check(parser).parseSuccess(
        '0++++',
        result: [
          ['0', '++'],
          '++',
        ],
      );
      check(parser).parseSuccess(
        '0++++++',
        result: [
          [
            ['0', '++'],
            '++',
          ],
          '++',
        ],
      );
      check(parser).parseSuccess(
        '0+++1',
        result: [
          ['0', '++'],
          '+',
          '1',
        ],
      );
      check(parser).parseSuccess(
        '0+++++1',
        result: [
          [
            ['0', '++'],
            '++',
          ],
          '+',
          '1',
        ],
      );
      check(parser).parseSuccess(
        '0+++++++1',
        result: [
          [
            [
              ['0', '++'],
              '++',
            ],
            '++',
          ],
          '+',
          '1',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('0++', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('0++++', result: closeTo(2, epsilon));
      check(evaluator).parseSuccess('0++++++', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('0+++1', result: closeTo(2, epsilon));
      check(evaluator).parseSuccess('0+++++1', result: closeTo(3, epsilon));
      check(evaluator).parseSuccess('0+++++++1', result: closeTo(4, epsilon));
    });
    test('error', () {
      check(evaluator).parseFailure('++', message: 'number expected');
      check(evaluator)
          .parseFailure('0+++', message: 'end of input expected', position: 3);
    });
  });
  group('postfix sub', () {
    test('parser', () {
      check(parser).parseSuccess('0--', result: ['0', '--']);
      check(parser).parseSuccess(
        '0----',
        result: [
          ['0', '--'],
          '--',
        ],
      );
      check(parser).parseSuccess(
        '0------',
        result: [
          [
            ['0', '--'],
            '--',
          ],
          '--',
        ],
      );
      check(parser).parseSuccess(
        '0---1',
        result: [
          ['0', '--'],
          '-',
          '1',
        ],
      );
      check(parser).parseSuccess(
        '0-----1',
        result: [
          [
            ['0', '--'],
            '--',
          ],
          '-',
          '1',
        ],
      );
      check(parser).parseSuccess(
        '0-------1',
        result: [
          [
            [
              ['0', '--'],
              '--',
            ],
            '--',
          ],
          '-',
          '1',
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('1--', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('2----', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('3------', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('2---1', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('3-----1', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('4-------1', result: closeTo(0, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('--', message: 'number expected', position: 2);
      check(evaluator)
          .parseFailure('0---', message: 'end of input expected', position: 3);
    });
  });
  group('negate', () {
    test('parser', () {
      check(parser).parseSuccess('1', result: '1');
      check(parser).parseSuccess('-1', result: ['-', '1']);
      check(parser).parseSuccess(
        '--1',
        result: [
          '-',
          ['-', '1'],
        ],
      );
      check(parser).parseSuccess(
        '---1',
        result: [
          '-',
          [
            '-',
            ['-', '1'],
          ],
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('1', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('-1', result: closeTo(-1, epsilon));
      check(evaluator).parseSuccess('--1', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('---1', result: closeTo(-1, epsilon));
    });
    test('error', () {
      check(evaluator)
          .parseFailure('-', message: 'number expected', position: 1);
      check(evaluator)
          .parseFailure('--', message: 'number expected', position: 2);
      check(evaluator)
          .parseFailure('+2', message: 'number expected', position: 0);
    });
  });
  group('number', () {
    test('parser', () {
      check(parser).parseSuccess('0', result: '0');
      check(parser).parseSuccess('0.1', result: '0.1');
      check(parser).parseSuccess('-1', result: ['-', '1']);
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('0', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('0.0', result: closeTo(0, epsilon));
      check(evaluator).parseSuccess('1', result: closeTo(1, epsilon));
      check(evaluator).parseSuccess('1.2', result: closeTo(1.2, epsilon));
      check(evaluator).parseSuccess('34', result: closeTo(34, epsilon));
      check(evaluator).parseSuccess('34.7', result: closeTo(34.7, epsilon));
      check(evaluator).parseSuccess('56.78', result: closeTo(56.78, epsilon));
    });
    test('error', () {
      check(evaluator).parseFailure('', message: 'number expected');
      check(evaluator)
          .parseFailure('-', message: 'number expected', position: 1);
      check(evaluator).parseFailure('(', message: 'number expected');
      check(evaluator)
          .parseFailure('0.', message: 'end of input expected', position: 1);
    });
  });
  group('priority', () {
    test('parser', () {
      check(parser).parseSuccess(
        '2 * 3 + 4',
        result: [
          ['2', '*', '3'],
          '+',
          '4',
        ],
      );
      check(parser).parseSuccess(
        '2 + 3 * 4',
        result: [
          '2',
          '+',
          ['3', '*', '4'],
        ],
      );
    });
    test('evaluator', () {
      check(evaluator).parseSuccess('2 * 3 + 4', result: closeTo(10, epsilon));
      check(evaluator).parseSuccess('2 + 3 * 4', result: closeTo(14, epsilon));
      check(evaluator).parseSuccess('6 / 3 + 4', result: closeTo(6, epsilon));
      check(evaluator).parseSuccess('2 + 6 / 2', result: closeTo(5, epsilon));
    });
  });
  group('builder', () {
    test('empty', () {
      final builder = ExpressionBuilder<String>();
      check(
        builder.build,
      ).throwsAssertionError(message: 'At least one primitive parser expected');
    }, skip: !hasAssertionsEnabled());
    test('no primitive', () {
      final builder = ExpressionBuilder<String>();
      builder.group().wrapper(char('('), char(')'), (l, v, r) => '[$v]');
      check(
        builder.build,
      ).throwsAssertionError(message: 'At least one primitive parser expected');
    }, skip: !hasAssertionsEnabled());
    test('loopback', () {
      final builder = ExpressionBuilder<String>();
      builder.primitive(seq2(char('a'), builder.loopback).flatten());
      builder.primitive(char('b'));
      final parser = builder.build();
      check(parser).parseSuccess('b', result: 'b');
      check(parser).parseSuccess('ab', result: 'ab');
      check(parser).parseSuccess('aab', result: 'aab');
    });
    group('epsilon', () {
      test('primitive', () {
        final builder = ExpressionBuilder<String>();
        builder
          ..primitive(noneOf('()'))
          ..primitive(epsilonWith('*'));
        builder.group().wrapper(char('('), char(')'), (_, v, _) => '[$v]');
        final parser = builder.build().end();
        check(parser).parseSuccess('', result: '*');
        check(parser).parseSuccess('a', result: 'a');
        check(parser).parseSuccess('(a)', result: '[a]');
        check(parser).parseSuccess('((a))', result: '[[a]]');
        check(parser).parseSuccess('()', result: '[*]');
        check(parser).parseSuccess('(())', result: '[[*]]');
      });
      test('left', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(any());
        builder.group().left(epsilonWith(null), (a, _, b) => '[$a$b]');
        final parser = builder.build().end();
        check(parser).parseFailure('');
        check(parser).parseSuccess('a', result: 'a');
        check(parser).parseSuccess('ab', result: '[ab]');
        check(parser).parseSuccess('abc', result: '[[ab]c]');
        check(parser).parseSuccess('abcd', result: '[[[ab]c]d]');
      });
      test('right', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(any());
        builder.group().right(epsilonWith(null), (a, _, b) => '[$a$b]');
        final parser = builder.build().end();
        check(parser).parseFailure('');
        check(parser).parseSuccess('a', result: 'a');
        check(parser).parseSuccess('ab', result: '[ab]');
        check(parser).parseSuccess('abc', result: '[a[bc]]');
        check(parser).parseSuccess('abcd', result: '[a[b[cd]]]');
      });
    });
    group('optional', () {
      test('basic', () {
        final builder = ExpressionBuilder<String>();
        builder.primitive(digit());
        builder.group()
          ..wrapper(char('('), char(')'), (_, v, _) => '($v)')
          ..optional('∅');
        final parser = builder.build().end();
        check(parser).parseSuccess('', result: '∅');
        check(parser).parseSuccess('()', result: '(∅)');
        check(parser).parseSuccess('1', result: '1');
        check(parser).parseSuccess('(1)', result: '(1)');
      });
      test('repeated', () {
        final builder = ExpressionBuilder<String>();
        final group = builder.group();
        group.optional('foo');
        check(
          () => group.optional('bar'),
        ).throwsAssertionError(message: 'At most one optional value expected');
      }, skip: !hasAssertionsEnabled());
    });
  });
  group('examples', () {
    test('regex', () {
      final builder = ExpressionBuilder<String>();
      builder.primitive(noneOf(')'));
      builder.group()
        ..wrapper(char('('), char(')'), (_, value, _) => '($value)')
        ..prefix(char('!'), (_, value) => '!($value)')
        ..postfix(char('?'), (value, _) => '($value)?')
        ..left(char('|'), (left, _, right) => '($left|$right)')
        ..right(char('&'), (left, _, right) => '($left&$right)');
      builder.group()
        ..left(epsilonWith(null), (a, _, b) => '[$a$b]')
        ..optional('∅');
      final parser = builder.build().end();
      check(parser).parseSuccess('', result: '∅');
      check(parser).parseSuccess('a', result: 'a');
      check(parser).parseSuccess('ab', result: '[ab]');
      check(parser).parseSuccess('abc', result: '[[ab]c]');
      check(parser).parseSuccess('a&b', result: '(a&b)');
      check(parser).parseSuccess('a&b&c', result: '(a&(b&c))');
      check(parser).parseSuccess('a|b', result: '(a|b)');
      check(parser).parseSuccess('a|b|c', result: '((a|b)|c)');
      check(parser).parseSuccess('a?', result: '(a)?');
      check(parser).parseSuccess('a??', result: '((a)?)?');
      check(parser).parseSuccess('!a', result: '!(a)');
      check(parser).parseSuccess('!!a', result: '!(!(a))');
      check(parser).parseSuccess('()', result: '(∅)');
      check(parser).parseSuccess('(a)', result: '(a)');
      check(parser).parseSuccess('(ab)', result: '([ab])');
      check(parser).parseSuccess('(abc)', result: '([[ab]c])');
    });
  });
  test('linter', () {
    check(linter(parser)).isEmpty();
    check(linter(evaluator)).isEmpty();
  });
}
