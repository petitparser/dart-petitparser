import 'context.dart';

/// An immutable parse result.
abstract class Result<R> extends Context {
  const Result(String buffer, int position) : super(buffer, position);

  /// Returns `true` if this result indicates a parse success.
  bool get isSuccess => false;

  /// Returns `true` if this result indicates a parse failure.
  bool get isFailure => false;

  /// Returns the parse result of the current context.
  R get value;

  /// Returns the parse message of the current context.
  String get message;

  /// Transform the result with a [callback].
  Result<T> map<T>(T Function(R element) callback);
}
