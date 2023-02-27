import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastListParserExtension<T> on Parser<T> {
  /// Returns a parser that casts itself to `Parser<List<R>>`. Assumes this
  /// parser to be of type `Parser<List>`.
  @useResult
  Parser<List<R>> castList<R>() => CastListParser<T, R>(this);
}

/// A parser that casts a `Result<List>` to a `Result<List<R>>`.
class CastListParser<T, R> extends DelegateParser<T, List<R>> {
  CastListParser(super.delegate);

  @override
  void parseOn(Context context) {
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.value = (context.value as List).cast<R>();
    }
  }

  @override
  void fastParseOn(Context context) => delegate.fastParseOn(context);

  @override
  CastListParser<T, R> copy() => CastListParser<T, R>(delegate);
}
