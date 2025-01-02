import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate.dart';

/// Returns a parser that accepts any uppercase character. The accepted input is
/// equivalent to the character-set `A-Z`.
@useResult
Parser<String> uppercase([String message = 'uppercase letter expected']) =>
    SingleCharacterParser(const UppercaseCharPredicate(), message);

class UppercaseCharPredicate extends CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int charCode) => 65 <= charCode && charCode <= 90;

  @override
  bool isEqualTo(CharacterPredicate other) => other is UppercaseCharPredicate;
}
