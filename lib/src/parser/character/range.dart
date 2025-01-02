import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
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

class RangeCharPredicate extends CharacterPredicate {
  const RangeCharPredicate(this.start, this.stop)
      : assert(start <= stop, 'Invalid range character range: $start-$stop');

  final int start;
  final int stop;

  @override
  bool test(int charCode) => start <= charCode && charCode <= stop;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangeCharPredicate && start == other.start && stop == other.stop;

  @override
  String toString() => '${super.toString()}($start, $stop)';
}
