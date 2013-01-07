// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * A token represents a parsed part of the input stream. Contrary to a
 * [String] or a [List] a token remembers the source [buffer] and the
 * [start] and [stop] position within that buffer.
 */
class Token {

  final dynamic _buffer;
  final int _start;
  final int _stop;

  const Token(this._buffer, this._start, this._stop);

  bool operator == (Token other) {
    return other is Token
      && _buffer == other._buffer
      && _start == other._start
      && _stop == other._stop;
  }

  int get hashCode => _buffer.hashCode + _start.hashCode + _stop.hashCode;

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
   * Returns the input buffer.
   */
  dynamic get buffer => _buffer;

  /**
   * Returns the valud of the token.
   */
  dynamic get value => _buffer.substring(_start, _stop);

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

  static Parser _NEWLINE_PARSER;

  static Parser newlineParser() {
    if (_NEWLINE_PARSER == null) {
      _NEWLINE_PARSER = char('\n').or(char('\r').seq(char('\n').optional()));
    }
    return _NEWLINE_PARSER;
  }

}


/**
 * A parser that answers a token of the range its delegate parses.
 */
class _TokenParser extends _FlattenParser {

  _TokenParser(parser) : super(parser);

  dynamic _flatten(dynamic buffer, int start, int stop) {
    return new Token(buffer, start, stop);
  }

}