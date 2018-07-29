library petitparser.core.actions.cast;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that casts the result of a [T] parsers to the result of an [R]
/// parser. What a waste of object creation.
class CastParser<T, R> extends DelegateParser<R> {
  CastParser(Parser<T> delegate) : super(delegate);

  @override
  Result<R> parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(result.value as R);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  Parser<R> copy() => CastParser<T, R>(delegate);
}
