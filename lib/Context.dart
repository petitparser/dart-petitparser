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

  bool isSuccess() => false;
  bool isFailure() => false;

  Success success(Dynamic result, [int position]) {
    return new Success(_buffer, position == null ? _position : position, result);
  }

  Failure failure(String message, [int position]) {
    return new Failure(_buffer, position == null ? _position : position, message);
  }

  String toString() {
    return 'Context[$_position]';
  }

}

/**
 * An immutable parse result.
 */
class Result extends Context {

  Result(buffer, position)
    : super(buffer, position);

  abstract Dynamic getResult();
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

  Dynamic getResult() {
    return _result;
  }

  String getMessage() {
    return null;
  }

  String toString() {
    return 'Success[$_position]: $_result';
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

  Dynamic getResult() {
    throw new UnsupportedOperationException(_message);
  }

  String getMessage() {
    return _message;
  }

  String toString() {
    return 'Success[$_position]: $_message';
  }

}