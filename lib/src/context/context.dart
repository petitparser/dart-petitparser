import 'package:meta/meta.dart';

import '../core/token.dart';
import '../shared/annotations.dart';
import 'failure.dart';
import 'success.dart';

/// An immutable parse context.
@immutable
class Context {
  const Context(this.buffer, this.position, [this.start = 0]);

  /// The buffer we are working on.
  final String buffer;

  /// The start position of the [buffer].
  final int start;

  /// The current position in the [buffer].
  final int position;

  /// Returns a result indicating a parse success.
  @inlineVm
  @inlineJs
  Success<R> success<R>(R result, [int? position, int? start]) =>
      Success<R>(buffer, position ?? this.position, result, start ?? this.start);

  /// Returns a result indicating a parse failure.
  @inlineVm
  @inlineJs
  Failure<R> failure<R>(String message, [int? position, int? start]) =>
      Failure<R>(buffer, position ?? this.position, message, start ?? this.start);

  /// Returns the current line:column position in the [buffer].
  String toPositionString() => Token.positionString(buffer, position);

  @override
  String toString() => 'Context[${toPositionString()}]';
}
