import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension MapParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates a [callback] as the production action
  /// on success of the receiver.
  ///
  /// For example, the parser `digit().map((char) => int.parse(char))` returns
  /// the number `1` for the input string `'1'`. If the delegate fails, the
  /// production action is not executed and the failure is passed on.
  @useResult
  Parser<R> map<R>(Callback<T, R> callback, {bool hasSideEffects = false}) =>
      MapParser<T, R>(this, callback, hasSideEffects);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class MapParser<T, R> extends DelegateParser<T, R> {
  MapParser(super.delegate, this.callback, this.hasSideEffects);

  /// The production action to be called.
  final Callback<T, R> callback;

  /// If `true`, executes the callback even if the calling parser is not
  /// interested in the value.
  final bool hasSideEffects;

  @override
  void parseOn(Context context) {
    if (context.isSkip) {
      if (hasSideEffects) {
        context.isSkip = false;
        delegate.parseOn(context);
        if (context.isSuccess) {
          callback(context.value);
        }
        context.isSkip = true;
      } else {
        delegate.parseOn(context);
      }
    } else {
      delegate.parseOn(context);
      if (context.isSuccess) {
        context.value = callback(context.value);
      }
    }
  }

  @override
  bool hasEqualProperties(MapParser<T, R> other) =>
      super.hasEqualProperties(other) && callback == other.callback;

  @override
  MapParser<T, R> copy() => MapParser<T, R>(delegate, callback, hasSideEffects);
}
