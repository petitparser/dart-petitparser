library petitparser.parsers.actions.cast;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';
import '../combinators/delegate.dart';

extension CastParserExtension<T> on Parser<T> {
  /// Returns a parser that casts itself to `Parser<R>`.
  Parser<R> cast<R>() => CastParser<R>(this);
}

/// A parser that casts a `Result` to a `Result<R>`.
class CastParser<R> extends DelegateParser<R> {
  CastParser(Parser delegate) : super(delegate);

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(result.value);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  CastParser<R> copy() => CastParser<R>(delegate);
}
