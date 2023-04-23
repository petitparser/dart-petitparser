import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastListParserExtension<R> on Parser<R> {
  /// Returns a parser that casts itself to `Parser<List<R>>`. Assumes this
  /// parser to be of type `Parser<List>`.
  @useResult
  Parser<List<S>> castList<S>() => CastListParser<R, S>(this);
}

/// A parser that casts a `Result<List>` to a `Result<List<S>>`.
class CastListParser<R, S> extends DelegateParser<R, List<S>> {
  CastListParser(super.delegate);

  @override
  Result<List<S>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(List.castFrom(result.value as List));
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  CastListParser<R, S> copy() => CastListParser<R, S>(delegate);
}
