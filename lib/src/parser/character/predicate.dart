import 'package:meta/meta.dart';

/// Abstract class for character predicates.
@immutable
abstract class CharacterPredicate {
  const CharacterPredicate();

  /// Tests if the [charCode] satisfies the predicate.
  bool test(int charCode);

  /// Compares the predicate and [other] for equality.
  bool isEqualTo(CharacterPredicate other);

  @override
  String toString() => '$runtimeType';
}
