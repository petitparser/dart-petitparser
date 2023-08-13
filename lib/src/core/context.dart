import 'package:meta/meta.dart';

import '../shared/annotations.dart';
import 'result.dart';
import 'token.dart';

/// An immutable parse context.
@immutable
class Context {
  const Context(this.buffer, this.position);

  /// The buffer we are working on.
  @inlineVm
  final String buffer;

  /// The current position in the [buffer].
  @inlineVm
  final int position;

  /// Returns a result indicating a parse success.
  @inlineVm
  @inlineJs
  @useResult
  Success<R> success<R>(R result, [int? position]) =>
      Success<R>(buffer, position ?? this.position, result);

  /// Returns a result indicating a parse failure.
  @inlineVm
  @inlineJs
  @useResult
  Failure failure(String message, [int? position]) =>
      Failure(buffer, position ?? this.position, message);

  /// Returns the current line:column position in the [buffer].
  String toPositionString() => Token.positionString(buffer, position);

  @override
  String toString() => 'Context[${toPositionString()}]';
}
