library petitparser.core.contexts.failure;

import 'package:petitparser/src/core/contexts/exception.dart';
import 'package:petitparser/src/core/contexts/result.dart';

/// An immutable parse result in case of a failed parse.
class Failure<R> extends Result<R> {
  const Failure(String buffer, int position, this.message)
      : super(buffer, position);

  @override
  bool get isFailure => true;

  @override
  R get value => throw ParserError(this);

  @override
  final String message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';
}
