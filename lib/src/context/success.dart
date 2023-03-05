import 'context.dart';
import 'result.dart';

/// An immutable successful parse result.
class Success<R> extends Result<R> {
  const Success(super.buffer, super.position, this.value);

  @override
  bool get isSuccess => true;

  @override
  final R value;

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
