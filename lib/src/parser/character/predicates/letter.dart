import '../predicate.dart';

final class LetterCharPredicate extends CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int charCode) =>
      (65 <= charCode && charCode <= 90) || (97 <= charCode && charCode <= 122);

  @override
  bool operator ==(Object other) => other is LetterCharPredicate;

  @override
  int get hashCode => 8078492;
}
