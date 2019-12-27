library petitparser.test.example_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  test('simple grammar', () {
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
    final id = letter().seq(word().star()).flatten();
    final matches = id.matchesSkipping('foo 123 bar4');
    expect(matches, ['foo', 'bar4']);
  });
  test('complicated grammar', () {
    final number = digit().plus().flatten().trim().map(int.parse);
    final term = undefined();
    final prod = undefined();
    final prim = undefined();
    term.set(prod.seq(char('+').trim()).seq(term).map((values) {
      return values[0] + values[2];
    }).or(prod));
    prod.set(prim.seq(char('*').trim()).seq(prod).map((values) {
      return values[0] * values[2];
    }).or(prim));
    prim.set(char('(').trim().seq(term).seq(char(')'.trim())).map((values) {
      return values[1];
    }).or(number));
    final start = term.end();
    expect(7, start.parse('1 + 2 * 3').value);
    expect(9, start.parse('(1 + 2) * 3').value);
  });
}
