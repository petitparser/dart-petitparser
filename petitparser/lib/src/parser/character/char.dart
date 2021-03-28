import '../../core/parser.dart';
import 'code.dart';
import 'parser.dart';
import 'predicate.dart';

/// Returns a parser that accepts a specific character only.
Parser<String> char(Object char, [String? message]) => CharacterParser(
    SingleCharPredicate(toCharCode(char)),
    message ?? '"${toReadableString(char)}" expected');

class SingleCharPredicate extends CharacterPredicate {
  const SingleCharPredicate(this.value);

  final int value;

  @override
  bool test(int value) => identical(this.value, value);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is SingleCharPredicate && other.value == value;
}
