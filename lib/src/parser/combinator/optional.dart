import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import 'delegate.dart';

extension OptionalParserExtension<R> on Parser<R> {
  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or `null` if not applicable.
  ///
  /// For example, the parser `letter().optional()` accepts a letter as input
  /// and returns that letter. When given something else the parser succeeds as
  /// well, does not consume anything and returns `null`.
  @useResult
  Parser<R?> optional() => OptionalParser<R?>(this, null);

  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or [value] if not applicable.
  ///
  /// For example, the parser `letter().optionalWith('!')` accepts a letter as
  /// input and returns that letter. When given something else the parser
  /// succeeds as well, does not consume anything and returns `'!'`.
  @useResult
  Parser<R> optionalWith(R value) => OptionalParser<R>(this, value);
}

/// A parser that optionally parsers its delegate, or answers `null`.
class OptionalParser<R> extends DelegateParser<R, R> {
  OptionalParser(super.delegate, this.otherwise);

  /// The value returned if the [delegate] cannot be parsed.
  final R otherwise;

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is! Failure) return result;
    return context.success(otherwise);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? position : result;
  }

  @override
  OptionalParser<R> copy() => OptionalParser<R>(delegate, otherwise);

  @override
  bool hasEqualProperties(OptionalParser<R> other) =>
      super.hasEqualProperties(other) && otherwise == other.otherwise;
}
