library petitparser.core.characters.range;

import 'package:petitparser/src/core/characters/code.dart';
import 'package:petitparser/src/core/characters/parser.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any character in the range
/// between [start] and [stop].
Parser<String> range(Object start, Object stop, [String message]) {
  return CharacterParser(
      RangeCharPredicate(toCharCode(start), toCharCode(stop)),
      message ??
          '${toReadableString(start)}..${toReadableString(stop)} expected');
}

class RangeCharPredicate implements CharacterPredicate {
  final int start;
  final int stop;

  RangeCharPredicate(this.start, this.stop) {
    if (start > stop) {
      throw ArgumentError('Invalid range: $start-$stop');
    }
  }

  @override
  bool test(int value) => start <= value && value <= stop;
}
