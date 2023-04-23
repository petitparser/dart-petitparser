import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastParserExtension<R> on Parser<R> {
  /// Returns a parser that casts itself to `Parser<R>`.
  @useResult
  Parser<S> cast<S>() => CastParser<R, S>(this);
}

/// A parser that casts a `Result` to a `Result<R>`.
class CastParser<R, S> extends DelegateParser<R, S> {
  CastParser(super.delegate);

  @override
  Result<S> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(result.value as S);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  CastParser<R, S> copy() => CastParser<R, S>(delegate);
}
