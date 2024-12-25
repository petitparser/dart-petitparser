import '../shared/annotations.dart';
import 'context.dart';
import 'exception.dart';

/// An immutable parse result that is either a [Success] or a [Failure].
sealed class Result<R> extends Context {
  const Result(super.buffer, super.position);

  /// Returns the parsed value of this result, or throws a [ParserException]
  /// if this is a parse failure.
  @inlineVm
  R get value;

  /// Returns the error message of this result, or throws an [UnsupportedError]
  /// if this is a parse success.
  @inlineVm
  String get message;
}

/// An immutable successful parse result.
class Success<R> extends Result<R> {
  const Success(super.buffer, super.position, this.value);

  @override
  final R value;

  @override
  String get message =>
      throw UnsupportedError('Successful parse results do not have a message.');

  @override
  String toString() => 'Success[${toPositionString()}]: $value';
}

/// An immutable failed parse result.
class Failure extends Result<Never> {
  const Failure(super.buffer, super.position, this.message);

  @override
  Never get value => throw ParserException(this);

  @override
  final String message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';
}
