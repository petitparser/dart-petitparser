import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'code.dart';
import 'optimize.dart';
import 'predicate.dart';
import 'range.dart';

/// Returns a parser that accepts a specific character only.
@useResult
Parser<String> char(String value, [String? message]) => SingleCharacterParser(
    SingleCharPredicate(toCharCode(value)),
    message ?? '"${toReadableString(value)}" expected');

/// Returns a parser that accepts a specific character only.
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

class SingleCharPredicate extends CharacterPredicate {
  const SingleCharPredicate(this.value);

  final int value;

  @override
  bool test(int value) => identical(this.value, value);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is SingleCharPredicate && value == other.value;
}
