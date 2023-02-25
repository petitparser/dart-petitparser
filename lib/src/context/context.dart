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
  bool isSuccess;

  /// The currently successful read value.
  dynamic value;

  /// The currently read error.
  String message;

  /// If `true`, the calling parser is ignoring the returned [value] of called
  /// children. Children might decide to skip creating costly values.
  bool isSkip;

  /// If `true`, a called parser desired to abort backtracking at the next
  /// error.
  bool isCut;

  /// Converts the current state of the context to a [Result].
  Result<T> toResult<T>() => isSuccess
      ? Success<T>(buffer, position, value)
      : Failure<T>(buffer, position, message);

  @override
  String toString() => 'Context{position: $position, isSuccess: $isSuccess, '
      'value: $value, message: $message, isCut: $isCut}';
}
