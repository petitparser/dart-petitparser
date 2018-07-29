library petitparser.core.combinators.optional;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that optionally parsers its delegate, or answers nil.
class OptionalParser<T> extends DelegateParser<T> {
  final _otherwise;

  OptionalParser(Parser<T> delegate, this._otherwise) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result;
    } else {
      return context.success(_otherwise);
    }
  }

  @override
  Parser<T> copy() => OptionalParser(delegate, _otherwise);

  @override
  bool hasEqualProperties(Parser other) {
    return other is OptionalParser &&
        super.hasEqualProperties(other) &&
        _otherwise == other._otherwise;
  }
}
