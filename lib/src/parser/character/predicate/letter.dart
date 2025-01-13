import '../predicate.dart';

class LetterCharPredicate extends CharacterPredicate {
  const LetterCharPredicate();

  @override
  bool test(int charCode) =>
      (65 <= charCode && charCode <= 90) || (97 <= charCode && charCode <= 122);

  @override
  bool isEqualTo(CharacterPredicate other) => other is LetterCharPredicate;
}
