import '../shared/annotations.dart';
import 'context.dart';

extension ContextExtensions on Context {
  /// Marks the context as a success.
  @inlineVm
  @inlineJs
  void success(dynamic value, {int? position, bool? isCut}) {
    isSuccess = true;
    this.value = value;
    if (position != null) this.position = position;
    if (isCut != null) this.isCut = isCut;
  }

  /// Marks the context as a failure.
  @inlineVm
  @inlineJs
  void failure(String message, {int? position, bool? isCut}) {
    isSuccess = false;
    this.message = message;
    if (position != null) this.position = position;
    if (isCut != null) this.isCut = isCut;
  }

  /// Creates a copy of the context.
  Context copy() => Context(buffer,
      position: position,
      isSuccess: isSuccess,
      value: value,
      message: message,
      isCut: isCut);
}
