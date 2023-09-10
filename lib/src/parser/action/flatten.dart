import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../combinator/delegate.dart';

extension FlattenParserExtension<R> on Parser<R> {
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
  Parser<String> flatten([String? message]) => FlattenParser<R>(this, message);
}

/// A parser that discards the result of the delegate and answers the
/// sub-string its delegate consumes.
class FlattenParser<R> extends DelegateParser<R, String> {
  FlattenParser(super.delegate, [this.message]);

  /// Error message to indicate parse failures with.
  final String? message;

  @override
  Result<String> parseOn(Context context) {
    if (message != null) {
      // If we have a message we can switch to fast mode.
      final position = delegate.fastParseOn(context.buffer, context.position);
      if (position < 0) return context.failure(message!);
      final output = context.buffer.substring(context.position, position);
      return context.success(output, position);
    } else {
      final result = delegate.parseOn(context);
      if (result is Failure) return result;
      final output =
          context.buffer.substring(context.position, result.position);
      return result.success(output);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  String toString() =>
      message == null ? super.toString() : '${super.toString()}[$message]';

  @override
  bool hasEqualProperties(FlattenParser<R> other) =>
      super.hasEqualProperties(other) && message == other.message;

  @override
  FlattenParser<R> copy() => FlattenParser<R>(delegate, message);
}
