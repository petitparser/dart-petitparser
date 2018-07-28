library petitparser.core.parsers.failure;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that consumes nothing and fails.
///
/// For example, `failure()` always fails, no matter what input it is given.
Parser failure([String message = 'unable to parse']) {
  return FailureParser(message);
}

/// A parser that consumes nothing and fails.
class FailureParser extends Parser {
  final String _message;

  FailureParser(this._message);

  @override
  Result parseOn(Context context) => context.failure(_message);

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => FailureParser(_message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is FailureParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
