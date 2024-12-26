import '../predicate.dart';

class LetterCharPredicate extends CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) || (97 <= value && value <= 122);

  @override
  bool operator ==(Object other) => other is LetterCharPredicate;

  @override
  int get hashCode => 8078492;
}
