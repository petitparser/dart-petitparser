part of petitparser;

/**
 * An immutable parse context.
 */
class Context {

  const Context(this.buffer, this.position);

  /**
   * The buffer we are working on.
   */
  final buffer;

  /**
   * The current position in the buffer.
   */
  final int position;

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
  Result success(result, [int position]) {
    return new Success(buffer, position == null ? this.position : position, result);
  }

  /**
   * Returns a result indicating a parse failure.
   */
  Result failure(String message, [int position]) {
    return new Failure(buffer, position == null ? this.position : position, message);
  }

  /**
   * Returns a human readable string of the current context.
   */
  String toString() => 'Context[${toPositionString()}]';

  /**
   * Returns the line:column if the input is a string, otherwise the position.
   */
  String toPositionString() => Token.positionString(buffer, position);

}

/**
 * An immutable parse result.
 */
abstract class Result extends Context {

  const Result(buffer, position): super(buffer, position);

  /**
   * Returns the parse result of the current context.
   */
  get value;

  /**
   * Returns the parse message of the current context.
   */
  String get message;

}

/**
 * An immutable parse result in case of a successful parse.
 */
class Success extends Result {

  const Success(buffer, position, this.value): super(buffer, position);

  @override
  bool get isSuccess => true;

  @override
  final value;

  @override
  String get message => null;

  @override
  String toString() => 'Success[${toPositionString()}]: $value';

}

/**
 * An immutable parse result in case of a failed parse.
 */
class Failure extends Result {

  const Failure(buffer, position, this.message): super(buffer, position);

  @override
  bool get isFailure => true;

  @override
  get value => throw new ParserError(this);

  @override
  final String message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';

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
