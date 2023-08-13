import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../combinator/skip.dart';

extension EndOfInputParserExtension<R> on Parser<R> {
  /// Returns a parser that succeeds only if the receiver consumes the complete
  /// input, otherwise return a failure with the optional [message].
  ///
  /// For example, the parser `letter().end()` succeeds on the input `'a'`
  /// and fails on `'ab'`. In contrast the parser `letter()` alone would
  /// succeed on both inputs, but not consume everything for the second input.
  @useResult
  Parser<R> end([String message = 'end of input expected']) =>
      skip(after: endOfInput(message));
}

/// Returns a parser that succeeds at the end of input.
@useResult
Parser<void> endOfInput([String message = 'end of input expected']) =>
    EndOfInputParser(message);

/// A parser that succeeds at the end of input.
class EndOfInputParser extends Parser<void> {
  EndOfInputParser(this.message);

  /// Error message to annotate parse failures with.
  final String message;

  @override
  Result<void> parseOn(Context context) {
    if (context.position < context.buffer.length) {
      return context.failure(message);
    } else {
      return context.success(null);
    }
  }

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
