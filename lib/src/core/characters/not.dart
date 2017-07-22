library petitparser.core.characters.not;

import 'package:petitparser/src/core/characters/predicate.dart';

class NotCharacterPredicate implements CharacterPredicate {
  final CharacterPredicate predicate;

  const NotCharacterPredicate(this.predicate);

  @override
  bool test(int value) => !predicate.test(value);
}
