library petitparser.parser.action.trimming;

import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../character/whitespace.dart';
import '../combinator/delegate.dart';

extension TrimmingParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns returns the result of the
  /// receiver. The optional arguments are parsers that consume the excess
  /// input. By default `whitespace()` is used. Up to two arguments can be
  /// provided to have different parsers on the [left] and [right] side.
  ///
  /// For example, the parser `letter().plus().trim()` returns `['a', 'b']`
  /// for the input `' ab\n'` and consumes the complete input string.
  Parser<T> trim([Parser left, Parser right]) =>
      TrimmingParser<T>(this, left ??= whitespace(), right ??= left);
}

/// A parser that silently consumes input of another parser around
/// its delegate.
class TrimmingParser<T> extends DelegateParser<T> {
  Parser left;
  Parser right;

  TrimmingParser(Parser<T> delegate, this.left, this.right)
      : assert(left != null, 'left must not be null'),
        assert(right != null, 'right must not be null'),
        super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final buffer = context.buffer;

    // Trim the left part:
    final before = trim_(left, buffer, context.position);
    if (before != context.position) {
      context = Context(buffer, before);
    }

    // Consume the delegate:
    final result = delegate.parseOn(context);
    if (result.isFailure) {
      return result;
    }

    // Trim the right part:
    final after = trim_(right, buffer, result.position);
    return after == result.position
        ? result
        : result.success(result.value, after);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, trim_(left, buffer, position));
    return result < 0 ? -1 : trim_(right, buffer, result);
  }

  int trim_(Parser parser, String buffer, int position) {
    for (;;) {
      final result = parser.fastParseOn(buffer, position);
      if (result < 0) {
        return position;
      }
      position = result;
    }
  }

  @override
  TrimmingParser<T> copy() => TrimmingParser<T>(delegate, left, right);

  @override
  List<Parser> get children => [delegate, left, right];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (left == source) {
      left = target;
    }
    if (right == source) {
      right = target;
    }
  }
}
