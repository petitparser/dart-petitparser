library petitparser.core.contexts.failure;

import 'package:petitparser/src/core/contexts/exception.dart';
import 'package:petitparser/src/core/contexts/result.dart';

/// An immutable parse result in case of a failed parse.
class Failure extends Result {
  const Failure(String buffer, int position, this.message) : super(buffer, position);

  @override
  bool get isFailure => true;

  @override
  get value => throw new ParserError(this);

  @override
  final String message;

  @override
  String toString() => 'Failure[${toPositionString()}]: $message';
}
