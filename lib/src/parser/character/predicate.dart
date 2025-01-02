import 'package:meta/meta.dart';

import '../../shared/to_string.dart';

/// Abstract class for character predicates.
@immutable
abstract class CharacterPredicate {
  const CharacterPredicate();

  /// Tests if the [charCode] satisfies the predicate.
  bool test(int charCode);

  /// Compares the two predicates for equality.
  bool isEqualTo(CharacterPredicate other);

  @override
  String toString() => objectToString(this);
}
