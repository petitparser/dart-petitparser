/// Calculator from the tutorial.
library calc;

import 'dart:io';
import 'dart:math';

import 'package:petitparser/petitparser.dart';

Parser buildParser() {
  final builder = ExpressionBuilder<num>();
  builder.primitive((pattern('+-').optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional() &
          (pattern('eE') & pattern('+-').optional() & digit().plus())
              .optional())
      .flatten('number expected')
      .trim()
      .map(num.parse));
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);
  builder.group().prefix(char('-').trim(), (op, a) => -a);
  builder.group().right(char('^').trim(), (a, op, b) => pow(a, b));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => a * b)
    ..left(char('/').trim(), (a, op, b) => a / b);
  builder.group()
    ..left(char('+').trim(), (a, op, b) => a + b)
    ..left(char('-').trim(), (a, op, b) => a - b);
  return builder.build().end();
}

void main(List<String> arguments) {
  final parser = buildParser();
  final input = arguments.join(' ');
  switch (parser.parse(input)) {
    case Success(value: final value):
      stdout.writeln(' = $value');
    case Failure(position: final position, message: final message):
      stderr.writeln(input);
      stderr.writeln('${' ' * (position - 1)}^-- $message');
      exit(1);
  }
}
