import '../predicate.dart';

final class DigitCharPredicate extends CharacterPredicate {
  const DigitCharPredicate();

  @override
  bool test(int charCode) => 48 <= charCode && charCode <= 57;

  @override
  bool operator ==(Object other) => other is DigitCharPredicate;

  @override
  int get hashCode => 7085385;
}
