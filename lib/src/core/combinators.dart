// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * The and-predicate, a parser that succeeds whenever its delegate does, but
 * does not consume the input stream [Parr 1994, 1995].
 */
class AndParser extends DelegateParser {

  AndParser(parser) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess()) {
      return context.success(result.result);
    } else {
      return result;
    }
  }

}

/**
 * A parser that uses the first parser that succeeds.
 */
class ChoiceParser extends ListParser {

  ChoiceParser(_parsers) : super(_parsers);

  Result _parse(Context context) {
    var result;
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

/**
 * Abstract parser that parses a list of things in some way (to be specified by
 * the subclasses).
 */
abstract class ListParser extends Parser {

  final List<Parser> _parsers;

  ListParser(this._parsers);

  List<Parser> get children => _parsers;

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    for (var i = 0; i < _parsers.length; i++) {
      if (identical(_parsers[i], source)) {
        _parsers[i] = target;
      }
    }
  }

}

/**
 * The not-predicate, a parser that succeeds whenever its delegate does not, but
 * consumes no input [Parr 1994, 1995].
 */
class NotParser extends DelegateParser {

  final String _message;

  NotParser(parser, this._message) : super(parser);

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
 * A parser that optionally parsers its delegate, or answers nil.
 */
class OptionalParser extends DelegateParser {

  OptionalParser(parser) : super(parser);

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

  RepeatingParser(parser, this._min, this._max) : super(parser);

  Result _parse(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = super._parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements.add(result.result);
      current = result;
    }
    while (elements.length < _max) {
      var result = super._parse(current);
      if (result.isFailure()) {
        return current.success(elements);
      }
      elements.add(result.result);
      current = result;
    }
    return current.success(elements);
  }

}

/**
 * A parser that parses a sequence of parsers.
 */
class SequenceParser extends ListParser {

  SequenceParser(_parsers) : super(_parsers);

  Result _parse(Context context) {
    var current = context;
    var elements = new List(_parsers.length);
    for (var i = 0; i < _parsers.length; i++) {
      var result = _parsers[i]._parse(current);
      if (result.isFailure()) {
        return result;
      }
      elements[i] = result.result;
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
 * A parser that wraps another one.
 */
class WrapperParser extends DelegateParser {
  WrapperParser(parser) : super(parser);
}