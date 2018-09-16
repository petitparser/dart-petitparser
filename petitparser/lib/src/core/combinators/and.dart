library petitparser.core.combinators.and;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// The and-predicate, a parser that succeeds whenever its delegate does, but
/// does not consume the input stream [Parr 1994, 1995].
class AndParser<T> extends DelegateParser<T> {
  AndParser(Parser delegate) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return context.success(result.value);
    } else {
      return result;
    }
  }

  @override
  AndParser<T> copy() => AndParser<T>(delegate);
}
