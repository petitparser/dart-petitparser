library petitparser.core.contexts.exception;

import 'package:petitparser/src/core/contexts/failure.dart';

/// An exception raised in case of a parse error.
class ParserError extends Error {
  final Failure failure;

  ParserError(this.failure);

  @override
  String toString() => '${failure.message} at ${failure.toPositionString()}';
}
