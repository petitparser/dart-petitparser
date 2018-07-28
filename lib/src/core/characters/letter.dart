library petitparser.core.characters.letter;

import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any letter character.
Parser letter([String message = 'letter expected']) {
  return CharacterParser(const LetterCharPredicate(), message);
}

class LetterCharPredicate implements CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) || (97 <= value && value <= 122);
}
