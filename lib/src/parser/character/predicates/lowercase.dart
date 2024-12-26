import '../predicate.dart';

class LowercaseCharPredicate extends CharacterPredicate {
  const LowercaseCharPredicate();

  @override
  bool test(int value) => 97 <= value && value <= 122;

  @override
  bool operator ==(Object other) => other is LowercaseCharPredicate;

  @override
  int get hashCode => 2194118;
}
