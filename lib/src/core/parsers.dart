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
}

/**
 * Returns a parser that is not defined yet, but that can be set later on. A
 *
 * For example, the following code sets up a parser that refers to itself:
 *
 *     var p = undefined();
 *     p.set(char('a').seq(p).or(char('b')));
 *
 * The parser above accepts a sequence of a's followed by b.
 */
SetableParser undefined([String message = 'undefined parser']) {
  return failure(message).setable();
}

/**
 * Interface of a parser that can be redefined using [SetableParser#set()].
 */
abstract class SetableParser implements Parser {

  /**
   * Tells this parser to become [parser].
   */
  void set(Parser parser);

}

class _SetableParser extends _DelegateParser implements SetableParser {
  _SetableParser(parser) : super(parser);
  void set(Parser parser) => replace(children[0], parser);
}
