import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';

/// Returns a parser that consumes nothing and fails.
///
/// For example, `failure()` always fails, no matter what input it is given.
Parser<T> failure<T>([String message = 'unable to parse']) {
  return FailureParser<T>(message);
}

/// A parser that consumes nothing and fails.
class FailureParser<T> extends Parser<T> {
  final String message;

  FailureParser(this.message)
      : assert(message != null, 'message must not be null');

  @override
  Result<T> parseOn(Context context) => context.failure<T>(message);

  @override
  int fastParseOn(String buffer, int position) => -1;

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  FailureParser<T> copy() => FailureParser<T>(message);

  @override
  bool hasEqualProperties(FailureParser<T> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
