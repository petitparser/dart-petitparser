library petitparser.core.combinators.delegate;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that delegates to another one. Normally users do not need to
/// directly use a delegate parser.
class DelegateParser<R> extends Parser<R> {
  Parser delegate;

  DelegateParser(this.delegate);

  @override
  Result<R> parseOn(Context context) => delegate.parseOn(context);

  @override
  List<Parser> get children => [delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (delegate == source) {
      delegate = target;
    }
  }

  @override
  Parser<R> copy() => DelegateParser<R>(delegate);
}
