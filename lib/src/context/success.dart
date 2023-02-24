import 'context.dart';
import 'result.dart';

/// An immutable successful parse result.
class Success<T> extends Result<T> {
  const Success(super.buffer, super.position, this.value);

  @override
  bool get isSuccess => true;

  @override
  final T value;

  @override
  String get message =>
      throw UnsupportedError('Successful parse results do not have a message.');

  @override
  Context toContext() {
    final context = super.toContext();
    context.isSuccess = true;
    context.value = value;
    return context;
  }

  @override
  String toString() => 'Success[${toPositionString()}]: $value';
}
