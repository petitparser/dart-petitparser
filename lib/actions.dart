// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {

  final Function _function;

  ActionParser(parser, this._function) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      return result.success(_function(result.getResult()));
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
    return current.success(result.getResult());
  }

  List<Parser> get children() => [_delegate, _trimmer];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_trimmer == source) {
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

  Dynamic _flatten(Dynamic buffer, int start, int stop) => buffer.substring(start, stop);

}

/**
 * A parser that answers a token of the range its delegate parses.
 */
class TokenParser extends FlattenParser {

  TokenParser(parser) : super(parser);

  Dynamic _flatten(Dynamic buffer, int start, int stop) => new Token(buffer, start, stop);

}

/**
 * A token represents a parsed part of the input stream. Contrary to a [String]
 * or a [List] it remembers the source [buffer] and the [start] and [stop] position
 * within that buffer.
 */
class Token {
  final Dynamic _buffer;
  final int _start;
  final int _stop;

  Token(this._buffer, this._start, this._stop);
  Token.on(String buffer): _buffer = buffer, _start = 0, _stop = buffer.length;

  bool operator == (Token other) => other is Token
      && _buffer === other._buffer
      && _start === other._start
      && _stop === other._stop;

  int get start() => _start;
  int get stop() => _stop;
  int get length() => _stop - _start;
  int get value() => _buffer.substring(_start, _stop);

  /** Returns the line number of this token. */
  int get line() {
    int line = 1;
    try {
      getLinefeedParser().token().matchesSkipping((Token token) {
        if (start <= token.start) {
          throw new NonLocalReturn(line);
        }
        line++;
      });
    } catch (NonLocalReturn e) {
      return e.value();
    }
    return line;
  }

  /** Returns the column number of this token. */
  int get column() {
    int position = 0;
    try {
      getLinefeedParser().token().matchesSkipping((Token token) {
        if (start <= token.start) {
          throw new NonLocalReturn(start - position);
        }
        position = token.start;
      });
    } catch (NonLocalReturn e) {
      return e.value();
    }
    return start - position;
  }

  String toString() => 'Token[start: $start, stop: $stop, value: $value]';

  static Parser LINEFEED_PARSER;

  static Parser getLinefeedParser() {
    if (LINEFEED_PARSER == null) {
      LINEFEED_PARSER = char('\n').or(char('\r').seq(char('\f').optional()));
    }
    return LINEFEED_PARSER;
  }
}

/** Non local return. */
class NonLocalReturn<T> implements Exception {
  final T _value;
  NonLocalReturn(this._value);
  T get value() => _value;
}