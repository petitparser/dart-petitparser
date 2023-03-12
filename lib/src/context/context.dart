import '../shared/annotations.dart';
import 'failure.dart';
import 'result.dart';
import 'success.dart';

class Context {
  Context(
    this.buffer, {
    this.start = 0,
    int? end,
    int? position,
    this.isSuccess = true,
    this.value,
    this.message = '',
    this.isSkip = false,
    this.isCut = false,
  })  : end = end ?? buffer.length,
        position = position ?? start;

  /// The input the parser is being run on.
  @inlineVm
  final String buffer;

  /// The start index in the input buffer.
  @inlineVm
  final int start;

  /// The end index in the input buffer.
  @inlineVm
  final int end;

  /// The current position in the parser input.
  @inlineVm
  int position;

  /// Whether or not the parse is currently successful.
  ///
  /// If `true`, the parser is currently in a valid state and unless [isSkip]
  /// is active [value] is expected to hold the currently resulting value.
  ///
  /// If `false`, the parser is currently in a error state and [message] is
  /// expected to hold an explanation.
  @inlineVm
  bool isSuccess;

  /// The currently successful read value.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `false`, or
  /// [isSkip] is `true`.
  @inlineVm
  dynamic value;

  /// The currently read error.
  ///
  /// The contents of this variable is undefined if [isSuccess] is `true`.
  @inlineVm
  String message;

  /// Disables the population of [value].
  ///
  /// If `true`, parsers can skip the creation of values in success cases.
  @inlineVm
  bool isSkip;

  /// Disables backtracking of errors.
  ///
  /// If `true`, parsers must refrain from backtracking and instead propagate
  /// possible new errors to the caller.
  @inlineVm
  bool isCut;

  /// Converts the current state of the context to a [Result].
  @inlineVm
  Result<R> toResult<R>() => isSuccess
      ? Success<R>(buffer, position, value)
      : Failure<R>(buffer, position, message);

  @override
  String toString() => 'Context{position: $position, isSuccess: $isSuccess, '
      'value: $value, message: $message, isCut: $isCut}';
}
