library petitparser.core.actions.trimming;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that silently consumes input of another parser around
/// its delegate.
class TrimmingParser<T> extends DelegateParser<T> {
  Parser _left;
  Parser _right;

  TrimmingParser(Parser<T> delegate, this._left, this._right) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    var current = context;
    do {
      current = _left.parseOn(current);
    } while ((current as Result).isSuccess);
    var result = delegate.parseOn(current);
    if (result.isFailure) {
      return result;
    }
    current = result;
    do {
      current = _right.parseOn(current);
    } while ((current as Result).isSuccess);
    return current.success(result.value);
  }

  @override
  Parser<T> copy() => TrimmingParser(delegate, _left, _right);

  @override
  List<Parser> get children => [delegate, _left, _right];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_left == source) {
      _left = target;
    }
    if (_right == source) {
      _right = target;
    }
  }
}
