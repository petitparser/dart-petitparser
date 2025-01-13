import '../predicate.dart';

class LowercaseCharPredicate extends CharacterPredicate {
  const LowercaseCharPredicate();

  @override
  bool test(int charCode) => 97 <= charCode && charCode <= 122;

  @override
  bool isEqualTo(CharacterPredicate other) => other is LowercaseCharPredicate;
}
