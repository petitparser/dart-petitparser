import '../predicate.dart';

class SingleCharPredicate extends CharacterPredicate {
  const SingleCharPredicate(this.value);

  final int value;

  @override
  bool test(int value) => identical(this.value, value);

  @override
  bool operator ==(Object other) =>
      other is SingleCharPredicate && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '${super.toString()}($value)';
}
