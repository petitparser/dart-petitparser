library petitparser.core.token;

import 'package:meta/meta.dart';

import '../matcher/matches_skipping.dart';
import '../parser/action/token.dart';
import '../parser/character/char.dart';
import '../parser/combinator/choice.dart';
import '../parser/combinator/optional.dart';
import '../parser/combinator/sequence.dart';
import 'parser.dart';

/// A token represents a parsed part of the input stream.
///
/// The token holds the resulting value of the input, the input buffer,
/// and the start and stop position in the input buffer. It provides many
/// convenience methods to access the state of the token.
@immutable
class Token<T> {
  /// Constructs a token from the parsed value, the input buffer, and the
  /// start and stop position in the input buffer.
  const Token(this.value, this.buffer, this.start, this.stop);

  /// The parsed value of the token.
  final T value;

  /// The parsed buffer of the token.
  final String buffer;

  /// The start position of the token in the buffer.
  final int start;

  /// The stop position of the token in the buffer.
  final int stop;

  /// The consumed input of the token.
  String get input => buffer.substring(start, stop);

  /// The length of the token.
  int get length => stop - start;

  /// The line number of the token (only works for [String] buffers).
  int get line => Token.lineAndColumnOf(buffer, start)[0];

  /// The column number of this token (only works for [String] buffers).
  int get column => Token.lineAndColumnOf(buffer, start)[1];

  @override
  String toString() => 'Token[${positionString(buffer, start)}]: $value';

  @override
  bool operator ==(Object other) {
    return other is Token &&
        value == other.value &&
        start == other.start &&
        stop == other.stop;
  }

  @override
  int get hashCode => value.hashCode + start.hashCode + stop.hashCode;

  /// Returns a parser for that detects newlines platform independently.
  static Parser newlineParser() => _newlineParser;

  static final Parser _newlineParser =
      char('\n') | (char('\r') & char('\n').optional());

  /// Converts the [position] index in a [buffer] to a line and column tuple.
  static List<int> lineAndColumnOf(String buffer, int position) {
    var line = 1, offset = 0;
    for (final token in newlineParser().token().matchesSkipping(buffer)) {
      if (position < token.stop) {
        return [line, position - offset + 1];
      }
      line++;
      offset = token.stop;
    }
    return [line, position - offset + 1];
  }

  /// Returns a human readable string representing the [position] index in a
  /// [buffer].
  static String positionString(String buffer, int position) {
    final lineAndColumn = lineAndColumnOf(buffer, position);
    return '${lineAndColumn[0]}:${lineAndColumn[1]}';
  }
}
