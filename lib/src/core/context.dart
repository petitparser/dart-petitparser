import 'package:meta/meta.dart';

import '../shared/pragma.dart';
import 'result.dart';
import 'token.dart';

/// An immutable parse context.
@immutable
class Context {
  /// Creates a [Context] at [position] in the [buffer].
  @preferInline
  const new(this.buffer, this.position);

  /// The input buffer being parsed.
  final String buffer;

  /// The current position in the [buffer].
  final int position;

  /// Creates a [Success] parse result with [result] at [position].
  ///
  /// If [position] is omitted, defaults to the current [position].
  @useResult
  @preferInline
  Success<R> success<R>(R result, [int? position]) =>
      Success<R>(buffer, position ?? this.position, result);

  /// Creates a [Failure] parse result with [message] at [position].
  ///
  /// If [position] is omitted, defaults to the current [position].
  @useResult
  @preferInline
  Failure failure(String message, [int? position]) =>
      Failure(buffer, position ?? this.position, message);

  /// Returns the current line:column position in the [buffer].
  String toPositionString() => Token.positionString(buffer, position);

  @override
  String toString() => '$runtimeType[${toPositionString()}]';
}
