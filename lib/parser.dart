// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Abstract base class for all parsers.
 */
abstract class Parser {

  // parsing related functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  /** Internal abstract method doing the actual parsing. */
  abstract Result _parse(Context context);

  /** Returns the parse result of the input. */
  Result parse(Dynamic input) {
    return _parse(new Context(input, 0));
  }

  /** Tests if the input can be successfully parsed. */
  bool accept(Dynamic input) {
    return parse(input).isSuccess();
  }

  /** Returns a list of all successful overlapping parses of the input. */
  List<Dynamic> matches(Dynamic input) {
    var list = new List();
    and().map((each) => list.add(each)).seq(any()).or(any()).star().parse(input);
    return list;
  }

  /** Returns a list of all successful non-overlapping parses of the input. */
  List<Dynamic> matchesSkipping(Dynamic input) {
    var list = new List();
    map((each) => list.add(each)).or(any()).star().parse(input);
    return list;
  }

  // parser combinator functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  Parser optional() => new OptionalParser(this);
  Parser star() => new RepeatingParser(this, 0, 65536);
  Parser plus() => new RepeatingParser(this, 1, 65536);
  Parser times(int count) => new RepeatingParser(this, count, count);
  Parser repeat(int min, int max) => new RepeatingParser(this, min, max);

  Parser seq(Parser other) => new SequenceParser([this, other]);
  Parser or(Parser other) => new ChoiceParser([this, other]);

  Parser and() => new AndParser(this);
  Parser not([String message]) => new NotParser(this, message);
  Parser neg([String message]) => not(message).seq(any()).map((each) => each[1]);

  Parser wrapper() => new WrapperParser(this);
  Parser flatten() => new FlattenParser(this);
  Parser trim([Parser trimmer]) => new TrimmingParser(this, trimmer == null ? whitespace() : trimmer);
  Parser map(Function function) => new ActionParser(this, function);
  Parser end([String message]) => new EndOfInputParser(this, message == null ? 'end of input expected' : message);

  Parser separatedBy(Parser separator) {
    return new SequenceParser([this, new SequenceParser([separator, this]).star()]).map((List list) {
      var result = new List();
      result.add(list[0]);
      list[1].forEach((each) => result.addAll(each));
      return result;
    });
  }
  Parser withoutSeparators() {
    return map((List list) {
      var result = new List();
      for (var i = 0; i < list.length; i += 2) {
        result.add(list[i]);
      }
      return result;
    });
  }

  // reflection functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  /** Returns a list of directly referring parsers. */
  List<Parser> get children() => [];

  /** Replaces [source] with [target], if [source] exists. */
  void replace(Parser source, Parser target) {
    // no children, nothing to do
  }

}

/**
 * A parser that consumes nothing and always succeeds.
 */
class EpsilonParser extends Parser {

  Result _parse(Context context) {
    return context.success(null);
  }

}

/**
 * A parser that consumes nothing and always fails.
 */
class FailureParser extends Parser {

  final String _message;

  FailureParser(this._message);

  Result _parse(Context context) {
    return context.failure(_message);
  }

}

/**
 * A parser that delegates to another one.
 */
abstract class DelegateParser extends Parser {

  Parser _delegate;

  DelegateParser(this._delegate);

  Result _parse(Context context) {
    return _delegate._parse(context);
  }

  List<Parser> get children() => [_delegate];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_delegate == source) {
      _delegate = target;
    }
  }

}

/**
 * A parser that wraps to another one.
 */
class WrapperParser extends DelegateParser {
  WrapperParser(parser) : super(parser);
}


/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {

  final Function _function;

  ActionParser(parser, this._function)
    : super(parser);

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
 * The and-predicate, a parser that succeeds whenever its delegate does, but
 * does not consume the input stream [Parr 1994, 1995].
 */
class AndParser extends DelegateParser {

  AndParser(parser)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      return context.success(result.getResult());
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

  NotParser(parser, this._message)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
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

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isFailure() || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.position);
  }

}

/**
 * A parser that answers a flat copy of the range my delegate parses.
 */
class FlattenParser extends DelegateParser {

  FlattenParser(parser)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      var flattened = context.buffer.substring(context.position, result.position);
      return result.success(flattened);
    } else {
      return result;
    }
  }

}

/**
 * A parser that silently consumes spaces before and after the delegate parser.
 */
class TrimmingParser extends DelegateParser {

  Parser _trimmer;

  TrimmingParser(parser, this._trimmer)
    : super(parser);

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
 * A parser that optionally parsers its delegate, or answers nil.
 */
class OptionalParser extends DelegateParser {

  OptionalParser(parser)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
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

  Result _parse(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = super._parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.getResult());
      current = result;
    }
    while (elements.length < _max) {
      var result = super._parse(current);
      if (result.isFailure()) {
        return current.success(elements);
      }
      elements.add(result.getResult());
      current = result;
    }
    return current.success(elements);
  }

}

/**
 * Abstract parser that parses a list of things in some way (to be specified by
 * the subclasses).
 */
abstract class ListParser extends Parser {
  final List<Parser> _parsers;

  ListParser(this._parsers);

  List<Parser> get children() => _parsers;

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    for (var i = 0; i < _parsers.length; i++) {
      if (_parsers[i] == source) {
        _parsers[i] = target;
      }
    }
  }

}

/**
 * A parser that parses a sequence of parsers.
 */
class SequenceParser extends ListParser {

  SequenceParser(_parsers)
    : super(_parsers);

  Result _parse(Context context) {
    var current = context;
    var elements = new List<Dynamic>();
    for (var parser in _parsers) {
      var result = parser._parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.getResult());
      current = result;
    }
    return current.success(elements);
  }

  Parser seq(Parser other) {
    var parsers = new List.from(_parsers);
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

  Result _parse(Context context) {
    var result = context.failure('Empty choice');
    for (var parser in _parsers) {
      result = parser._parse(context);
      if (result.isSuccess()) {
        return result;
      }
    }
    return result;
  }

  Parser or(Parser other) {
    var parsers = new List.from(_parsers);
    parsers.addLast(other);
    return new ChoiceParser(parsers);
  }

}

Parser any([String message]) {
  return new PredicateParser(1,
    (each) => true,
    message != null ? message : 'input expected');
}

Parser anyIn(Dynamic elements, [String message]) {
  return new PredicateParser(1,
    (each) => elements.indexOf(each) >= 0,
    message != null ? message : 'any of $elements expected');
}

Parser string(String element, [String message]) {
  return new PredicateParser(element.length,
    (String each) => element == each,
    message != null ? message : '$element expected');
}

Parser stringIgnoreCase(String element, [String message]) {
  final lowerElement = element.toLowerCase();
  return new PredicateParser(element.length,
    (String each) => lowerElement == each.toLowerCase(),
    message != null ? message : '$element expected');
}

/**
 * A parser for a single literal satisfying a predicate.
 */
class PredicateParser extends Parser {

  final int _length;
  final Function _predicate;
  final String _message;

  PredicateParser(this._length, this._predicate, this._message);

  Result _parse(Context context) {
    final start = context.position;
    final stop = start + _length;
    if (stop <= context.buffer.length) {
      var result = context.buffer.substring(start, stop);
      if (_predicate(result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(_message);
  }

}