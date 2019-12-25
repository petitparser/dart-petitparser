library petitparser.example.regexp_benchmark;

import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';

import 'benchmark.dart';

const Equality equality = ListEquality();

void compare(String regExp, Parser parser, String input) {
  final nativePattern = RegExp(regExp);
  final nativeResult = nativePattern
      .allMatches(input)
      .map((matcher) => matcher.group(0))
      .toList();

  final parserPattern = parser.toPattern();
  final parserResult = parserPattern
      .allMatches(input)
      .map((matcher) => matcher.group(0))
      .toList();

  if (!equality.equals(nativeResult, parserResult)) {
    print('$regExp\tERROR');
    return;
  }

  final nativeTime = benchmark(() => nativePattern
      .allMatches(input)
      .map((matcher) => matcher.group(0))
      .toList());
  final parserTime = benchmark(() => parserPattern
      .allMatches(input)
      .map((matcher) => matcher.group(0))
      .toList());
  print('$regExp\t'
      '${nativeTime.toStringAsFixed(6)}\t'
      '${parserTime.toStringAsFixed(6)}\t'
      '${(100 * nativeTime / parserTime).round() - 100}%');
}

void main() {
  print('Expression\tNative\tParser\tChange');
  compare(r'[0-9]', digit(),
      '!1!12!123!1234!12345!123456!1234567!12345678!123456789!');
  compare(r'[^0-9]', digit().not() & any(),
      '!1!12!123!1234!12345!123456!1234567!12345678!123456789!');
  compare(r'[0-9]+', digit().plus(),
      '!1!12!123!1234!12345!123456!1234567!12345678!123456789!');
  compare(r'[0-9]*!', digit().star() & char('!'),
      '!1!12!123!1234!12345!123456!1234567!12345678!123456789!');
  compare(r'![0-9]*', char('!') & digit().star(),
      '!1!12!123!1234!12345!123456!1234567!12345678!123456789!');
  compare(
      r'[a-z]+@[a-z]+\.[a-z]{2,3}',
      letter().plus() &
          char('@') &
          letter().plus() &
          char('.') &
          letter().repeat(2, 3),
      'a@b.c, de@fg.hi, jkl@mno.pqr, stuv@wxyz.abcd, efghi@jklmn.opqrs');
  compare(
      r'[+-]?\d+(\.\d+)?([eE][+-]?\d+)?',
      pattern('+-').optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional() &
          (pattern('eE') & pattern('+-').optional() & digit().plus())
              .optional(),
      '1, -2, 3.4, -5.6, 7e8, 9E0, 0e+1, 2E-3, -4.567e-890');
}
