import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../action/map.dart';
import '../combinator/choice.dart';
import '../combinator/optional.dart';
import '../combinator/sequence.dart';
import '../predicate/any.dart';
import '../predicate/character.dart';
import '../repeater/possessive.dart';
import 'char.dart';
import 'code.dart';
import 'constant.dart';
import 'not.dart';
import 'optimize.dart';
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
@useResult
Parser<String> pattern(String element, [String? message]) =>
    SingleCharacterParser(_pattern.parse(element).value,
        message ?? '[${toReadableString(element)}] expected');

/// Returns a parser that accepts a single character of a given case-insensitive
/// character set provided as a string.
///
/// Characters match themselves. A dash `-` between two characters matches the
/// range of those characters. A caret `^` at the beginning negates the pattern.
///
/// For example, the parser `patternIgnoreCase('aoU')` accepts the character
/// 'a', 'o', 'u' and 'A', 'O', 'U', and fails for any other input. The parser
/// `patternIgnoreCase('a-c')` accepts 'a', 'b', 'c' and 'A', 'B', 'C'; and
/// fails for any other character. The parser `patternIgnoreCase('^A') accepts
/// any character, but fails for the characters 'a' or 'A'.
@useResult
Parser<String> patternIgnoreCase(String element, [String? message]) {
  var normalized = element;
  final isNegated = normalized.startsWith('^');
  if (isNegated) {
    normalized = normalized.substring(1);
  }
  final isDashed = normalized.endsWith('-');
  if (isDashed) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return pattern(
      '${isNegated ? '^' : ''}'
      '${normalized.toLowerCase()}${normalized.toUpperCase()}'
      '${isDashed ? '-' : ''}',
      message ?? '[${toReadableString(element)}] (case-insensitive) expected');
}

/// Parser that reads a single character.
final _single = any().map(
    (element) => RangeCharPredicate(toCharCode(element), toCharCode(element)));

/// Parser that reads a character range.
final _range = (any(), char('-'), any()).toSequenceParser().map3(
    (start, _, stop) =>
        RangeCharPredicate(toCharCode(start), toCharCode(stop)));

/// Parser that reads a sequence of single characters or ranges.
final _sequence =
    [_range, _single].toChoiceParser().star().map(optimizedRanges);

/// Parser that reads a possibly negated sequence of predicates.
final _pattern = (char('^').optional(), _sequence)
    .toSequenceParser()
    .map2((negation, sequence) => negation == null
        ? sequence
        : sequence is ConstantCharPredicate
            ? ConstantCharPredicate(!sequence.constant)
            : NotCharacterPredicate(sequence));
