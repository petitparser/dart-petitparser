library petitparser.matcher.pattern;

import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'match.dart';

extension PatternParser<T> on Parser<T> {
  /// Converts this [Parser] into a [Pattern] for basic searches within strings.
  Pattern toPattern() => ParserPattern(this);
}

@immutable
class ParserPattern implements Pattern {
  final Parser parser;

  const ParserPattern(this.parser);

  /// Matches this parser against [string] repeatedly.
  ///
  /// If [start] is provided, matching will start at that index. The returned
  /// iterable lazily computes all the non-overlapping matches of the parser on
  /// the string, ordered by start index.
  ///
  /// If the pattern matches the empty string at some point, the next match is
  /// found by starting at the previous match's end plus one.
  @override
  Iterable<Match> allMatches(String string, [int start = 0]) sync* {
    while (start <= string.length) {
      final match = matchAsPrefix(string, start);
      if (match == null) {
        start++;
      } else {
        yield match;
        if (start == match.end) {
          start++;
        } else {
          start = match.end;
        }
      }
    }
  }

  /// Match this pattern against the start of [string].
  ///
  /// If [start] is provided, this parser is tested against the string at the
  /// [start] position. That is, a [Match] is returned if the pattern can match
  /// a part of the string starting from position [start].
  ///
  /// Returns `null` if the pattern doesn't match.
  @override
  Match matchAsPrefix(String string, [int start = 0]) {
    final end = parser.fastParseOn(string, start);
    return end < 0 ? null : ParserMatch(this, string, start, end);
  }
}
