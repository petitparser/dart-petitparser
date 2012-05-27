// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

abstract class _Parser implements Parser {

}

/**
 * A parser that consumes nothing and always succeeds.
 */
class _EpsilonParser extends _Parser {

  Result parse(Context context) {
    return context.success(null);
  }

}

/**
 * A parser that consumes nothing and always fails.
 */
class _FailureParser extends _Parser {

  final String _message;

  _FailureParser(this._message);

  Result parse(Context context) {
    return context.failure(_message);
  }

}

/**
 * A parser that delegates to another one.
 */
abstract class _DelegateParser extends _Parser {

  final Parser _delegate;

  _DelegateParser(this._delegate);

  Result parse(Context context) {
    return _delegate.parse(context);
  }

}

/**
 * The and-predicate, a parser that succeeds whenever its delegate does, but
 * does not consume the input stream [Parr 1994, 1995].
 */
class _AndParser extends _DelegateParser {

  _AndParser(parser)
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isSuccess()) {
      return context.success(result.get());
    } else {
      return result;
    }
  }

}

/**
 * The not-predicate, a parser that succeeds whenever its delegate does not, but
 * consumes no input [Parr 1994, 1995].
 */
class _NotParser extends _DelegateParser {

  final String _message;

  _NotParser(parser, [this._message])
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isFailure()) {
      return context.success(null);
    } else {
      return context.failure(_message);
    }
  }

}


/**
 * A parser that succeeds only at the end of the input.
 */
class _EndOfInputParser extends _DelegateParser {

  final String _message;

  _EndOfInputParser(parser, this._message)
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isFailure() || result.getPosition() >= result.getBuffer().length) {
      return result;
    }
    return result.failure(_message, result.getPosition());
  }

}

/**
 * A parser that optionally parsers its delegate, or answers nil.
 */
class _OptionalParser extends _DelegateParser {

  _OptionalParser(parser)
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isSuccess()) {
      return result;
    } else {
      return context.success(null);
    }
  }

}

/**
 * A parser that repeatedly parses a sequence of parsers.
 */
class _RepeatingParser extends _DelegateParser {

  final int _min;
  final int _max;

  _RepeatingParser(parser, this._min, this._max)
    : super(parser);

  Result parse(Context context) {
    Context current = context;
    List<Dynamic> elements = new List();
    while (elements.length < _min) {
      Result result = super.parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.get());
      current = result;
    }
    while (elements.length < _max) {
      Result result = super.parse(current);
      if (result.isFailure()) {
        return current.success(elements);
      }
      elements.add(result.get());
      current = result;
    }
    return current.success(elements);
  }

}

/**
 * Abstract parser that parses a list of things in some way (to be specified by
 * the subclasses).
 */
abstract class _ListParser extends _Parser {
  final List<Parser> parsers;

  _ListParser(this.parsers);
}

/**
 * A parser that parses a sequence of parsers.
 */
class _SequenceParser extends _ListParser {

  _SequenceParser(parsers) : super(parsers);

  Result parse(Context context) {
    Context current = context;
    List<Dynamic> elements = new List<Dynamic>(parsers.length);
    for (Parser parser in parsers) {
      Result result = parser.parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.get());
      current = result;
    }
    return current.success(elements);
  }

}

/**
 * A parser that uses the first parser that succeeds.
 */
class _ChoiceParser extends _ListParser {

  _ChoiceParser(parsers) : super(parsers);

  Result parse(Context context) {
    Result result = context.failure("Empty choice");
    for (Parser parser in parsers) {
      result = parser.parse(context);
      if (result.isSuccess()) {
        return result;
      }
    }
    return result;
  }

}