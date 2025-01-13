import '../predicate.dart';

class ConstantCharPredicate extends CharacterPredicate {
  const ConstantCharPredicate(this.constant);

  final bool constant;

  @override
  bool test(int charCode) => constant;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is ConstantCharPredicate && constant == other.constant;

  @override
  String toString() => '${super.toString()}($constant)';
}
