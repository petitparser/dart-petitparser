library petitparser.core.actions.cast;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that casts a `Result` to a `Result<R>`.
class CastParser<R> extends DelegateParser<R> {
  CastParser(Parser delegate) : super(delegate);

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(result.value as R);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  CastParser<R> copy() => CastParser<R>(delegate);
}

/// A parser that casts a `Result<List>` to a `Result<List<R>>`.
class CastListParser<R> extends DelegateParser<List<R>> {
  CastListParser(Parser delegate) : super(delegate);

  @override
  Result<List<R>> parseOn(Context context) {
    final result = delegate.parseOn(context) as Result<List>;
    if (result.isSuccess) {
      return result.success(result.value.cast<R>());
    } else {
      return result.failure(result.message);
    }
  }

  @override
  CastListParser<R> copy() => CastListParser<R>(delegate);
}
