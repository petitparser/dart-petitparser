import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';

/// Returns a parser that consumes nothing and fails.
///
/// For example, `failure()` always fails, no matter what input it is given.
@useResult
Parser<R> failure<R>([String message = 'unable to parse']) =>
    FailureParser<R>(message);

/// A parser that consumes nothing and fails.
class FailureParser<R> extends Parser<R> {
  FailureParser(this.message);

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    context.isSuccess = false;
    context.message = message;
  }

  @override
  void fastParseOn(Context context) {
    context.isSuccess = false;
    context.message = message;
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  FailureParser<R> copy() => FailureParser<R>(message);

  @override
  bool hasEqualProperties(FailureParser<R> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
