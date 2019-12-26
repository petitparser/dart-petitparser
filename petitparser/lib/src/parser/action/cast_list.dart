library petitparser.parser.action.cast_list;

import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastListParserExtension<T> on Parser<T> {
  /// Returns a parser that casts itself to `Parser<List<R>>`. Assumes this
  /// parser to be of type `Parser<List>`.
  Parser<List<R>> castList<R>() => CastListParser<R>(this);
}

/// A parser that casts a `Result<List>` to a `Result<List<R>>`.
class CastListParser<R> extends DelegateParser<List<R>> {
  CastListParser(Parser delegate) : super(delegate);

  @override
  Result<List<R>> parseOn(Context context) {
    final Result<List> result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(result.value.cast<R>());
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  CastListParser<R> copy() => CastListParser<R>(delegate);
}
