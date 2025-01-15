import '../predicate.dart';

class ConstantCharPredicate extends CharacterPredicate {
  static const any = ConstantCharPredicate(true);
  static const none = ConstantCharPredicate(false);

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
