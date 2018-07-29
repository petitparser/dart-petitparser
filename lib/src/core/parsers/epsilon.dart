library petitparser.core.parsers.epsilon;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that consumes nothing and succeeds.
///
/// For example, `char('a').or(epsilon())` is equivalent to
/// `char('a').optional()`.
Parser epsilon([result]) => EpsilonParser(result);

/// A parser that consumes nothing and succeeds.
class EpsilonParser<T> extends Parser<T> {
  final T _result;

  EpsilonParser(this._result);

  @override
  Result<T> parseOn(Context context) => context.success(_result);

  @override
  Parser<T> copy() => EpsilonParser(_result);

  @override
  bool hasEqualProperties(Parser other) {
    return other is EpsilonParser &&
        super.hasEqualProperties(other) &&
        _result == other._result;
  }
}
