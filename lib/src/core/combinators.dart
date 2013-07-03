// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * A parser that delegates to another one. Normally users do not need to
 * directly use a delegate parser.
 */
class DelegateParser extends Parser {

  Parser _delegate;

  DelegateParser(this._delegate);

  @override
  Result parseOn(Context context) {
    return _delegate.parseOn(context);
  }

  @override
  List<Parser> get children => [_delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_delegate == source) {
      _delegate = target;
    }
  }

  @override
  Parser copy() => new DelegateParser(_delegate);

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
  Parser copy() => new _EndOfInputParser(_delegate, _message);

  @override
  bool match(dynamic other, [Set<Parser> seen]) {
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
  Parser copy() => new _AndParser(_delegate);

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
  Parser copy() => new _NotParser(_delegate, _message);

  @override
  bool match(dynamic other, [Set<Parser> seen]) {
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
  Parser copy() => new _OptionalParser(_delegate, _otherwise);

  @override
  bool match(dynamic other, [Set<Parser> seen]) {
    return super.match(other, seen) && _otherwise == other._otherwise;
  }

}

/**
 * Abstract parser that parses a list of things in some way.
 */
abstract class ListParser extends Parser {

  final List<Parser> _parsers;

  ListParser(this._parsers);

  @override
  List<Parser> get children => _parsers;

  @override
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
 * A parser that uses the first parser that succeeds.
 */
class _ChoiceParser extends ListParser {

  factory _ChoiceParser(Iterable<Parser> parsers) {
    return new _ChoiceParser._(new List.from(parsers, growable: false));
  }

  _ChoiceParser._(parsers) : super(parsers);

  @override
  Result parseOn(Context context) {
    var result;
    for (var i = 0; i < _parsers.length; i++) {
      result = _parsers[i].parseOn(context);
      if (result.isSuccess) {
        return result;
      }
    }
    return result;
  }

  @override
  Parser or(Parser other) {
    return new _ChoiceParser(new List()..addAll(_parsers)..add(other));
  }

  @override
  Parser copy() => new _ChoiceParser(_parsers);

}

/**
 * A parser that parses a sequence of parsers.
 */
class _SequenceParser extends ListParser {

  factory _SequenceParser(Iterable<Parser> parsers) {
    return new _SequenceParser._(new List.from(parsers, growable: false));
  }

  _SequenceParser._(parsers) : super(parsers);

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
  Parser seq(Parser other) {
    return new _SequenceParser(new List()..addAll(_parsers)..add(other));
  }

  @override
  Parser copy() => new _SequenceParser(_parsers);

}
