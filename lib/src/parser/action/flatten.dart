import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension FlattenParserExtension<T> on Parser<T> {
  /// Returns a parser that discards the result of the receiver and answers
  /// the sub-string its delegate consumes.
  ///
  /// If a [message] is provided, the flatten parser can switch to a fast mode
  /// where error tracking within the receiver is suppressed and in case of a
  /// problem [message] is reported instead.
  ///
  /// For example, the parser `letter().plus().flatten()` returns `'abc'`
  /// for the input `'abc'`. In contrast, the parser `letter().plus()` would
  /// return `['a', 'b', 'c']` for the same input instead.
  @useResult
  Parser<String> flatten([String? message]) => FlattenParser<T>(this, message);
}

/// A parser that discards the result of the delegate and answers the
/// sub-string its delegate consumes.
class FlattenParser<T> extends DelegateParser<T, String> {
  FlattenParser(super.delegate, [this.message]);

  /// Error message to indicate parse failures with.
  final String? message;

  @override
  void parseOn(Context context) {
    final position = context.position;
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.value = context.buffer.substring(position, context.position);
    } else if (message != null) {
      context.position = position;
      context.message = message!;
    }
  }

  @override
  bool hasEqualProperties(FlattenParser<T> other) =>
      super.hasEqualProperties(other) && message == other.message;

  @override
  FlattenParser<T> copy() => FlattenParser<T>(delegate, message);
}
