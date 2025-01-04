import '../predicate.dart';

final class LowercaseCharPredicate extends CharacterPredicate {
  const LowercaseCharPredicate();

  @override
  bool test(int charCode) => 97 <= charCode && charCode <= 122;

  @override
  bool operator ==(Object other) => other is LowercaseCharPredicate;

  @override
  int get hashCode => 2194118;
}
