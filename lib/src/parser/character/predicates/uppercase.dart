import '../predicate.dart';

class UppercaseCharPredicate extends CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int value) => 65 <= value && value <= 90;

  @override
  bool operator ==(Object other) => other is UppercaseCharPredicate;

  @override
  int get hashCode => 2054429;
}
