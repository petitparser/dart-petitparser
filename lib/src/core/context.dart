// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * An immutable parse context.
 */
class Context {

  final Dynamic _buffer;
  final int _position;

  const Context(this._buffer, this._position);

  /** The buffer we are working on. */
  Dynamic get buffer => _buffer;

  /** The current position in the buffer. */
  int get position => _position;

  /** Returns [true] if this context indicates a parse success. */
  bool isSuccess() => false;

  /** Returns [true] if this context indicates a parse failure. */
  bool isFailure() => false;

  /** Copies the current context to indicate a parse success. */
  Success success(Dynamic result, [int position]) {
    return new Success(_buffer, position === null ? _position : position, result);
  }

  /** Copies the current context to indicate a parse failure. */
  Failure failure(String message, [int position]) {
    return new Failure(_buffer, position === null ? _position : position, message);
  }

  /** Returns a human readable string of the current context */
  String toString() => 'Context[$_position]';

}

/**
 * An immutable parse result.
 */
class Result extends Context {

  const Result(buffer, position) : super(buffer, position);

  /** Returns the parse result of the current context. */
  abstract Dynamic getResult();

  /** Returns the parse message of the current context. */
  abstract String getMessage();

}

/**
 * An immutable parse success.
 */
class Success extends Result {

  final Dynamic _result;

  const Success(buffer, position, this._result) : super(buffer, position);

  bool isSuccess() => true;

  Dynamic getResult() => _result;
  String getMessage() => null;

  String toString() => 'Success[$_position]: $_result';

}

/**
 * An immutable parse failure.
 */
class Failure extends Result {

  final String _message;

  const Failure(buffer, position, this._message) : super(buffer, position);

  bool isFailure() => true;

  Dynamic getResult() { throw new UnsupportedOperationException(_message); }
  String getMessage() => _message;

  String toString() => 'Failure[$_position]: $_message';

}