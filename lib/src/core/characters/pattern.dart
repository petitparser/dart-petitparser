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
Parser pattern(String element, [String message]) {
  return new CharacterParser(_patternParser
      .parse(element)
      .value, message ?? '[${toReadableString(element)}] expected');
}

Parser _createPatternParser() {
  var single = any().map((String element) {
    return new RangeCharPredicate(toCharCode(element), toCharCode(element));
  });
  var range = any().seq(char('-')).seq(any()).map((List<String> elements) {
    return new RangeCharPredicate(toCharCode(elements[0]), toCharCode(elements[2]));
  });
  var positive = range.or(single).plus().map((List<RangeCharPredicate> predicates) {
    return optimizedRanges(predicates);
  });
  return char('^').optional().seq(positive)
      .map((List<RangeCharPredicate> predicates) {
    return predicates[0] == null ? predicates[1] : new NotCharacterPredicate(predicates[1]);
  });
}

final _patternParser = _createPatternParser();
