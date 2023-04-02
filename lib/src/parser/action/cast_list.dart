import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension CastListParserExtension<R> on Parser<R> {
  /// Returns a parser that casts itself to `Parser<List<S>>`. Assumes this
  /// parser to be of type `Parser<List>`.
  @useResult
  Parser<List<S>> castList<S>() => CastListParser<R, S>(this);
}

/// A parser that casts a `Result<List>` to a `Result<List<S>>`.
class CastListParser<R, S> extends DelegateParser<R, List<S>> {
  CastListParser(super.delegate);

  @override
  void parseOn(Context context) {
    delegate.parseOn(context);
    if (context.isSuccess && !context.isSkip) {
      context.value = (context.value as List).cast<S>();
    }
  }

  @override
  CastListParser<R, S> copy() => CastListParser<R, S>(delegate);
}
