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
  final String _message;

  AnyParser(this._message);

  @override
  Result<String> parseOn(Context context) {
    var position = context.position;
    var buffer = context.buffer;
    return position < buffer.length
        ? context.success(buffer[position], position + 1)
        : context.failure(_message);
  }

  @override
  Parser<String> copy() => AnyParser(_message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is AnyParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
