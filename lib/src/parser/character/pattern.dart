import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../action/map.dart';
import '../combinator/choice.dart';
import '../combinator/sequence.dart';
import '../misc/end.dart';
import '../predicate/character.dart';
import '../repeater/possessive.dart';
import 'any.dart';
import 'char.dart';
import 'predicate/constant.dart';
import 'predicate/not.dart';
import 'predicate/range.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts a single character of a given character set
/// [pattern] provided as a string.
///
/// Characters match themselves. A dash `-` between two characters matches the
/// range of those characters. A caret `^` at the beginning negates the pattern.
///
/// For example, the parser `pattern('aou')` accepts the character 'a', 'o', or
/// 'u', and fails for any other input. The parser `pattern('1-3')` accepts
/// either '1', '2', or '3'; and fails for any other character. The parser
/// `pattern('^aou') accepts any character, but fails for the characters 'a',
/// 'o', or 'u'.
///
/// If [ignoreCase] is set to `true` the pattern accepts lower and uppercase
/// variations of its characters. If [unicode] is set to `true` unicode
/// surrogate pairs are extracted and matched against the predicate.
@useResult
Parser<String> pattern(String pattern,
    {String? message, bool ignoreCase = false, bool unicode = false}) {
  var input = pattern;
  final isNegated = input.startsWith('^');
  if (isNegated) input = input.substring(1);
  final inputs =
      ignoreCase ? [input.toLowerCase(), input.toUpperCase()] : [input];
  final parser = unicode ? _patternUnicodeParser : _patternParser;
  var predicate = optimizedRanges(
      inputs.expand((each) => parser.parse(each).value),
      unicode: unicode);
  if (isNegated) {
    predicate = predicate is ConstantCharPredicate
        ? ConstantCharPredicate(!predicate.constant)
        : NotCharPredicate(predicate);
  }
  message ??= '[${toReadableString(pattern, unicode: unicode)}]'
      '${ignoreCase ? ' (case-insensitive)' : ''} expected';
  return CharacterParser(predicate, message, unicode: unicode);
}

Parser<List<RangeCharPredicate>> _createParser({required bool unicode}) {
  // Parser that consumes a single character.
  final character = any(unicode: unicode);
  // Parser that reads a single character.
  final single = character.map((element) => RangeCharPredicate(
      toCharCode(element, unicode: unicode),
      toCharCode(element, unicode: unicode)));
  // Parser that reads a character range.
  final range = (
    character,
    char('-'),
    character
  ).toSequenceParser().map3((start, _, stop) => RangeCharPredicate(
      toCharCode(start, unicode: unicode), toCharCode(stop, unicode: unicode)));
  // Parser that reads a sequence of single characters or ranges.
  return [range, single].toChoiceParser().star().end();
}

final _patternParser = _createParser(unicode: false);
final _patternUnicodeParser = _createParser(unicode: true);
