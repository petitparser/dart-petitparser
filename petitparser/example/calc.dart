/// Calculator from the tutorial.
library petitparser.example.calc;

import 'dart:math';
import 'package:petitparser/petitparser.dart';

Parser buildParser() {
  final builder = ExpressionBuilder();
  builder.group()
    ..primitive((pattern('+-').optional() &
            digit().plus() &
            (char('.') & digit().plus()).optional() &
            (pattern('eE') & pattern('+-').optional() & digit().plus())
                .optional())
        .flatten('number expected')
        .trim()
        .map(num.tryParse));
  builder.group()..prefix(char('-').trim(), (op, a) => -a);
  builder.group()..right(char('^').trim(), (a, op, b) => pow(a, b));
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
  final result = parser.parse(input);
  if (result.isSuccess) {
    print(' = ${result.value}');
  } else {
    print(input);
    print('${' ' * (result.position - 1)}^-- ${result.message}');
  }
}
