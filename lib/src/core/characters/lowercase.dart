library petitparser.core.characters.lowercase;

import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any lowercase character.
Parser lowercase([String message = 'lowercase letter expected']) {
  return CharacterParser(const LowercaseCharPredicate(), message);
}

class LowercaseCharPredicate implements CharacterPredicate {
  const LowercaseCharPredicate();

  @override
  bool test(int value) => 97 <= value && value <= 122;
}
