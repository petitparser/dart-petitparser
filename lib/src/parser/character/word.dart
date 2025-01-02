import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any word character (lowercase, uppercase,
/// underscore, or digit). The accepted input is equivalent to the character-set
/// `a-zA-Z_0-9`.
@useResult
Parser<String> word([String message = 'letter or digit expected']) =>
    SingleCharacterParser(const WordCharPredicate(), message);

class WordCharPredicate extends CharacterPredicate {
  const WordCharPredicate();

  @override
  bool test(int charCode) =>
      (65 <= charCode && charCode <= 90) ||
      (97 <= charCode && charCode <= 122) ||
      (48 <= charCode && charCode <= 57) ||
      identical(charCode, 95);

  @override
  bool isEqualTo(CharacterPredicate other) => other is WordCharPredicate;
}
