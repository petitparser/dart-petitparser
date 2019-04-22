library petitparser.core.characters.char;

import 'package:petitparser/src/core/characters/code.dart';
import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts a specific character only.
Parser<String> char(Object char, [String message]) {
  return CharacterParser(SingleCharPredicate(toCharCode(char)),
      message ?? '"${toReadableString(char)}" expected');
}

class SingleCharPredicate extends CharacterPredicate {
  final int value;

  const SingleCharPredicate(this.value)
      : assert(value != null, 'value must not be null');

  @override
  bool test(int value) => identical(this.value, value);

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is SingleCharPredicate && other.value == value;
}
