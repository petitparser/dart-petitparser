/// Calculator from the tutorial.
library petitparser.example.calc;

import 'package:petitparser/petitparser.dart';

void main(List<String> arguments) {
  final number = digit().plus().flatten().trim().map(int.parse);
  final term = undefined();
  final prod = undefined();
  final prim = undefined();
  final start = term.end();

  term.set(prod
      .seq(char('+').trim())
      .seq(term)
      .map((values) => values[0] + values[2])
      .or(prod));
  prod.set(prim
      .seq(char('*').trim())
      .seq(prod)
      .map((values) => values[0] * values[2])
      .or(prim));
  prim.set(char('(')
      .trim()
      .seq(term)
      .seq(char(')').trim())
      .map((values) => values[1])
      .or(number));

  print(start.parse(arguments.join(' ')).value);
}
