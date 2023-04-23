import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any uppercase character. The accepted input is
/// equivalent to the character-set `A-Z`.
@useResult
Parser<String> uppercase([String message = 'uppercase letter expected']) =>
    SingleCharacterParser(const UppercaseCharPredicate(), message);

class UppercaseCharPredicate implements CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int value) => 65 <= value && value <= 90;

  @override
  bool isEqualTo(CharacterPredicate other) => other is UppercaseCharPredicate;
}
