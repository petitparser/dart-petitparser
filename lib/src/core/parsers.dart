// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/** Returns a parser that consumes nothing and succeeds. */
Parser epsilon() => new _EpsilonParser();

class _EpsilonParser extends Parser {
  Result _parse(Context context) => context.success(null);
}

/** Returns a parser that consumes nothing and fails. */
Parser failure(String message) => new _FailureParser(message);

class _FailureParser extends Parser {
  final String _message;
  _FailureParser(this._message);
  Result _parse(Context context) => context.failure(_message);
}

/**
 * A parser that delegates to another one.
 */
class DelegateParser extends Parser {

  Parser _delegate;

  DelegateParser(this._delegate);

  Result _parse(Context context) {
    return _delegate._parse(context);
  }

  List<Parser> get children => [_delegate];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (identical(_delegate, source)) {
      _delegate = target;
    }
  }

}

/**
 * A parser that succeeds only at the end of the input.
 */
class EndOfInputParser extends DelegateParser {

  final String _message;

  EndOfInputParser(parser, this._message)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isFailure() || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.position);
  }

}