// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * A parser that delegates to another one. Normally users do not need to
 * directly use a delegate parser.
 */
class DelegateParser extends ParserBase {

  ParserBase _delegate;

  DelegateParser(this._delegate);

  @override
  Result parseOn(Context context) => _delegate.parseOn(context);

  @override
  List<ParserBuilder> get children => [_delegate];

  @override
  void replace(ParserBuilder source, ParserBuilder target) {
    super.replace(source, target);
    if (_delegate == source) {
      _delegate = target;
    }
  }

  @override
  ParserBuilder copy() => new DelegateParser(_delegate);

}

/**
 * A parser that succeeds only at the end of the input.
 */
class _EndOfInputParser extends DelegateParser {

  final String _message;

  _EndOfInputParser(parser, this._message) : super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isFailure || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.position);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  ParserBuilder copy() => new _EndOfInputParser(_delegate, _message);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen) && _message == other._message;
  }

}

/**
 * The and-predicate, a parser that succeeds whenever its delegate does, but
 * does not consume the input stream [Parr 1994, 1995].
 */
class _AndParser extends DelegateParser {

  _AndParser(parser) : super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      return context.success(result.value);
    } else {
      return result;
    }
  }

  @override
  ParserBuilder copy() => new _AndParser(_delegate);

}

/**
 * The not-predicate, a parser that succeeds whenever its delegate does not,
 * but consumes no input [Parr 1994, 1995].
 */
class _NotParser extends DelegateParser {

  final String _message;

  _NotParser(parser, this._message) : super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(null);
    } else {
      return context.failure(_message);
    }
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  ParserBuilder copy() => new _NotParser(_delegate, _message);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen) && _message == other._message;
  }

}

/**
 * A parser that optionally parsers its delegate, or answers nil.
 */
class _OptionalParser extends DelegateParser {

  final dynamic _otherwise;

  _OptionalParser(parser, this._otherwise) : super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      return result;
    } else {
      return context.success(_otherwise);
    }
  }

  @override
  ParserBuilder copy() => new _OptionalParser(_delegate, _otherwise);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen) && _otherwise == other._otherwise;
  }

}

/**
 * A parser that repeatedly parses a sequence of parsers.
 */
class _RepeatingParser extends DelegateParser {

  final int _min;
  final int _max;

  _RepeatingParser(parser, this._min, this._max) : super(parser);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    while (elements.length < _max) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return current.success(elements);
      }
      elements.add(result.value);
      current = result;
    }
    return current.success(elements);
  }

  @override
  String toString() => '${super.toString()}[$_min..$_max]';

  @override
  ParserBuilder copy() => new _RepeatingParser(_delegate, _min, _max);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen)
        && _min == other._min
        && _max == other._max;
  }

}

/**
 * Abstract parser that parses a list of things in some way.
 */
abstract class _ListParser extends ParserBase {

  final List<ParserBase> _parsers;

  _ListParser(this._parsers);

  @override
  List<ParserBuilder> get children => _parsers;

  @override
  void replace(ParserBuilder source, ParserBuilder target) {
    super.replace(source, target);
    for (var i = 0; i < _parsers.length; i++) {
      if (_parsers[i] == source) {
        _parsers[i] = target;
      }
    }
  }

}

/**
 * A parser that uses the first parser that succeeds.
 */
class _ChoiceParser extends _ListParser {

  _ChoiceParser(parsers) : super(parsers);

  @override
  Result parseOn(Context context) {
    var result;
    for (var parser in _parsers) {
      result = parser.parseOn(context);
      if (result.isSuccess) {
        return result;
      }
    }
    return result;
  }

  @override
  ParserBuilder or(ParserBuilder other) {
    var parsers = new List.from(_parsers);
    parsers.add(other);
    return new _ChoiceParser(parsers).copy();
  }

  @override
  ParserBuilder copy() => new _ChoiceParser(new List.from(_parsers, growable: false));

}

/**
 * A parser that parses a sequence of parsers.
 */
class _SequenceParser extends _ListParser {

  _SequenceParser(parsers) : super(parsers);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List(_parsers.length);
    for (var i = 0; i < _parsers.length; i++) {
      var result = _parsers[i].parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements[i] = result.value;
      current = result;
    }
    return current.success(elements);
  }

  @override
  ParserBuilder seq(ParserBuilder other) {
    var parsers = new List.from(_parsers);
    parsers.add(other);
    return new _SequenceParser(parsers).copy();
  }

  @override
  ParserBuilder copy() => new _SequenceParser(new List.from(_parsers, growable: false));

}
