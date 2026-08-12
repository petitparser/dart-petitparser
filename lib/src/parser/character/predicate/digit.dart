import '../predicate.dart';

class DigitCharPredicate extends CharacterPredicate {
  const new();

  @override
  bool test(int charCode) => 48 <= charCode && charCode <= 57;

  @override
  bool isEqualTo(CharacterPredicate other) => other is DigitCharPredicate;
}
