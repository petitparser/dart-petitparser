// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a parser that consumes nothing and succeeds.
 *
 * For example, [:char('a').or(epsilon()):] is equivalent to
 * [:char('a').optional():].
 */
Parser epsilon([dynamic result]) => new _EpsilonParser(result);

class _EpsilonParser extends Parser {

  final dynamic _result;

  _EpsilonParser(this._result);

  Result _parse(Context context) => context.success(_result);

  Parser copy() => new _EpsilonParser(_result);

  bool match(dynamic other, [Set<Parser> seen]) {
    return super.match(other, seen) && _result == other._result;
  }

}

/**
 * Returns a parser that consumes nothing and fails.
 *
 * For example, [:failure():] always fails, no matter what input it is given.
 */
Parser failure([String message = 'unable to parse']) {
  return new _FailureParser(message);
}

class _FailureParser extends Parser {

  final String _message;

  _FailureParser(this._message);

  Result _parse(Context context) => context.failure(_message);

  String toString() => '${super.toString()}[$_message]';

  Parser copy() => new _FailureParser(_message);

  bool match(dynamic other, [Set<Parser> seen]) {
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
abstract class SetableParser implements Parser {

  /** Sets the receiver to delegate to [parser]. */
  void set(Parser parser);

}

class _SetableParser extends DelegateParser implements SetableParser {

  _SetableParser(parser) : super(parser);

  void set(Parser parser) => replace(children[0], parser);

  Parser copy() => new _SetableParser(_delegate);

}