import '../predicate.dart';

final class WordCharPredicate extends CharacterPredicate {
  const WordCharPredicate();

  @override
  bool test(int charCode) =>
      (65 <= charCode && charCode <= 90) ||
      (97 <= charCode && charCode <= 122) ||
      (48 <= charCode && charCode <= 57) ||
      (charCode == 95);

  @override
  bool operator ==(Object other) => other is WordCharPredicate;

  @override
  int get hashCode => 9590294;
}
