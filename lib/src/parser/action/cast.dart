import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastParserExtension<T> on Parser<T> {
  /// Returns a parser that casts itself to `Parser<R>`.
  @useResult
  Parser<R> cast<R>() => CastParser<T, R>(this);
}

/// A parser that casts a `Result` to a `Result<R>`.
class CastParser<T, R> extends DelegateParser<T, R> {
  CastParser(super.delegate);

  @override
  void parseOn(Context context) {
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.value = context.value as R;
    }
  }

  @override
  void fastParseOn(Context context) => delegate.fastParseOn(context);

  @override
  CastParser<T, R> copy() => CastParser<T, R>(delegate);
}
