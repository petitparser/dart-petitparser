library petitparser.core.combinators.and;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'delegate.dart';

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
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? -1 : position;
  }

  @override
  AndParser<T> copy() => AndParser<T>(delegate);
}
