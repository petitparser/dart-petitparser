library petitparser.core.actions.action;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Typed action callback.
typedef R ActionCallback<T, R>(T value);

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class ActionParser<T, R> extends DelegateParser<R> {
  final ActionCallback<T, R> callback;

  ActionParser(Parser<T> delegate, this.callback) : super(delegate);

  @override
  Result<R> parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(callback(result.value));
    } else {
      return result.failure(result.message);
    }
  }

  @override
  Parser<R> copy() => ActionParser<T, R>(delegate, callback);

  @override
  bool hasEqualProperties(Parser other) {
    return other is ActionParser &&
        super.hasEqualProperties(other) &&
        callback == other.callback;
  }
}
