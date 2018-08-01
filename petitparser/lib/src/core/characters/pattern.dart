library petitparser.core.characters.pattern;

import 'package:petitparser/src/core/characters/char.dart';
import 'package:petitparser/src/core/characters/code.dart';
import 'package:petitparser/src/core/characters/not.dart';
import 'package:petitparser/src/core/characters/optimize.dart';
import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/range.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/predicates/any.dart';

/// Returns a parser that accepts the given character class pattern.
Parser<String> pattern(String element, [String message]) {
  return CharacterParser(pattern_.parse(element).value,
      message ?? '[${toReadableString(element)}] expected');
}

/// Parser that reads a single character.
final single_ = any().map(
    (element) => RangeCharPredicate(toCharCode(element), toCharCode(element)));

/// Parser that reads a character range.
final range_ = any().seq(char('-')).seq(any()).map((List elements) =>
    RangeCharPredicate(toCharCode(elements[0]), toCharCode(elements[2])));

/// Parser that reads a sequence of single characters or ranges.
final sequence_ = range_.or(single_).plus().map((List predicates) =>
    optimizedRanges(predicates.cast<RangeCharPredicate>()));

/// Parser that reads a possibly negated sequecne of predicates.
final pattern_ = char('^').optional().seq(sequence_).map((List predicates) =>
    predicates[0] == null
        ? predicates[1]
        : NotCharacterPredicate(predicates[1]));
