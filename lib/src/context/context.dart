import '../shared/annotations.dart';
import 'failure.dart';
import 'result.dart';
import 'success.dart';

class Context {
  Context(this.buffer, {this.position = 0});

  /// The input the parser is being run on.
  final String buffer;

  /// The current position in the parser input.
  int position;

  /// Whether or not the parse is currently successful.
  bool isSuccess = true;

  /// The currently successful read value.
  dynamic value;

  /// The currently read error.
  String message = '';

  /// Whether or not the parse is prevented from backtracking.
  bool isCut = true;

  // Marks the context as a success.
  @inlineVm
  @inlineJs
  void success(dynamic value, {int? position}) {
    isSuccess = true;
    this.value = value;
    if (position != null) this.position = position;
  }

  // Marks the context as a failure.
  @inlineVm
  @inlineJs
  void failure(String message, {int? position}) {
    isSuccess = false;
    this.message = message;
    if (position != null) this.position = position;
  }

  // Converts the current state of the context to a [Result].
  @inlineVm
  @inlineJs
  Result<T> toResult<T>() => isSuccess
      ? Success<T>(buffer, position, value)
      : Failure<T>(buffer, position, message);

  @override
  String toString() => 'Context{position: $position, isSuccess: $isSuccess, '
      'value: $value, message: $message, isCut: $isCut}';
}
