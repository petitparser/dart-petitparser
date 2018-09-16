library petitparser.core.actions.trimming;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that silently consumes input of another parser around
/// its delegate.
class TrimmingParser<T> extends DelegateParser<T> {
  Parser left;
  Parser right;

  TrimmingParser(Parser<T> delegate, this.left, this.right) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    var current = context;
    do {
      current = left.parseOn(current);
    } while ((current as Result).isSuccess);
    final result = delegate.parseOn(current);
    if (result.isFailure) {
      return result;
    }
    current = result;
    do {
      current = right.parseOn(current);
    } while ((current as Result).isSuccess);
    return current.success(result.value);
  }

  @override
  TrimmingParser<T> copy() => TrimmingParser<T>(delegate, left, right);

  @override
  List<Parser> get children => [delegate, left, right];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (left == source) {
      left = target;
    }
    if (right == source) {
      right = target;
    }
  }
}
