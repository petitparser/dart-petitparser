library petitparser.core.characters.predicate;

/// Abstract character predicate class.
abstract class CharacterPredicate {
  /// Tests if the character predicate is satisfied.
  bool test(int value);
}
