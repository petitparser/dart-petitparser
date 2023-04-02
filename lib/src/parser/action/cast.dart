import 'package:meta/meta.dart';

import '../../context/context.dart';
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
  void parseOn(Context context) {
    delegate.parseOn(context);
    if (context.isSuccess && !context.isSkip) {
      context.value = context.value as R;
    }
  }

  @override
  CastParser<R, S> copy() => CastParser<R, S>(delegate);
}
