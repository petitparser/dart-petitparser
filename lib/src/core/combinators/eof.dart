library petitparser.core.combinators.eof;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that succeeds only at the end of the input.
class EndOfInputParser<T> extends DelegateParser<T> {
  final String message;

  EndOfInputParser(Parser delegate, this.message) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isFailure || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(message, result.position);
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  EndOfInputParser<T> copy() => EndOfInputParser<T>(delegate, message);

  @override
  bool hasEqualProperties(EndOfInputParser<T> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
