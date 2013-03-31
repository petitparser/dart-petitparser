// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * A token represents a parsed part of the input stream. The token holds
 * the parsed input, the input buffer, and the start and stop position
 * in the input buffer.
 */
class Token {

  /**
   * Returns the parsed value.
   */
  final dynamic value;

  /**
   * Returns the input buffer.
   */
  final dynamic buffer;

  /**
   * Returns the start position in the input buffer.
   */
  final int start;

  /**
   * Returns the stop position in the input buffer.
   */
  final int stop;

  const Token(this.value, this.buffer, this.start, this.stop);

  bool operator == (Token other) {
    return other is Token
      && value == other._value
      && start == other._start
      && stop == other._stop;
  }

  int get hashCode => value.hashCode + start.hashCode + stop.hashCode;

  /**
   * Returns the length of the token.
   */
  int get length => stop - start;

  /**
   * Returns the line number of the token.
   */
  int get line {
    var line = 1;
    for (var each in newlineParser().token().matchesSkipping(buffer)) {
      if (start < each.stop) {
        return line;
      }
      line++;
    }
    return line;
  }

  /**
   * Returns the column number of this token.
   */
  int get column {
    var position = 0;
    for (var each in newlineParser().token().matchesSkipping(buffer)) {
      if (start < each.stop) {
        return start - position + 1;
      }
      position = each.stop;
    }
    return start - position + 1;
  }

  String toString() => 'Token[start: $start, stop: $stop, value: $value]';

  static final Parser _NEWLINE_PARSER =
      char('\n').or(char('\r').seq(char('\n').optional()));

  static Parser newlineParser() => _NEWLINE_PARSER;

}