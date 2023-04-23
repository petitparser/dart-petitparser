import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any letter character (lowercase or uppercase).
/// The accepted input is equivalent to the character-set `a-zA-Z`.
@useResult
Parser<String> letter([String message = 'letter expected']) =>
    SingleCharacterParser(const LetterCharPredicate(), message);

class LetterCharPredicate extends CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) || (97 <= value && value <= 122);

  @override
  bool isEqualTo(CharacterPredicate other) => other is LetterCharPredicate;
}
