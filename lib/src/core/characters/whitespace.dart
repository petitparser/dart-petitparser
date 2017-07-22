library petitparser.core.characters.whitespace;

import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any whitespace character.
Parser whitespace([String message = 'whitespace expected']) {
  return new CharacterParser(const WhitespaceCharPredicate(), message);
}

class WhitespaceCharPredicate implements CharacterPredicate {
  const WhitespaceCharPredicate();

  @override
  bool test(int value) {
    if (value < 256) {
      return value == 0x09 ||
          value == 0x0A ||
          value == 0x0B ||
          value == 0x0C ||
          value == 0x0D ||
          value == 0x20 ||
          value == 0x85 ||
          value == 0xA0;
    } else {
      return value == 0x1680 ||
          value == 0x180E ||
          value == 0x2000 ||
          value == 0x2001 ||
          value == 0x2002 ||
          value == 0x2003 ||
          value == 0x2004 ||
          value == 0x2005 ||
          value == 0x2006 ||
          value == 0x2007 ||
          value == 0x2008 ||
          value == 0x2009 ||
          value == 0x200A ||
          value == 0x2028 ||
          value == 0x2029 ||
          value == 0x202F ||
          value == 0x205F ||
          value == 0x3000 ||
          value == 0xFEFF;
    }
  }
}
