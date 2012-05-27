// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * An immutable parse context.
 */
class _Context implements Context {

  final Buffer _buffer;
  final int _position;

  _Context(this._buffer, this._position);

  Buffer getBuffer() => _buffer;
  int getPosition() => _position;
  bool isSuccess() => false;
  bool isFailure() => false;

  Success success(Dynamic result, [int position]) {
    return new _Success(_buffer, position == null ? _position : position, result);
  }

  Failure failure(String message, [int position]) {
    return new _Failure(_buffer, position == null ? _position : position, message);
  }

}

/**
 * An immutable parse success.
 */
class _Success extends _Context implements Success {

  final Dynamic _result;

  _Success(buffer, position, this._result)
    : super(buffer, position);

  bool isSuccess() => true;

  Dynamic get() {
    return _result;
  }

  String getMessage() {
    return null;
  }

}

/**
 * An immutable parse failure.
 */
class _Failure extends _Context implements Failure {

  final String _message;

  _Failure(buffer, position, this._message)
    : super(buffer, position);

  bool isFailure() => true;

  Dynamic get() {
    throw new UnsupportedOperationException("Parse failure: $_message");
  }

  String getMessage() {
    return _message;
  }

}