// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

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