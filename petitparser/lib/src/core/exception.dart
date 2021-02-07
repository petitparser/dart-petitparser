import '../../buffer.dart';
import '../context/failure.dart';

/// An exception raised in case of a parse error.
class ParserException implements FormatException {
  final Failure failure;

  ParserException(this.failure);

  @override
  String get message => failure.message;

  @override
  int get offset => failure.position;

  @override
  Buffer get source => failure.buffer;

  @override
  String toString() => '${failure.message} at ${failure.toPositionString()}';
}
