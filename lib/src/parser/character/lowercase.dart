import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any lowercase character. The accepted input is
/// equivalent to the character-set `a-z`.
@useResult
Parser<String> lowercase([String message = 'lowercase letter expected']) =>
    SingleCharacterParser(const LowercaseCharPredicate(), message);

class LowercaseCharPredicate extends CharacterPredicate {
  const LowercaseCharPredicate();

  @override
  bool test(int value) => 97 <= value && value <= 122;

  @override
  bool isEqualTo(CharacterPredicate other) => other is LowercaseCharPredicate;
}
