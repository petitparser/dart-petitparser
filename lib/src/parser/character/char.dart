import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'internal/char.dart';
import 'internal/code.dart';
import 'internal/optimize.dart';
import 'internal/range.dart';

/// Returns a parser that accepts a specific character (UTF-16 code unit).
@useResult
Parser<String> char(String value, [String? message]) => SingleCharacterParser(
    SingleCharPredicate(toCharCode(value)),
    message ?? '"${toReadableString(value)}" expected');

/// Returns a parser that accepts a specific character (Unicode code-point).
@useResult
Parser<String> charUnicode(String value, [String? message]) =>
    UnicodeCharacterParser(
        SingleCharPredicate(toCharCode(value, unicode: true)),
        message ?? '"${toReadableString(value, unicode: true)}" expected');

/// Returns a parser that accepts a case-insensitive specific character only.
@useResult
Parser<String> charIgnoringCase(String char, [String? message]) {
  final lowerCase = toCharCode(char.toLowerCase());
  final upperCase = toCharCode(char.toUpperCase());
  return SingleCharacterParser(
      optimizedRanges([
        RangeCharPredicate(lowerCase, lowerCase),
        RangeCharPredicate(upperCase, upperCase),
      ]),
      message ?? '"${toReadableString(char)}" (case-insensitive) expected');
}
