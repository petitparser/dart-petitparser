import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import 'delegate.dart';

extension AndParserExtension<R> on Parser<R> {
  /// Returns a parser (logical and-predicate) that succeeds whenever the
  /// receiver does, but never consumes input.
  ///
  /// For example, the parser `char('_').and().seq(identifier)` accepts
  /// identifiers that start with an underscore character. Since the predicate
  /// does not consume accepted input, the parser `identifier` is given the
  /// ability to process the complete identifier.
  @useResult
  Parser<R> and() => AndParser<R>(this);
}

/// The and-predicate, a parser that succeeds whenever its delegate does, but
/// does not consume the input stream.
class AndParser<R> extends DelegateParser<R, R> {
  AndParser(super.delegate);

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) return result;
    return context.success(result.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? -1 : position;
  }

  @override
  AndParser<R> copy() => AndParser<R>(delegate);
}
