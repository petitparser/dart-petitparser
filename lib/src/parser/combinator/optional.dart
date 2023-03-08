import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
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
  void parseOn(Context context) {
    final position = context.position;
    final isCut = context.isCut;
    context.isCut = false;
    delegate.parseOn(context);
    if (!context.isSuccess && !context.isCut) {
      context.isSuccess = true;
      context.position = position;
      if (!context.isSkip) {
        context.value = otherwise;
      }
    }
    context.isCut |= isCut;
  }

  @override
  OptionalParser<R> copy() => OptionalParser<R>(delegate, otherwise);

  @override
  bool hasEqualProperties(OptionalParser<R> other) =>
      super.hasEqualProperties(other) && otherwise == other.otherwise;
}
