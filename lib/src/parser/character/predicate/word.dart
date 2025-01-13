import '../predicate.dart';

class WordCharPredicate extends CharacterPredicate {
  const WordCharPredicate();

  @override
  bool test(int charCode) =>
      (65 <= charCode && charCode <= 90) ||
      (97 <= charCode && charCode <= 122) ||
      (48 <= charCode && charCode <= 57) ||
      identical(charCode, 95);

  @override
  bool isEqualTo(CharacterPredicate other) => other is WordCharPredicate;
}
