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
  /// For example, with the parser
  ///
  ///     final parser = letter().plus().flatten();
  ///
  /// `parser.allMatches('abc de')` results in the iterable `['abc', 'de']`; and
  /// `parser.allMatches('abc de', overlapping: true)` results in the iterable
  /// `['abc', 'bc', 'c', 'de', 'e']`.
  Iterable<T> allMatches(String input,
          {int start = 0, bool overlapping = false}) =>
      MatchesIterable<T>(this, input, start, overlapping);
}
