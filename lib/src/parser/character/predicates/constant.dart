import '../predicate.dart';

class ConstantCharPredicate extends CharacterPredicate {
  const ConstantCharPredicate(this.constant);

  final bool constant;

  @override
  bool test(int value) => constant;

  @override
  bool operator ==(Object other) =>
      other is ConstantCharPredicate && constant == other.constant;

  @override
  int get hashCode => constant.hashCode;

  @override
  String toString() => '${super.toString()}($constant)';
}
