library petitparser.core.actions.action;

import '../combinators/delegate.dart';
import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';

/// Typed action callback.
typedef ActionCallback<T, R> = R Function(T value);

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class ActionParser<T, R> extends DelegateParser<R> {
  final ActionCallback<T, R> callback;
  final bool hasSideEffects;

  ActionParser(Parser<T> delegate, this.callback, [this.hasSideEffects = false])
      : assert(callback != null, 'callback must not be null'),
        assert(hasSideEffects != null, 'hasSideEffects must not be null'),
        super(delegate);

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(callback(result.value));
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    // If we know to have side-effects, we have to fall back to the slow mode.
    return hasSideEffects
        ? super.fastParseOn(buffer, position)
        : delegate.fastParseOn(buffer, position);
  }

  @override
  ActionParser<T, R> copy() =>
      ActionParser<T, R>(delegate, callback, hasSideEffects);

  @override
  bool hasEqualProperties(ActionParser<T, R> other) =>
      super.hasEqualProperties(other) &&
      callback == other.callback &&
      hasSideEffects == other.hasSideEffects;
}
