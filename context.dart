// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * An immutable parse context.
 */
class Context {

  final Dynamic _buffer;
  final int _position;

  Context(this._buffer, [this._position = 0]);

  Dynamic get buffer() => _buffer;
  int get position() => _position;

  Success success(Dynamic result, [int position]) {
    return new Success(_buffer, position == null ? _position : position, result);
  }

  Failure failure(String message, [int position]) {
    return new Failure(_buffer, position == null ? _position : position, message);
  }

}

/**
 * An immutable parse result.
 */
class Result extends Context {

  Result(buffer, position)
    : super(buffer, position);

  bool isSuccess() => false;
  bool isFailure() => false;

  abstract Dynamic getValue();
  abstract String getMessage();

}

/**
 * An immutable parse success.
 */
class Success extends Result {

  final Dynamic _result;

  Success(buffer, position, this._result)
    : super(buffer, position);

  bool isSuccess() => true;

  Dynamic getValue() {
    return _result;
  }

  String getMessage() {
    return null;
  }

}

/**
 * An immutable parse failure.
 */
class Failure extends Result {

  final String _message;

  Failure(buffer, position, this._message)
    : super(buffer, position);

  bool isFailure() => true;

  Dynamic getValue() {
    throw new UnsupportedOperationException("Parse failure: $_message");
  }

  String getMessage() {
    return _message;
  }

}