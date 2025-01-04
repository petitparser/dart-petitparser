import 'package:meta/meta.dart';

/// Abstract class for character predicates.
@immutable
abstract class CharacterPredicate {
  const CharacterPredicate();

  /// Tests if the [charCode] satisfies the predicate.
  bool test(int charCode);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString() => '$runtimeType';
}
