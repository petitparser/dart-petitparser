/// Calculator from the tutorial.
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
        .map(num.tryParse))
    ..wrapper(
        char('(').trim(), char(')').trim(), (left, value, right) => value);
  builder.group()..prefix<String, int>(char('-').trim(), (op, a) => -a);
  builder.group()
    ..right<String, int>(char('^').trim(), (a, op, b) => pow(a, b));
  builder.group()
    ..left<String, int>(char('*').trim(), (a, op, b) => a * b)
    ..left<String, int>(char('/').trim(), (a, op, b) => a / b);
  builder.group()
    ..left<String, int>(char('+').trim(), (a, op, b) => a + b)
    ..left<String, int>(char('-').trim(), (a, op, b) => a - b);
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
