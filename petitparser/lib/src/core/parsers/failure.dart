library petitparser.core.parsers.failure;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that consumes nothing and fails.
///
/// For example, `failure()` always fails, no matter what input it is given.
Parser<T> failure<T>([String message = 'unable to parse']) {
  return FailureParser(message);
}

/// A parser that consumes nothing and fails.
class FailureParser<T> extends Parser<T> {
  final String message;

  FailureParser(this.message) : assert(message != null);

  @override
  Result<T> parseOn(Context context) => context.failure(message);

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  FailureParser<T> copy() => FailureParser<T>(message);

  @override
  bool hasEqualProperties(FailureParser<T> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
