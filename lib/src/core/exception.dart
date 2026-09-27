import 'package:meta/meta.dart';

import 'result.dart';

/// An exception raised in case of a parse error.
@immutable
class ParserException implements FormatException {
  /// Creates a [ParserException] with the provided [failure].
  const new(this.failure);

  /// The underlying parse failure.
  final Failure failure;

  @override
  String get message => failure.message;

  @override
  int get offset => failure.position;

  @override
  String get source => failure.buffer;

  @override
  String toString() => '$runtimeType[${failure.toPositionString()}]: $message';
}
