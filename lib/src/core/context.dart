// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * An immutable parse context.
 */
class Context {

  const Context(this.buffer, this.position);

  /** The buffer we are working on. */
  final dynamic buffer;

  /** The current position in the buffer. */
  final int position;

  /** Returns [true] if this context indicates a parse success. */
  bool get isSuccess => false;

  /** Returns [true] if this context indicates a parse failure. */
  bool get isFailure => false;

  /** Copies the current context to indicate a parse success. */
  Success success(dynamic result, [int pos]) {
    return new Success(buffer, pos == null ? position : pos, result);
  }

  /** Copies the current context to indicate a parse failure. */
  Failure failure(String message, [int pos]) {
    return new Failure(buffer, pos == null ? position : pos, message);
  }

  /** Returns a human readable string of the current context */
  String toString() => 'Context[$position]';

}

/**
 * An immutable parse result.
 */
abstract class Result extends Context {

  const Result(buffer, position) : super(buffer, position);

  /** Returns the parse result of the current context. */
  dynamic get result;

  /** Returns the parse message of the current context. */
  String get message;

}

/**
 * An immutable parse result in case of a successful parse.
 */
class Success extends Result {

  const Success(buffer, position, this.result) : super(buffer, position);

  bool get isSuccess => true;

  final dynamic result;

  String get message => null;

  String toString() => 'Success[$position]: $result';

}

/**
 * An immutable parse result in case of a failed parse.
 */
class Failure extends Result {

  const Failure(buffer, position, this.message) : super(buffer, position);

  bool get isFailure => true;

  dynamic get result { throw new ParserError(this); }

  final String message;

  String toString() => 'Failure[$position]: $message';

}

/**
 * An exception raised in case of a parse error.
 */
class ParserError implements Error {

  ParserError(this.failure);

  final Failure failure;

  String toString() => '${failure.message} at ${failure.position}';
}
