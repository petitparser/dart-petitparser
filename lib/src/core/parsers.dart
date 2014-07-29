part of petitparser;

/**
 * Returns a parser that consumes nothing and succeeds.
 *
 * For example, `char('a').or(epsilon())` is equivalent to
 * `char('a').optional()`.
 */
Parser epsilon([result]) => new EpsilonParser(result);

class EpsilonParser extends Parser {

  final _result;

  EpsilonParser(this._result);

  @override
  Result parseOn(Context context) => context.success(_result);

  @override
  Parser copy() => new EpsilonParser(_result);

  @override
  bool equalProperties(EpsilonParser other) {
    return super.equalProperties(other) && _result == other._result;
  }

}

/**
 * Returns a parser that consumes nothing and fails.
 *
 * For example, `failure()` always fails, no matter what input it is given.
 */
Parser failure([String message = 'unable to parse']) {
  return new FailureParser(message);
}

class FailureParser extends Parser {

  final String _message;

  FailureParser(this._message);

  @override
  Result parseOn(Context context) => context.failure(_message);

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => new FailureParser(_message);

  @override
  bool equalProperties(FailureParser other) {
    return super.equalProperties(other) && _message == other._message;
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

class SetableParser extends DelegateParser {

  SetableParser(parser): super(parser);

  /**
   * Sets the receiver to delegate to [parser].
   */
  void set(Parser parser) => replace(children[0], parser);

  @override
  Parser copy() => new SetableParser(_delegate);

}
