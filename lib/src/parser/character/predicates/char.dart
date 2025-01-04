import '../predicate.dart';

final class SingleCharPredicate extends CharacterPredicate {
  const SingleCharPredicate(this.charCode);

  final int charCode;

  @override
  bool test(int charCode) => this.charCode == charCode;

  @override
  bool operator ==(Object other) =>
      other is SingleCharPredicate && charCode == other.charCode;

  @override
  int get hashCode => charCode.hashCode;

  @override
  String toString() => '${super.toString()}($charCode)';
}
