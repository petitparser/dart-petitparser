import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension MapParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates a [callback] as the production action
  /// on success of the receiver.
  ///
  /// By default we assume the [callback] to be side-effect free. Unless
  /// [hasSideEffects] is set to `true`, the execution might be skipped if there
  /// are no direct dependencies.
  ///
  /// For example, the parser `digit().map((char) => int.parse(char))` returns
  /// the number `1` for the input string `'1'`. If the delegate fails, the
  /// production action is not executed and the failure is passed on.
  Parser<R> map<R>(Callback<T, R> callback, {bool hasSideEffects = false}) =>
      MapParser<T, R>(this, callback, hasSideEffects);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class MapParser<T, R> extends DelegateParser<T, R> {
  MapParser(Parser<T> delegate, this.callback, [this.hasSideEffects = false])
      : super(delegate);

  /// The production action to be called.
  final Callback<T, R> callback;

  /// Whether the [callback] has side-effects.
  final bool hasSideEffects;

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(callback(result.value));
    } else {
      return result.failure(result.message);
    }
  }

  // If we know to have side-effects, we have to fall back to the slow mode.
  @override
  int fastParseOn(String buffer, int position) => hasSideEffects
      ? super.fastParseOn(buffer, position)
      : delegate.fastParseOn(buffer, position);

  @override
  bool hasEqualProperties(MapParser<T, R> other) =>
      super.hasEqualProperties(other) &&
      callback == other.callback &&
      hasSideEffects == other.hasSideEffects;

  @override
  MapParser<T, R> copy() => MapParser<T, R>(delegate, callback, hasSideEffects);
}
