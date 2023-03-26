import '../shared/annotations.dart';
import 'context.dart';
import 'failure.dart';
import 'result.dart';
import 'success.dart';

/// Extension methods to the [Context].
extension ContextExtensions on Context {
  /// Marks the context as a success.
  @inlineVm
  @inlineJs
  void success(dynamic value, {int? position}) {
    isSuccess = true;
    this.value = value;
    if (position != null) this.position = position;
  }

  /// Marks the context as a failure.
  @inlineVm
  @inlineJs
  void failure(String message, {int? position}) {
    isSuccess = false;
    this.message = message;
    if (position != null) this.position = position;
  }

  /// Converts the current state of the context to an immutable [Result].
  @inlineVm
  @inlineJs
  Result<R> toResult<R>() => isSuccess
      ? Success<R>(buffer, position, value as R)
      : Failure<R>(buffer, position, message);

  /// Creates a copy of the current context.
  @inlineVm
  @inlineJs
  Context copy() => Context(buffer,
      start: start,
      end: end,
      position: position,
      isSuccess: isSuccess,
      value: value,
      message: message,
      isSkip: isSkip,
      isCut: isCut);
}
