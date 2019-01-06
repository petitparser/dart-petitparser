library petitparser.core.characters.not;

import 'package:petitparser/src/core/characters/predicate.dart';

/// Negates the result of a character predicate.
class NotCharacterPredicate extends CharacterPredicate {
  final CharacterPredicate predicate;

  const NotCharacterPredicate(this.predicate) : assert(predicate != null);

  @override
  bool test(int value) => !predicate.test(value);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is NotCharacterPredicate &&
      other.predicate.isEqualTo(other.predicate);
}
