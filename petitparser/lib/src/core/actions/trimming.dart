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

  TrimmingParser(Parser<T> delegate, this.left, this.right)
      : assert(left != null),
        assert(right != null),
        super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final before = trimmer_(left, context);
    final result = delegate.parseOn(before);
    if (result.isFailure) {
      return result;
    }
    final after = trimmer_(right, result);
    return after.success(result.value);
  }

  Result trimmer_(Parser parser, Context context) {
    var result = parser.parseOn(context);
    while (result.isSuccess) {
      result = parser.parseOn(result);
    }
    return result;
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
