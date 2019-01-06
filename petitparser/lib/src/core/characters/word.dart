library petitparser.core.characters.word;

import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any word character.
Parser<String> word([String message = 'letter or digit expected']) {
  return CharacterParser(const WordCharPredicate(), message);
}

class WordCharPredicate implements CharacterPredicate {
  const WordCharPredicate();

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) ||
      (97 <= value && value <= 122) ||
      (48 <= value && value <= 57) ||
      identical(value, 95);

  @override
  bool isEqualTo(CharacterPredicate other) => other is WordCharPredicate;
}
