library petitparser.core.parsers.eof;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that succeeds at the end of input.
Parser endOfInput([String message = 'end of input expected']) =>
    EndOfInputParser(message);

/// A parser that succeeds at the end of input.
class EndOfInputParser extends Parser<void> {
  final String message;

  EndOfInputParser(this.message) : assert(message != null);

  @override
  Result parseOn(Context context) => context.position < context.buffer.length
      ? context.failure(message)
      : context.success(null);

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length ? -1 : position;

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  EndOfInputParser copy() => EndOfInputParser(message);

  @override
  bool hasEqualProperties(EndOfInputParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
