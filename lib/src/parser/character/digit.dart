import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any digit character. The accepted input is
/// equivalent to the character-set `0-9`.
@useResult
Parser<String> digit([String message = 'digit expected']) =>
    SingleCharacterParser(const DigitCharPredicate(), message);

class DigitCharPredicate extends CharacterPredicate {
  const DigitCharPredicate();

  @override
  bool test(int charCode) => 48 <= charCode && charCode <= 57;

  @override
  bool isEqualTo(CharacterPredicate other) => other is DigitCharPredicate;
}
