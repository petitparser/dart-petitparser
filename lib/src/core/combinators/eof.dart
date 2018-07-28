library petitparser.core.combinators.eof;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that succeeds only at the end of the input.
class EndOfInputParser extends DelegateParser {
  final String _message;

  EndOfInputParser(Parser delegate, this._message) : super(delegate);

  @override
  Result parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isFailure || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.position);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => EndOfInputParser(delegate, _message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is EndOfInputParser &&
        super.hasEqualProperties(other) &&
        _message == other._message;
  }
}
