import '../predicate.dart';

class UppercaseCharPredicate extends CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int charCode) => 65 <= charCode && charCode <= 90;

  @override
  bool isEqualTo(CharacterPredicate other) => other is UppercaseCharPredicate;
}
