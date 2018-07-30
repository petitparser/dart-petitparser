library petitparser.core.combinators.not;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input [Parr 1994, 1995].
class NotParser extends DelegateParser<Null> {
  final String message;

  NotParser(Parser delegate, this.message) : super(delegate);

  @override
  Result<Null> parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(null);
    } else {
      return context.failure(message);
    }
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  NotParser copy() => NotParser(delegate, message);

  @override
  bool hasEqualProperties(NotParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
