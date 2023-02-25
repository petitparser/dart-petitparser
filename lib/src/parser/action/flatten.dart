import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';
import '../misc/failure_message.dart';

extension FlattenParserExtension<R> on Parser<R> {
  /// Returns a parser that discards the result of the receiver and answers
  /// the sub-string its delegate consumes.
  ///
  /// The provided [message] is uses in case of an error instead of the error
  /// message by provided by its delegate.
  ///
  /// For example, the parser `letter().plus().flatten()` returns `'abc'`
  /// for the input `'abc'`. In contrast, the parser `letter().plus()` would
  /// return `['a', 'b', 'c']` for the same input.
  @useResult
  Parser<String> flatten([String? message]) => message == null
      ? FlattenParser<R>(this)
      : FlattenParser<R>(this).failure(message);
}

/// A parser that discards the result of the delegate and answers the
/// sub-string its delegate consumes.
class FlattenParser<T> extends DelegateParser<T, String> {
  FlattenParser(super.delegate);

  @override
  void parseOn(Context context) {
    if (context.isSkip) {
      // If we are already skipping, just continue.
      return delegate.parseOn(context);
    }
    final position = context.position;
    context.isSkip = true;
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.value = context.buffer.substring(position, context.position);
    }
    context.isSkip = false;
  }

  @override
  bool hasEqualProperties(FlattenParser<T> other) =>
      super.hasEqualProperties(other);

  @override
  FlattenParser<T> copy() => FlattenParser<T>(delegate);
}
