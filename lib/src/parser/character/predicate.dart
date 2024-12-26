import 'package:meta/meta.dart';

import '../../shared/utils.dart';

/// Abstract class for character predicates.
@immutable
abstract class CharacterPredicate {
  const CharacterPredicate();

  /// Tests if the unicode code point [value] satisfies ths predicate.
  bool test(int value);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString() => sanitizeToString(super.toString());
}
