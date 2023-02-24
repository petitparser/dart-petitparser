import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import 'delegate.dart';

extension AndParserExtension<T> on Parser<T> {
  /// Returns a parser (logical and-predicate) that succeeds whenever the
  /// receiver does, but never consumes input.
  ///
  /// For example, the parser `char('_').and().seq(identifier)` accepts
  /// identifiers that start with an underscore character. Since the predicate
  /// does not consume accepted input, the parser `identifier` is given the
  /// ability to process the complete identifier.
  @useResult
  Parser<T> and() => AndParser<T>(this);
}

/// The and-predicate, a parser that succeeds whenever its delegate does, but
/// does not consume the input stream [Parr 1994, 1995].
class AndParser<R> extends DelegateParser<R, R> {
  AndParser(super.delegate);

  @override
  void parseOn(Context context) {
    final position = context.position;
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.position = position;
    }
  }

  @override
  AndParser<R> copy() => AndParser<R>(delegate);
}
