import 'failure.dart';
import 'result.dart';
import 'success.dart';

class Context {
  Context(
    this.buffer, {
    this.position = 0,
    this.isSuccess = true,
    this.value,
    this.message = '',
    this.isSkip = false,
    this.isCut = true,
  });

  /// The input the parser is being run on.
  final String buffer;

  /// The current position in the parser input.
  int position;

  /// Whether or not the parse is currently successful.
  ///
  /// If `true`, the parser is currently in a valid state and unless [isSkip]
  /// is active [value] is expected to hold the currently resulting value.
  ///
  /// If `false`, the parser is currently in a error state and [message] is
  /// expected to hold an explanation.
  bool isSuccess;

  /// The currently successful read value.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `false`, or
  /// [isSkip] is `true`.
  dynamic value;

  /// The currently read error.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `true`.
  String message;

  /// Skips the creation of read values.
  ///
  /// If `true`, parsers must not read [value] and might decide to skip the
  /// creation of expensive return values.
  bool isSkip;

  /// Disables backtracking of errors.
  ///
  /// If `true`, parsers must refrain from backtracking and instead propagate
  /// possible new errors to the caller.
  bool isCut;

  /// Converts the current state of the context to a [Result].
  Result<T> toResult<T>() => isSuccess
      ? Success<T>(buffer, position, value)
      : Failure<T>(buffer, position, message);

  @override
  String toString() => 'Context{position: $position, isSuccess: $isSuccess, '
      'value: $value, message: $message, isCut: $isCut}';
}
