library petitparser.core.contexts.success;

import 'package:petitparser/src/core/contexts/result.dart';

/// An immutable parse result in case of a successful parse.
class Success extends Result {
  const Success(String buffer, int position, this.value)
      : super(buffer, position);

  @override
  bool get isSuccess => true;

  @override
  final value;

  @override
  String get message => null;

  @override
  String toString() => 'Success[${toPositionString()}]: $value';
}
