library petitparser.core.contexts.context;

import 'package:petitparser/src/core/contexts/failure.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/contexts/success.dart';
import 'package:petitparser/src/core/token.dart';

/// An immutable parse context.
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
