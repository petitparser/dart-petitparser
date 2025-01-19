import '../predicate.dart';

class NotCharPredicate extends CharacterPredicate {
  const NotCharPredicate(this.predicate);

  final CharacterPredicate predicate;

  @override
  bool test(int charCode) => !predicate.test(charCode);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is NotCharPredicate && predicate.isEqualTo(other.predicate);

  @override
  String toString() => '${super.toString()}($predicate)';
}
