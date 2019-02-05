library petitparser.core.combinators.optional;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that optionally parsers its delegate, or answers nil.
class OptionalParser<T> extends DelegateParser<T> {
  final T otherwise;

  OptionalParser(Parser<T> delegate, this.otherwise) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result;
    } else {
      return context.success(otherwise);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? position : result;
  }

  @override
  OptionalParser<T> copy() => OptionalParser<T>(delegate, otherwise);

  @override
  bool hasEqualProperties(OptionalParser<T> other) =>
      super.hasEqualProperties(other) && otherwise == other.otherwise;
}
