library petitparser.core.predicates.any;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that accepts any input element.
///
/// For example, `any()` succeeds and consumes any given letter. It only
/// fails for an empty input.
Parser<String> any([String message = 'input expected']) {
  return AnyParser(message);
}

/// A parser that accepts any input element.
class AnyParser extends Parser<String> {
  final String message;

  AnyParser(this.message) : assert(message != null, 'message must not be null');

  @override
  Result<String> parseOn(Context context) {
    final position = context.position;
    final buffer = context.buffer;
    return position < buffer.length
        ? context.success(buffer[position], position + 1)
        : context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length ? position + 1 : -1;

  @override
  AnyParser copy() => AnyParser(message);

  @override
  bool hasEqualProperties(AnyParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
