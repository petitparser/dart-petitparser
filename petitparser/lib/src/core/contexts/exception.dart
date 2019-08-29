library petitparser.core.contexts.exception;

import 'package:petitparser/src/core/contexts/failure.dart';

/// An exception raised in case of a parse error.
class ParserException implements FormatException {
  final Failure failure;

  ParserException(this.failure);

  @override
  String get message => failure.message;

  @override
  int get offset => failure.position;

  @override
  String get source => failure.buffer;

  @override
  String toString() => '${failure.message} at ${failure.toPositionString()}';
}
