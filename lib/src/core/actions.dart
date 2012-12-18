// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/** Function interface for parse actions. */
typedef dynamic _ActionFunction(dynamic argument);

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {

  final _ActionFunction _function;

  ActionParser(parser, this._function) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      return result.success(_function(result.result));
    } else {
      return result;
    }
  }

}

/**
 * A parser that silently consumes input of a parser around its delegate.
 */
class TrimmingParser extends DelegateParser {

  Parser _trimmer;

  TrimmingParser(parser, this._trimmer) : super(parser);

  Result _parse(Context context) {
    var current = context;
    do {
      current = _trimmer._parse(current);
    } while (current.isSuccess());
    var result = super._parse(current);
    if (result.isFailure()) {
      return result;
    }
    current = result;
    do {
      current = _trimmer._parse(current);
    } while (current.isSuccess());
    return current.success(result.result);
  }

  List<Parser> get children => [_delegate, _trimmer];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (identical(_trimmer, source)) {
      _trimmer = target;
    }
  }

}

/**
 * A parser that answers a substring of the range its delegate parses.
 */
class FlattenParser extends DelegateParser {

  FlattenParser(parser) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      return result.success(_flatten(context.buffer, context.position, result.position));
    } else {
      return result;
    }
  }

  dynamic _flatten(dynamic buffer, int start, int stop) => buffer.substring(start, stop);

}

/**
 * A parser that answers a token of the range its delegate parses.
 */
class TokenParser extends FlattenParser {

  TokenParser(parser) : super(parser);

  dynamic _flatten(dynamic buffer, int start, int stop) => new Token(buffer, start, stop);

}

/**
 * A token represents a parsed part of the input stream. Contrary to a [String]
 * or a [List] it remembers the source [buffer] and the [start] and [stop] position
 * within that buffer.
 */
class Token {
  final dynamic _buffer;
  final int _start;
  final int _stop;

  const Token(this._buffer, this._start, this._stop);

  bool operator == (Token other) => other is Token
      && _buffer == other._buffer
      && _start == other._start
      && _stop == other._stop;

  int get start => _start;
  int get stop => _stop;
  int get length => _stop - _start;

  dynamic get buffer => _buffer;
  dynamic get value => _buffer.substring(_start, _stop);

  /** Returns the line number of this token. */
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

  /** Returns the column number of this token. */
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

  static Parser NEWLINE_PARSER;
  static Parser newlineParser() {
    if (NEWLINE_PARSER == null) {
      NEWLINE_PARSER = char('\n').or(char('\r').seq(char('\n').optional()));
    }
    return NEWLINE_PARSER;
  }

}