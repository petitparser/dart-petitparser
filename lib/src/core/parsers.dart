// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a parser that consumes nothing and succeeds.
 *
 * For example, [:char('a').or(epsilon()):] is equivalent to
 * [:char('a').optional():].
 */
Parser epsilon() => new _EpsilonParser();

class _EpsilonParser extends Parser {

  Result _parse(Context context) => context.success(null);

}

/**
 * Returns a parser that consumes nothing and fails.
 *
 * For example, [:failure('Unable to parse input'):] always fails no
 * matter what input it is given.
 */
Parser failure(String message) => new _FailureParser(message);

class _FailureParser extends Parser {

  final String _message;

  _FailureParser(this._message);

  Result _parse(Context context) => context.failure(_message);

}

/**
 * Returns a parser that is not defined yet, but that can be set later on.
 *
 * For example, the following code sets up a parser that refers to itself:
 *
 *     var p = undefined();
 *     p.set(char('a').or(char('b').seq(p)));
 */
_WrapperParser undefined() => failure('Undefined parser').wrapper();

class _WrapperParser extends _DelegateParser {

  _WrapperParser(parser) : super(parser);

  void set(Parser parser) => _delegate = parser;

}
