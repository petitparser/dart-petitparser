import 'package:meta/meta.dart';

import '../core/exception.dart';
import 'context.dart';
import 'result.dart';

/// An immutable failed parse result.
@immutable
class Failure<T> extends Result<T> {
  const Failure(super.buffer, super.position, this.message);

  @override
  bool get isFailure => true;

  @override
  T get value => throw ParserException(this);

  @override
  final String message;

  @override
  Context toContext() {
    final context = super.toContext();
    context.isSuccess = false;
    context.message = message;
    return context;
  }

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';
}
