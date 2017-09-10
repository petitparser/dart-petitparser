library petitparser.core.characters.none_of;

import 'package:petitparser/src/core/characters/code.dart';
import 'package:petitparser/src/core/characters/not.dart';
import 'package:petitparser/src/core/characters/optimize.dart';
import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts none of the specified characters.
Parser noneOf(String chars, [String message]) {
  return new CharacterParser(new NotCharacterPredicate(optimizedString(chars)),
      message ?? 'none of "${toReadableString(chars)}" expected');
}
