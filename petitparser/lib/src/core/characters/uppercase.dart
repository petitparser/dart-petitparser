library petitparser.core.characters.uppercase;

import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any uppercase character.
Parser<String> uppercase([String message = 'uppercase letter expected']) {
  return CharacterParser(const UppercaseCharPredicate(), message);
}

class UppercaseCharPredicate implements CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int value) => 65 <= value && value <= 90;
}
