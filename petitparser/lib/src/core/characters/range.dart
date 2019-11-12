library petitparser.core.characters.range;

import '../parser.dart';
import 'code.dart';
import 'parser.dart';
import 'predicate.dart';

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

  RangeCharPredicate(this.start, this.stop)
      : assert(start != null, 'start must not be null'),
        assert(stop != null, 'stop must not be null') {
    if (start > stop) {
      throw ArgumentError('Invalid range: $start-$stop');
    }
  }

  @override
  bool test(int value) => start <= value && value <= stop;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangeCharPredicate && other.start == start && other.stop == stop;
}
