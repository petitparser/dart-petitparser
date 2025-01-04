import '../predicate.dart';

final class NotCharPredicate extends CharacterPredicate {
  const NotCharPredicate(this.predicate);

  final CharacterPredicate predicate;

  @override
  bool test(int charCode) => !predicate.test(charCode);

  @override
  bool operator ==(Object other) =>
      other is NotCharPredicate && predicate == other.predicate;

  @override
  int get hashCode => 4680790 ^ predicate.hashCode;

  @override
  String toString() => '${super.toString()}($predicate)';
}
