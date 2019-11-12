library petitparser.core.characters.pattern;

import '../parser.dart';
import '../predicates/any.dart';
import 'char.dart';
import 'code.dart';
import 'not.dart';
import 'optimize.dart';
import 'parser.dart';
import 'predicate.dart';
import 'range.dart';

/// Returns a parser that accepts a single character of a given character set
/// provided as a string.
///
/// Characters match themselves. A dash `-` between two characters matches the
/// range of those characters. A caret `^` at the beginning negates the pattern.
///
/// For example, the parser `pattern('aou')` accepts the character 'a', 'o', or
/// 'u', and fails for any other input. The parser `pattern('1-3')` accepts
/// either '1', '2', or '3'; and fails for any other character. The parser
/// `pattern('^aou') accepts any character, but fails for the characters 'a',
/// 'o', or 'u'.
Parser<String> pattern(String element, [String message]) {
  return CharacterParser(pattern_.parse(element).value,
      message ?? '[${toReadableString(element)}] expected');
}

/// Parser that reads a single character.
final Parser<RangeCharPredicate> single_ =
    any().map((element) => RangeCharPredicate(
          toCharCode(element),
          toCharCode(element),
        ));

/// Parser that reads a character range.
final Parser<RangeCharPredicate> range_ =
    any().seq(char('-')).seq(any()).map((elements) => RangeCharPredicate(
          toCharCode(elements[0]),
          toCharCode(elements[2]),
        ));

/// Parser that reads a sequence of single characters or ranges.
final Parser<CharacterPredicate> sequence_ = range_.or(single_).plus().map(
    (predicates) => optimizedRanges(predicates.cast<RangeCharPredicate>()));

/// Parser that reads a possibly negated sequence of predicates.
final Parser<CharacterPredicate> pattern_ = char('^')
    .optional()
    .seq(sequence_)
    .map((predicates) => predicates[0] == null
        ? predicates[1]
        : NotCharacterPredicate(predicates[1]));
