import 'package:meta/meta.dart';

import '../shared/pragma.dart';
import '../shared/to_string.dart';
import 'result.dart';
import 'token.dart';

/// An immutable parse context.
@immutable
class Context {
  @preferInline
  const Context(this.buffer, this.position);

  /// The buffer we are working on.
  final String buffer;

  /// The current position in the [buffer].
  final int position;

  /// Returns a result indicating a parse success.
  @useResult
  @preferInline
  Success<R> success<R>(R result, [int? position]) =>
      Success<R>(buffer, position ?? this.position, result);

  /// Returns a result indicating a parse failure.
  @useResult
  @preferInline
  Failure failure(String message, [int? position]) =>
      Failure(buffer, position ?? this.position, message);

  /// Returns the current line:column position in the [buffer].
  String toPositionString() => Token.positionString(buffer, position);

  @override
  String toString() => '${objectToString(this)}[${toPositionString()}]';
}
