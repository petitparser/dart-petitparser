import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'code.dart';
import 'predicate.dart';

/// Returns a parser that accepts any character in the range
/// between [start] and [stop].
@useResult
Parser<String> range(String start, String stop, [String? message]) =>
    SingleCharacterParser(
        RangeCharPredicate(toCharCode(start), toCharCode(stop)),
        message ??
            '[${toReadableString(start)}-${toReadableString(stop)}] expected');

/// Returns a parser that accepts any character in the range
/// between [start] and [stop].
@useResult
Parser<String> rangeUnicode(String start, String stop, [String? message]) =>
    UnicodeCharacterParser(
        RangeCharPredicate(
            toCharCode(start, unicode: true), toCharCode(stop, unicode: true)),
        message ??
            '[${toReadableString(start, unicode: true)}-'
                '${toReadableString(stop, unicode: true)}] expected');

class RangeCharPredicate implements CharacterPredicate {
  const RangeCharPredicate(this.start, this.stop)
      : assert(start <= stop, 'Invalid range character range: $start-$stop');

  final int start;
  final int stop;

  @override
  bool test(int value) => start <= value && value <= stop;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangeCharPredicate && start == other.start && stop == other.stop;
}
