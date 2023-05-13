import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../core/token.dart';
import '../combinator/delegate.dart';

extension TokenParserExtension<R> on Parser<R> {
  /// Returns a parser that returns a [Token]. The token carries the parsed
  /// value of the receiver [Token.value], as well as the consumed input
  /// [Token.input] from [Token.start] to [Token.stop] of the input being
  /// parsed.
  ///
  /// For example, the parser `letter().plus().token()` returns the token
  /// `Token[start: 0, stop: 3, value: abc]` for the input `'abc'`.
  @useResult
  Parser<Token<R>> token() => TokenParser<R>(this);
}

/// A parser that creates a token of the result its delegate parses.
class TokenParser<R> extends DelegateParser<R, Token<R>> {
  TokenParser(super.delegate);

  @override
  Result<Token<R>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    switch (result) {
      case Success(value: final value, position: final position):
        final token =
            Token<R>(value, context.buffer, context.position, position);
        return result.success(token);
      case Failure(message: final message):
        return result.failure(message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  TokenParser<R> copy() => TokenParser<R>(delegate);
}
