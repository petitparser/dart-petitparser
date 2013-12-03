// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * An immutable parse context.
 */
class Context {

  final dynamic _buffer;
  final int _position;

  const Context(this._buffer, this._position);

  /**
   * The buffer we are working on.
   */
  dynamic get buffer => _buffer;

  /**
   * The current position in the buffer.
   */
  int get position => _position;

  /**
   * Returns [true] if this result indicates a parse success.
   */
  bool get isSuccess => false;

  /**
   * Returns [true] if this result indicates a parse failure.
   */
  bool get isFailure => false;

  /**
   * Returns a result indicating a parse success.
   */
  Result success(dynamic result, [int position]) {
    return new Success(_buffer, position == null ? _position : position, result);
  }

  /**
   * Returns a result indicating a parse failure.
   */
  Result failure(String message, [int position]) {
    return new Failure(_buffer, position == null ? _position : position, message);
  }

  /**
   * Returns a human readable string of the current context.
   */
  String toString() => 'Context[${toPositionString()}]';

  /**
   * Returns the line:column if the input is a string, otherwise the position.
   */
  String toPositionString() => Token.positionString(_buffer, _position);

}

/**
 * An immutable parse result.
 */
abstract class Result extends Context {

  const Result(buffer, position) : super(buffer, position);

  /**
   * Returns the parse result of the current context.
   */
  dynamic get value;

  /**
   * Returns the parse message of the current context.
   */
  String get message;

}

/**
 * An immutable parse result in case of a successful parse.
 */
class Success extends Result {

  final dynamic _value;

  const Success(buffer, position, this._value) : super(buffer, position);

  @override
  bool get isSuccess => true;

  @override
  dynamic get value => _value;

  @override
  String get message => null;

  @override
  String toString() => 'Success[${toPositionString()}]: $_value';

}

/**
 * An immutable parse result in case of a failed parse.
 */
class Failure extends Result {

  final String _message;

  const Failure(buffer, position, this._message) : super(buffer, position);

  @override
  bool get isFailure => true;

  @override
  dynamic get value => throw new ParserError(this);

  @override
  String get message => _message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $_message';

}

/**
 * An exception raised in case of a parse error.
 */
class ParserError extends Error {

  final Failure failure;

  ParserError(this.failure);

  @override
  String toString() => '${failure.message} at ${failure.toPositionString()}';

}