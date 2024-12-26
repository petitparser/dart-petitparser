import '../predicate.dart';

class WordCharPredicate extends CharacterPredicate {
  const WordCharPredicate();

  @override
  bool test(int value) =>
      (65 <= value && value <= 90) ||
      (97 <= value && value <= 122) ||
      (48 <= value && value <= 57) ||
      identical(value, 95);

  @override
  bool operator ==(Object other) => other is WordCharPredicate;

  @override
  int get hashCode => 9590294;
}
