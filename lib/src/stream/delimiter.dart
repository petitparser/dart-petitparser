import 'dart:math' as math;

import '../core/parser.dart';
import '../parser/action/flatten.dart';
import '../parser/character/predicate/char.dart';
import '../parser/combinator/choice.dart';
import '../parser/combinator/delegate.dart';
import '../parser/combinator/sequence.dart';
import '../parser/predicate/character.dart';
import '../parser/predicate/string.dart';

/// Internal helper for delimiter-accelerated searching across streams and iterables.
class DelimiterSearcher {
  /// Creates a [DelimiterSearcher] for the specified [delimiter].
  new(this.delimiter)
    : _literal = _extractLiteral(delimiter),
      _overlap = _parserOverlap(delimiter);

  /// The delimiter parser.
  final Parser<dynamic> delimiter;

  /// Precomputed literal string or single character for fast searching.
  final String? _literal;

  /// The maximum overlap across chunk boundaries for this delimiter.
  final int _overlap;

  /// The maximum overlap across chunk boundaries for this delimiter.
  int get overlap => _overlap;

  /// Finds the next occurrence of [delimiter] in [buffer] starting from [start].
  ///
  /// Returns the start position of the match, or `-1` if no candidate is found.
  int find(String buffer, int start) {
    final literal = _literal;
    if (literal != null) {
      return buffer.indexOf(literal, start);
    }
    for (var i = start; i <= buffer.length; i++) {
      if (delimiter.fastParseOn(buffer, i) >= 0) {
        return i;
      }
    }
    return -1;
  }

  static String? _extractLiteral(Parser delimiter) {
    var current = delimiter;
    while (current is FlattenParser) {
      current = current.delegate;
    }
    if (current is StringParser && current is! StringIgnoreCaseParser) {
      return current.literal;
    }
    if (current case CharacterParser(
      predicate: SingleCharPredicate(:final charCode),
    )) {
      return String.fromCharCode(charCode);
    }
    return null;
  }

  static int _parserOverlap(Parser? parser) {
    if (parser == null) return 0;
    while (parser is DelegateParser) {
      parser = parser.delegate;
    }
    if (parser is StringParser) {
      return math.max(0, parser.literal.length - 1);
    }
    if (parser is CharacterParser) {
      return 0;
    }
    if (parser is ChoiceParser) {
      var max = 0;
      for (final child in parser.children) {
        max = math.max(max, _parserOverlap(child));
      }
      return max;
    }
    if (parser is SequenceParser) {
      var total = 0;
      for (final child in parser.children) {
        final childLength = _parserLength(child);
        if (childLength == 0) return 0;
        total += childLength;
      }
      return math.max(0, total - 1);
    }
    return 0;
  }

  static int _parserLength(Parser parser) {
    while (parser is DelegateParser) {
      parser = parser.delegate;
    }
    if (parser is StringParser) return parser.literal.length;
    if (parser is CharacterParser) return 1;
    if (parser is SequenceParser) {
      var total = 0;
      for (final child in parser.children) {
        final childLength = _parserLength(child);
        if (childLength == 0) return 0;
        total += childLength;
      }
      return total;
    }
    return 0;
  }
}
