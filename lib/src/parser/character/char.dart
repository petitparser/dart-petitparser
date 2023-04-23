import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'code.dart';
import 'optimize.dart';
import 'predicate.dart';
import 'range.dart';

/// Returns a parser that accepts a specific character only.
@useResult
Parser<String> char(String char, [String? message]) => SingleCharacterParser(
    SingleCharPredicate(toCharCode(char)),
    message ?? '"${toReadableString(char)}" expected');

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
      other is SingleCharPredicate && other.value == value;
}
