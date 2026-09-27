import '../shared/pragma.dart';
import 'context.dart';
import 'exception.dart';

/// An immutable parse result that is either a [Success] or a [Failure].
sealed class Result<R> extends Context {
  /// Creates a [Result] at [position] in the [buffer].
  @preferInline
  const new(super.buffer, super.position);

  /// The parsed value of this result.
  ///
  /// Throws a [ParserException] if this is a [Failure].
  R get value;

  /// The error message of this result.
  ///
  /// Throws an [UnsupportedError] if this is a [Success].
  String get message;
}

/// An immutable successful parse result.
class Success<R> extends Result<R> {
  /// Creates a [Success] parse result with [value] at [position] in the [buffer].
  @preferInline
  const new(super.buffer, super.position, this.value);

  @override
  final R value;

  @override
  String get message =>
      throw UnsupportedError('Successful parse results do not have a message.');

  @override
  String toString() => '${super.toString()}: $value';
}

/// An immutable failed parse result.
class Failure extends Result<Never> {
  /// Creates a [Failure] parse result with [message] at [position] in the [buffer].
  @preferInline
  const new(super.buffer, super.position, this.message);

  @override
  Never get value => throw ParserException(this);

  @override
  final String message;

  @override
  String toString() => '${super.toString()}: $message';
}
