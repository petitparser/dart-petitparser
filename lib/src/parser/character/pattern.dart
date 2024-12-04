import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../action/map.dart';
import '../combinator/choice.dart';
import '../combinator/optional.dart';
import '../combinator/sequence.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import '../repeater/possessive.dart';
import 'char.dart';
import 'code.dart';
import 'constant.dart';
import 'not.dart';
import 'optimize.dart';
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
@useResult
Parser<String> pattern(String element, [String? message]) =>
    SingleCharacterParser(_pattern.parse(element).value,
        message ?? '[${toReadableString(element)}] expected');

/// Returns a parser that accepts a single character of a given character set
/// provided as a string. The pattern works with full unicode patterns.
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
Parser<String> patternUnicode(String element, [String? message]) =>
    UnicodeCharacterParser(_patternUnicode.parse(element).value,
        message ?? '[${toReadableString(element, unicode: true)}] expected');

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

Parser<CharacterPredicate> _createParser({bool unicode = false}) {
  const anyPredicate = ConstantCharPredicate(true);
  final any = unicode
      ? UnicodeCharacterParser(anyPredicate, 'input expected')
      : SingleCharacterParser(anyPredicate, 'input expected');
  // Parser that reads a single character.
  final single = any.map((element) => RangeCharPredicate(
      toCharCode(element, unicode: unicode),
      toCharCode(element, unicode: unicode)));
  // Parser that reads a character range.
  final range = (
    any,
    char('-'),
    any
  ).toSequenceParser().map3((start, _, stop) => RangeCharPredicate(
      toCharCode(start, unicode: unicode), toCharCode(stop, unicode: unicode)));
  // Parser that reads a sequence of single characters or ranges.
  final sequence = [range, single].toChoiceParser().star().map(optimizedRanges);
  // Parser that reads a possibly negated sequence of predicates.
  return (char('^').optional(), sequence)
      .toSequenceParser()
      .map2((negation, sequence) => negation == null
          ? sequence
          : sequence is ConstantCharPredicate
              ? ConstantCharPredicate(!sequence.constant)
              : NotCharacterPredicate(sequence));
}

final _pattern = _createParser();
final _patternUnicode = _createParser(unicode: true);
