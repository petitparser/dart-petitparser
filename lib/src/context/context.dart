import '../shared/annotations.dart';
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
    this.isCut = true,
  });

  /// The input the parser is being run on.
  @inlineVm
  @inlineJs
  final String buffer;

  /// The current position in the parser input.
  @inlineVm
  @inlineJs
  int position;

  /// Whether or not the parse is currently successful.
  ///
  /// If `true`, the parser is currently in a valid state and unless [isSkip]
  /// is active [value] is expected to hold the currently resulting value.
  ///
  /// If `false`, the parser is currently in a error state and [message] is
  /// expected to hold an explanation.
  @inlineVm
  @inlineJs
  bool isSuccess;

  /// The currently successful read value.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `false`, or
  /// [isSkip] is `true`.
  @inlineVm
  @inlineJs
  dynamic value;

  /// The currently read error.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `true`.
  @inlineVm
  @inlineJs
  String message;

  /// Disables backtracking of errors.
  ///
  /// If `true`, parsers must refrain from backtracking and instead propagate
  /// possible new errors to the caller.
  @inlineVm
  @inlineJs
  bool isCut;

  /// Converts the current state of the context to a [Result].
  @inlineVm
  @inlineJs
  Result<T> toResult<T>() => isSuccess
      ? Success<T>(buffer, position, value)
      : Failure<T>(buffer, position, message);

  @override
  String toString() => 'Context{position: $position, isSuccess: $isSuccess, '
      'value: $value, message: $message, isCut: $isCut}';
}
