import '../predicate.dart';

class DigitCharPredicate extends CharacterPredicate {
  const DigitCharPredicate();

  @override
  bool test(int value) => 48 <= value && value <= 57;

  @override
  bool operator ==(Object other) => other is DigitCharPredicate;

  @override
  int get hashCode => 7085385;
}
