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
  /// For example, the parser `digit().map((char) => int.parse(char))` returns
  /// the number `1` for the input string `'1'`. If the delegate fails, the
  /// production action is not executed and the failure is passed on.
  @useResult
  Parser<S> map<S>(
    Callback<R, S> callback, {
    @Deprecated('All callbacks are considered to have side-effects')
        bool hasSideEffects = true,
  }) =>
      MapParser<R, S>(this, callback);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class MapParser<R, S> extends DelegateParser<R, S> {
  MapParser(super.delegate, this.callback);

  /// The production action to be called.
  final Callback<R, S> callback;

  @override
  Result<S> parseOn(Context context) {
    final result = delegate.parseOn(context);
    return switch (result) {
      Success(value: final value) => result.success(callback(value)),
      Failure(message: final message) => result.failure(message)
    };
  }

  @override
  bool hasEqualProperties(MapParser<R, S> other) =>
      super.hasEqualProperties(other) && callback == other.callback;

  @override
  MapParser<R, S> copy() => MapParser<R, S>(delegate, callback);
}
