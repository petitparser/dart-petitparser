// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * A token represents a parsed part of the input stream. The token holds
 * the parsed input, the input buffer, and the start and stop position
 * in the input buffer.
 */
class Token {

  final dynamic _value;
  final dynamic _buffer;
  final int _start;
  final int _stop;

  const Token(this._value, this._buffer, this._start, this._stop);

  bool operator == (Token other) {
    return other is Token
      && _value == other._value
      && _start == other._start
      && _stop == other._stop;
  }

  int get hashCode => _value.hashCode + _start.hashCode + _stop.hashCode;

  /**
   * Returns the parsed value.
   */
  dynamic get value => _value;


  /**
   * Returns the input buffer.
   */
  dynamic get buffer => _buffer;

  /**
   * Returns the start position in the input buffer.
   */
  int get start => _start;

  /**
   * Returns the stop position in the input buffer.
   */
  int get stop => _stop;

  /**
   * Returns the length of the token.
   */
  int get length => _stop - _start;

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