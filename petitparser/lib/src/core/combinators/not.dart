library petitparser.core.combinators.not;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'delegate.dart';

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input [Parr 1994, 1995].
class NotParser extends DelegateParser<void> {
  final String message;

  NotParser(Parser delegate, this.message)
      : assert(message != null, 'message must not be null'),
        super(delegate);

  @override
  Result<void> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(null);
    } else {
      return context.failure(message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? position : -1;
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  NotParser copy() => NotParser(delegate, message);

  @override
  bool hasEqualProperties(NotParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
