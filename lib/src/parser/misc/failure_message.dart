import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension FailureMessageParserExtension<R> on Parser<R> {
  /// Returns a parser that replaces a failure message of the receiver with
  /// [message].
  ///
  /// For example, the parser `digit().failure('NaN')` returns digits. If fed
  /// with a letter it returns the error message 'NaN' instead of the standard
  /// 'digit expected'.
  @useResult
  Parser<R> failure(String message) => FailureMessageParser<R>(this, message);
}

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class FailureMessageParser<R> extends DelegateParser<R, R> {
  FailureMessageParser(super.delegate, this.message);

  /// The failure message to use.
  final String message;

  @override
  void parseOn(Context context) {
    final position = context.position;
    delegate.parseOn(context);
    if (!context.isSuccess) {
      context.position = position;
      context.message = message;
    }
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  bool hasEqualProperties(FailureMessageParser<R> other) =>
      super.hasEqualProperties(other) && message == other.message;

  @override
  FailureMessageParser<R> copy() => FailureMessageParser<R>(delegate, message);
}
