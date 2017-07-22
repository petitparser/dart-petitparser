library petitparser.core.characters.any_of;

import 'package:petitparser/src/core/characters/optimize.dart';
import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any of the specified characters.
Parser anyOf(String chars, [String message]) {
  return new CharacterParser(optimizedString(chars), message ?? 'any of "$chars" expected');
}
