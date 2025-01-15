import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/char.dart';
import 'predicate/range.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts a specific character only.
@useResult
Parser<String> char(String char, [String? message]) => CharacterParser(
    SingleCharPredicate(toCharCode(char)),
    message ?? '"${toReadableString(char)}" expected');

/// Returns a parser that accepts a case-insensitive specific character only.
@useResult
Parser<String> charIgnoringCase(String char, [String? message]) {
  final lowerCase = toCharCode(char.toLowerCase());
  final upperCase = toCharCode(char.toUpperCase());
  return CharacterParser(
      optimizedRanges([
        RangeCharPredicate(lowerCase, lowerCase),
        RangeCharPredicate(upperCase, upperCase),
      ]),
      message ?? '"${toReadableString(char)}" (case-insensitive) expected');
}
