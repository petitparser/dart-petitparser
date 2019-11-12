library petitparser.core.combinators.delegate;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';

/// A parser that delegates to another one. Normally users do not need to
/// directly use a delegate parser.
class DelegateParser<R> extends Parser<R> {
  Parser delegate;

  DelegateParser(this.delegate)
      : assert(delegate != null, 'delegate must not be null');

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
  DelegateParser<R> copy() => DelegateParser<R>(delegate);
}
