library petitparser.core.characters.predicate;

/// Abstract character predicate class.
abstract class CharacterPredicate {
  const CharacterPredicate();

  /// Tests if the character predicate is satisfied.
  bool test(int value);

  /// Compares the two predicates for equality.
  bool isEqualTo(CharacterPredicate other);
}
