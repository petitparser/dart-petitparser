import '../predicate.dart';

class SingleCharPredicate extends CharacterPredicate {
  const SingleCharPredicate(this.charCode);

  final int charCode;

  @override
  bool test(int charCode) => identical(this.charCode, charCode);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is SingleCharPredicate && charCode == other.charCode;

  @override
  String toString() => '${super.toString()}($charCode)';
}
