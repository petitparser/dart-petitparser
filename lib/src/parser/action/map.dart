import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension MapParserExtension<R> on Parser<R> {
  /// Returns a parser that evaluates a [callback] as the production action
  /// on success of the receiver.
  ///
  /// [callback] should be side-effect free, meaning for the same input it
  /// always gives the same output. This allows the framework skip calling
  /// the callback if the result is not used, or to cache the results. If
  /// [callback] has side-effects, make sure to exactly understand the
  /// implications and set [hasSideEffects] to `true`.
  ///
  /// For example, the parser `digit().map((char) => int.parse(char))` returns
  /// the number `1` for the input string `'1'`. If the delegate fails, the
  /// production action is not executed and the failure is passed on.
  @useResult
  Parser<S> map<S>(Callback<R, S> callback, {bool hasSideEffects = false}) =>
      MapParser<R, S>(this, callback, hasSideEffects: hasSideEffects);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class MapParser<R, S> extends DelegateParser<R, S> {
  MapParser(super.delegate, this.callback, {this.hasSideEffects = false});

  /// The production action to be called.
  final Callback<R, S> callback;

  /// Whether the [callback] has side-effects.
  final bool hasSideEffects;

  @override
  Result<S> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) return result;
    return result.success(callback(result.value));
  }

  // If we know to have side-effects, we have to fall back to the slow mode.
  @override
  int fastParseOn(String buffer, int position) => hasSideEffects
      ? super.fastParseOn(buffer, position)
      : delegate.fastParseOn(buffer, position);

  @override
  bool hasEqualProperties(MapParser<R, S> other) =>
      super.hasEqualProperties(other) &&
      callback == other.callback &&
      hasSideEffects == other.hasSideEffects;

  @override
  MapParser<R, S> copy() =>
      MapParser<R, S>(delegate, callback, hasSideEffects: hasSideEffects);
}
