import 'package:meta/meta.dart';

import '../core/exception.dart';
import 'result.dart';

/// An immutable failed parse result.
@immutable
class Failure<R> extends Result<R> {
  const Failure(super.buffer, super.position, this.message);

  @override
  bool get isFailure => true;

  @override
  R get value => throw ParserException(this);

  @override
  final String message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';
}
