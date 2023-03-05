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
  String toString() => 'Success[${toPositionString()}]: $value';
}
