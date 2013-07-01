// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a parser that consumes nothing and succeeds.
 *
 * For example, [:char('a').or(epsilon()):] is equivalent to
 * [:char('a').optional():].
 */
ParserBuilder epsilon([dynamic result]) => new _EpsilonParser(result);

class _EpsilonParser extends ParserBase {

  final dynamic _result;

  _EpsilonParser(this._result);

  @override
  Result parseOn(Context context) => context.success(_result);

  @override
  ParserBuilder copy() => new _EpsilonParser(_result);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen) && _result == other._result;
  }

}

/**
 * Returns a parser that consumes nothing and fails.
 *
 * For example, [:failure():] always fails, no matter what input it is given.
 */
ParserBuilder failure([String message = 'unable to parse']) {
  return new _FailureParser(message);
}

class _FailureParser extends ParserBase {

  final String _message;

  _FailureParser(this._message);

  @override
  Result parseOn(Context context) => context.failure(_message);

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  ParserBuilder copy() => new _FailureParser(_message);

  @override
  bool match(dynamic other, [Set<ParserBuilder> seen]) {
    return super.match(other, seen) && _message == other._message;
  }

}

/**
 * Returns a parser that is not defined, but that can be set at a later
 * point in time.
 *
 * For example, the following code sets up a parser that points to itself
 * and that accepts a sequence of a's ended with the letter b.
 *
 *     var p = undefined();
 *     p.set(char('a').seq(p).or(char('b')));
 */
SetableParser undefined([String message = 'undefined parser']) {
  return failure(message).setable();
}

/**
 * Interface of a parser that can be redefined using [SetableParser.set].
 */
class SetableParser extends DelegateParser {

  SetableParser(parser) : super(parser);

  /** Sets the receiver to delegate to [parser]. */
  void set(ParserBuilder parser) => replace(children[0], parser);

  @override
  ParserBuilder copy() => new SetableParser(_delegate);

}