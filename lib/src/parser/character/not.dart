import 'predicate.dart';

/// Negates the result of a character predicate.
class NotCharacterPredicate extends CharacterPredicate {
  const NotCharacterPredicate(this.predicate);

  final CharacterPredicate predicate;

  @override
  bool test(int charCode) => !predicate.test(charCode);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is NotCharacterPredicate && predicate.isEqualTo(other.predicate);

  @override
  String toString() => '${super.toString()}($predicate)';
}
