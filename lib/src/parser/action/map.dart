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
  Parser<R> map<R>(Callback<T, R> callback) =>
      MapSuccessParser<T, R>(this, callback);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class MapSuccessParser<T, R> extends DelegateParser<T, R> {
  MapSuccessParser(super.delegate, this.callback);

  /// The production action to be called.
  final Callback<T, R> callback;

  @override
  void parseOn(Context context) {
    final isSkip = context.isSkip;
    context.isSkip = false;
    delegate.parseOn(context);
    context.isSkip = isSkip;
    if (context.isSuccess) {
      context.value = callback(context.value);
    }
  }

  @override
  bool hasEqualProperties(MapSuccessParser<T, R> other) =>
      super.hasEqualProperties(other) && callback == other.callback;

  @override
  MapSuccessParser<T, R> copy() => MapSuccessParser<T, R>(delegate, callback);
}
