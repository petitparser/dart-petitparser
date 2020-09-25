import 'dart:math' as math;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  test('simple grammar (operators)', () {
    final id = letter() & (letter() | digit()).star();
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
  test('simple grammar (chained functions)', () {
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
    final id = (letter() & word().star()).flatten();
    final matches = id.matchesSkipping('foo 123 bar4');
    expect(matches, ['foo', 'bar4']);
  });
  test('complicated grammar', () {
    final term = undefined();
    final prod = undefined();
    final prim = undefined();
    final add =
        (prod & char('+').trim() & term).map((values) => values[0] + values[2]);
    term.set(add | prod);
    final mul =
        (prim & char('*').trim() & prod).map((values) => values[0] * values[2]);
    prod.set(mul | prim);
    final parens =
        (char('(').trim() & term & char(')').trim()).map((values) => values[1]);
    final number = digit().plus().flatten().trim().map(int.parse);
    prim.set(parens | number);
    final parser = term.end();
    expect(parser.parse('1 + 2 + 3').value, 6);
    expect(parser.parse('1 + 2 * 3').value, 7);
    expect(parser.parse('(1 + 2) * 3').value, 9);
  });
  test('expression builder', () {
    final builder = ExpressionBuilder();
    builder.group()
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map((a) => num.tryParse(a)))
      ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);
    // negation is a prefix operator
    builder.group()..prefix(char('-').trim(), (op, a) => -a);
    // power is right-associative
    builder.group()..right(char('^').trim(), (a, op, b) => math.pow(a, b));
    // multiplication and addition are left-associative
    builder.group()
      ..left(char('*').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b);
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);
    final parser = builder.build().end();
    expect(parser.parse('-8').value, -8);
    expect(parser.parse('1+2*3').value, 7);
    expect(parser.parse('1*2+3').value, 5);
    expect(parser.parse('8/4/2').value, 1);
    expect(parser.parse('2^2^3').value, 256);
  });
}
