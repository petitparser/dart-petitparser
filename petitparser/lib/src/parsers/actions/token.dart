library petitparser.parsers.actions.token;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';
import '../../core/token.dart';
import '../combinators/delegate.dart';

extension TokenParserExtension<T> on Parser<T> {
  /// Returns a parser that returns a [Token]. The token carries the parsed
  /// value of the receiver [Token.value], as well as the consumed input
  /// [Token.input] from [Token.start] to [Token.stop] of the input being
  /// parsed.
  ///
  /// For example, the parser `letter().plus().token()` returns the token
  /// `Token[start: 0, stop: 3, value: abc]` for the input `'abc'`.
  Parser<Token<T>> token() => TokenParser<T>(this);
}

/// A parser that answers a token of the result its delegate parses.
class TokenParser<T> extends DelegateParser<Token<T>> {
  TokenParser(Parser delegate) : super(delegate);

  @override
  Result<Token<T>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      final token = Token<T>(
          result.value, context.buffer, context.position, result.position);
      return result.success(token);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  TokenParser<T> copy() => TokenParser<T>(delegate);
}
