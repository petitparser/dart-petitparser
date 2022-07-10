import '../core/parser.dart';
import 'matches/matches_iterable.dart';

extension MatchesParserExtension<T> on Parser<T> {
  /// Returns a _lazy iterable_ over all successful parse results of type [T] of
  /// the provided [input].
  ///
  /// If [start] is provided, parsing will start at that character.
  ///
  /// By default only non-overlapping parse results will be returned, but this
  /// can be changed by setting [overlapping] to `true`.
  ///
  /// For example, `letter().plus().flatten().allMatches('abc de')` results
  /// in the iterable `['abc', 'de']`.
  Iterable<T> allMatches(String input,
          {int start = 0, bool overlapping = false}) =>
      MatchesIterable<T>(this, input, start, overlapping);

  /// Returns a lazy iterable of all successful overlapping parses of the
  /// provided [input].
  ///
  /// For example, `letter().plus().matches('abc de')` results in the iterable
  /// `[['a', 'b', 'c'], ['b', 'c'], ['c'], ['d', 'e'], ['e']]`.
  @Deprecated('Use `allMatches(input, overlapping: true)` instead.')
  Iterable<T> matches(String input) => allMatches(input, overlapping: true);

  /// Returns a lazy iterable of all successful non-overlapping parses of the
  /// provided [input].
  ///
  /// For example, `letter().plus().matchesSkipping('abc de')` results in the
  /// iterable `[['a', 'b', 'c'], ['d', 'e']]`.
  @Deprecated('Use `allMatches(input, overlapping: false)` instead.')
  Iterable<T> matchesSkipping(String input) =>
      allMatches(input, overlapping: false);
}
