library petitparser.matcher.matches;

import '../core/parser.dart';
import '../parsers/actions/map.dart';
import '../parsers/combinators/and.dart';
import '../parsers/combinators/choice.dart';
import '../parsers/combinators/sequence.dart';
import '../parsers/predicates/any.dart';
import '../parsers/repeaters/possesive.dart';
import 'matches_skipping.dart';

extension MatchesParser<T> on Parser<T> {
  /// Returns a list of all successful overlapping parses of the [input].
  ///
  /// For example, `letter().plus().matches('abc de')` results in the list
  /// `[['a', 'b', 'c'], ['b', 'c'], ['c'], ['d', 'e'], ['e']]`. See
  /// [matchesSkipping] to retrieve non-overlapping parse results.
  List<T> matches(String input) {
    final list = <T>[];
    and()
        .map(list.add, hasSideEffects: true)
        .seq(any())
        .or(any())
        .star()
        .fastParseOn(input, 0);
    return list;
  }
}
