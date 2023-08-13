import 'package:meta/meta.dart';

import 'result.dart';

/// An exception raised in case of a parse error.
@immutable
class ParserException implements FormatException {
  const ParserException(this.failure);

  final Failure failure;

  @override
  String get message => failure.message;

  @override
  int get offset => failure.position;

  @override
  String get source => failure.buffer;

  @override
  String toString() => '${super.toString()}: $message '
      '(at ${failure.toPositionString()})';
}
