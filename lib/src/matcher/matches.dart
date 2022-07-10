import '../core/parser.dart';
import 'matches/matches_iterable.dart';

extension MatchesParserExtension<T> on Parser<T> {
  /// Returns a _lazy iterable_ over all non-overlapping successful parse
  /// results of type [T] over the provided [input].
  ///
  /// If [start] is provided, parsing will start at that index.
  ///
  /// If [overlapping] is set to `true`, the parsing is attempted at each input
  /// position and does not skip over previous matches.
  ///
  /// For example, `letter().plus().flatten().allMatches('abc de')` results
  /// in the iterable `['abc', 'de']`. `letter().plus().allMatches('abc de',
  /// overlapping: true)` results in the iterable `['abc', 'bc', 'c',
  /// 'de', 'e']`.
  Iterable<T> allMatches(String input,
          {int start = 0, bool overlapping = false}) =>
      MatchesIterable<T>(this, input, start, overlapping);

  /// Returns a list of all successful overlapping parses of [input].
  ///
  /// For example, `letter().plus().matches('abc de')` results in the list
  /// `[['a', 'b', 'c'], ['b', 'c'], ['c'], ['d', 'e'], ['e']]`.
  @Deprecated('Use `allMatches(input, overlapping: true)` instead.')
  List<T> matches(String input) =>
      allMatches(input, overlapping: true).toList();

  /// Returns a list of all successful non-overlapping parses of [input].
  ///
  /// For example, `letter().plus().matchesSkipping('abc de')` results in the
  /// list `[['a', 'b', 'c'], ['d', 'e']]`.
  @Deprecated('Use `allMatches(input, overlapping: false)` instead.')
  List<T> matchesSkipping(String input) =>
      allMatches(input, overlapping: false).toList();
}
