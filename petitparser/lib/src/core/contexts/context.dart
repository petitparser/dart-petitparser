library petitparser.core.contexts.context;

import 'package:meta/meta.dart';

import '../token.dart';
import 'failure.dart';
import 'result.dart';
import 'success.dart';

/// An immutable parse context.
@immutable
class Context {
  const Context(this.buffer, this.position);

  /// The buffer we are working on.
  final String buffer;

  /// The current position in the buffer.
  final int position;

  /// Returns a result indicating a parse success.
  Result<R> success<R>(R result, [int position]) =>
      Success<R>(buffer, position ?? this.position, result);

  /// Returns a result indicating a parse failure.
  Result<R> failure<R>(String message, [int position]) =>
      Failure<R>(buffer, position ?? this.position, message);

  /// Returns a human readable string of the current context.
  @override
  String toString() => 'Context[${toPositionString()}]';

  /// Returns the line:column if the input is a string, otherwise the position.
  String toPositionString() => Token.positionString(buffer, position);
}
