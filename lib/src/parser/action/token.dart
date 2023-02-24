import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../core/token.dart';
import '../combinator/delegate.dart';

extension TokenParserExtension<T> on Parser<T> {
  /// Returns a parser that returns a [Token]. The token carries the parsed
  /// value of the receiver [Token.value], as well as the consumed input
  /// [Token.input] from [Token.start] to [Token.stop] of the input being
  /// parsed.
  ///
  /// For example, the parser `letter().plus().token()` returns the token
  /// `Token[start: 0, stop: 3, value: abc]` for the input `'abc'`.
  @useResult
  Parser<Token<T>> token() => TokenParser<T>(this);
}

/// A parser that creates a token of the result its delegate parses.
class TokenParser<R> extends DelegateParser<R, Token<R>> {
  TokenParser(super.delegate);

  @override
  void parseOn(Context context) {
    final position = context.position;
    delegate.parseOn(context);
    if (context.isSuccess) {
      context.value =
          Token<R>(context.value, context.buffer, position, context.position);
    }
  }

  @override
  TokenParser<R> copy() => TokenParser<R>(delegate);
}
