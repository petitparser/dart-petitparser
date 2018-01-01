library petitparser.core.contexts.result;

import 'package:petitparser/src/core/contexts/context.dart';

/// An immutable parse result.
abstract class Result extends Context {
  const Result(buffer, position) : super(buffer, position);

  /// Returns `true` if this result indicates a parse success.
  bool get isSuccess => false;

  /// Returns `true` if this result indicates a parse failure.
  bool get isFailure => false;

  /// Returns the parse result of the current context.
  get value;

  /// Returns the parse message of the current context.
  String get message;
}
