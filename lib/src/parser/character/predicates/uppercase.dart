import '../predicate.dart';

final class UppercaseCharPredicate extends CharacterPredicate {
  const UppercaseCharPredicate();

  @override
  bool test(int charCode) => 65 <= charCode && charCode <= 90;

  @override
  bool operator ==(Object other) => other is UppercaseCharPredicate;

  @override
  int get hashCode => 2054429;
}
