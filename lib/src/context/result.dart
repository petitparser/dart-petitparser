import 'package:meta/meta.dart';

import '../core/exception.dart';
import '../core/token.dart';
import 'context.dart';
import 'failure.dart';
import 'success.dart';

/// An immutable parse result that is either a [Success] or a [Failure].
@immutable
abstract class Result<T> {
  const Result(this.buffer, this.position);

  /// The input buffer of this result.
  final String buffer;

  /// The position in the parser input.
  final int position;

  /// Returns `true` if this result indicates a parse success.
  bool get isSuccess => false;

  /// Returns `true` if this result indicates a parse failure.
  bool get isFailure => false;

  /// Returns the parsed value of this result, or throws a [ParserException]
  /// if this is a parse failure.
  T get value;

  /// Returns the error message of this result, or throws an [UnsupportedError]
  /// if this is a [Success].
  String get message;

  /// Converts a result back into a [Context].
  Context toContext() => Context(buffer, position: position);

  /// Returns the current line:column position in the [buffer].
  String toPositionString() => Token.positionString(buffer, position);
}
