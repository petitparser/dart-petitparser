// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Abstract base class for all parsers.
 */
/* TODO(renggli): abstract */ class Parser {

  abstract Result parse(Context context);

  Parser operator >> (Function function) {
    return new ActionParser(this, function);
  }

  Parser operator & (Parser other) {
    return new SequenceParser([this, other]);
  }

  Parser operator | (Parser other) {
    return new ChoiceParser([this, other]);
  }

}

/**
 * A parser that consumes nothing and always succeeds.
 */
class EpsilonParser extends Parser {

  Result parse(Context context) {
    return context.success(null);
  }

}

/**
 * A parser that consumes nothing and always fails.
 */
class FailureParser extends Parser {

  final String _message;

  FailureParser(this._message);

  Result parse(Context context) {
    return context.failure(_message);
  }

}

/**
 * A parser that delegates to another one.
 */
class DelegateParser extends Parser {

  final Parser _delegate;

  DelegateParser(this._delegate);

  Result parse(Context context) {
    return _delegate.parse(context);
  }

}

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {

  final Function _function;

  ActionParser(parser, this._function)
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isSuccess()) {
      return result.success(_function(result.get()));
    } else {
      return result;
    }
  }

}

/**
 * The and-predicate, a parser that succeeds whenever its delegate does, but
 * does not consume the input stream [Parr 1994, 1995].
 */
class AndParser extends DelegateParser {

  AndParser(parser)
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
class NotParser extends DelegateParser {

  final String _message;

  NotParser(parser, [this._message])
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
class EndOfInputParser extends DelegateParser {

  final String _message;

  EndOfInputParser(parser, this._message)
    : super(parser);

  Result parse(Context context) {
    Result result = super.parse(context);
    if (result.isFailure() || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.getPosition());
  }

}

/**
 * A parser that optionally parsers its delegate, or answers nil.
 */
class OptionalParser extends DelegateParser {

  OptionalParser(parser)
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
class RepeatingParser extends DelegateParser {

  final int _min;
  final int _max;

  RepeatingParser(parser, this._min, this._max)
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
/* TODO(renggli): abstract */ class ListParser extends Parser {
  final List<Parser> _parsers;

  ListParser(this._parsers);
}

/**
 * A parser that parses a sequence of parsers.
 */
class SequenceParser extends ListParser {

  SequenceParser(_parsers)
    : super(_parsers);

  Result parse(Context context) {
    Context current = context;
    List<Dynamic> elements = new List<Dynamic>(parsers.length);
    for (Parser parser in _parsers) {
      Result result = parser.parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.get());
      current = result;
    }
    return current.success(elements);
  }

  Parser operator & (Parser other) {
    List<Parser> parsers = new List.from(_parsers);
    parsers.addLast(other);
    return new SequenceParser(parsers);
  }

}

/**
 * A parser that uses the first parser that succeeds.
 */
class ChoiceParser extends ListParser {

  ChoiceParser(_parsers)
    : super(_parsers);

  Result parse(Context context) {
    Result result = context.failure('Empty choice');
    for (Parser parser in _parsers) {
      result = parser.parse(context);
      if (result.isSuccess()) {
        return result;
      }
    }
    return result;
  }

  Parser operator | (Parser other) {
    List<Parser> parsers = new List.from(_parsers);
    parsers.addLast(other);
    return new ChoiceParser(parsers);
  }

}

/**
 * Predicate function definition for the [PredicateParser].
 */
typedef bool Predicate(Dynamic object);

/**
 * A parser for a single element satisfying a predicate.
 */
class PredicateParser extends Parser {

  final Predicate _predicate;
  final String _message;

  PredicateParser(this._predicate, this._message);

  Result parse(Context context) {
    if (context.position < context.buffer.length) {
      if (_predicate(context.buffer[context.position])) {
        return context.success(result, context.position + 1);
      }
    }
    return context.failure(_message);
  }

  static PredicateParser any([String message]) {
    return new PredicateParser(
      (each) => true,
      message != null ? message : 'input expected');
  }

  static PredicateParser anyOf(List<Dynamic> list, [String message]) {
    return new PredicateParser(
      (each) => list.includes(each),
      message != null ? message : 'any of $list expected');
  }

  static PredicateParser expect(Dynamic element, [String message]) {
    return new PredicateParser(
      (each) => element == each,
      message != null ? message : '$element expected');
  }

  static PredicateParser range(String start, String stop, [String message]) {
    return new PredicateParser(
      (each) => (start <= each && each <= stop),
      message != null ? message : '$start..$stop expected');
  }

  static PredicateParser whitespace([String message]) {
    return new PredicateParser(
      (each) => (each == ' ') || (each == '\t') || (each == '\n') || (each == '\r') || (each == '\f'),
      message != null ? message : 'whitespace expected');
  }

  static PredicateParser digit([String message]) {
    return new PredicateParser(
      (each) => ('0' <= each && each <= '9'),
      message != null ? message : 'digit expected');
  }

  static PredicateParser letter([String message]) {
    return new PredicateParser(
      (each) => ('a' <= each && each <= 'z') || ('A' <= each && each <= 'Z'),
      message != null ? message : 'letter expected');
  }

  static PredicateParser lowercase([String message]) {
    return new PredicateParser(
      (each) => ('a' <= each && each <= 'z'),
      message != null ? message : 'lowercase letter expected');
  }

  static PredicateParser uppercase([String message]) {
    return new PredicateParser(
      (each) => ('A' <= each && each <= 'Z'),
      message != null ? message : 'uppercase letter expected');
  }

  static PredicateParser word([String message]) {
    return new PredicateParser(
      (each) => ('0' <= each && each <= '9') || ('a' <= each && each <= 'z') || ('A' <= each && each <= 'Z'),
      message != null ? message : 'letter or digit expected');
  }

}