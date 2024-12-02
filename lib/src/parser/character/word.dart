import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any word character (lowercase, uppercase,
/// underscore, or digit). The accepted input is equivalent to the character-set
/// `a-zA-Z_0-9`.
@useResult
Parser<String> word([String message = 'letter or digit expected']) =>
    SingleCharacterParser(const WordCharPredicate(), message);

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
