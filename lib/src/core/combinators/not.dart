library petitparser.core.combinators.not;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input [Parr 1994, 1995].
class NotParser extends DelegateParser {
  final String _message;

  NotParser(Parser delegate, this._message) : super(delegate);

  @override
  Result parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(null);
    } else {
      return context.failure(_message);
    }
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => new NotParser(delegate, _message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is NotParser && super.hasEqualProperties(other) && _message == other._message;
  }
}
