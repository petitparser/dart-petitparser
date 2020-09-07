import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'delegate.dart';

extension OptionalParserExtension<T> on Parser<T> {
  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or `null` if not applicable.
  ///
  /// For example, the parser `letter().optional()` accepts a letter as input
  /// and returns that letter. When given something else the parser succeeds as
  /// well, does not consume anything and returns `null`.
  Parser<T?> optional() => OptionalParser<T?>(this, null);

  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or [value] if not applicable.
  ///
  /// For example, the parser `letter().optionalWith('!')` accepts a letter as
  /// input and returns that letter. When given something else the parser
  /// succeeds as well, does not consume anything and returns `'!'`.
  Parser<T> optionalWith(T value) => OptionalParser<T>(this, value);
}

/// A parser that optionally parsers its delegate, or answers null.
class OptionalParser<T> extends DelegateParser<T> {
  final T otherwise;

  OptionalParser(Parser<T> delegate, this.otherwise) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result as Result<T>;
    } else {
      return context.success(otherwise);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? position : result;
  }

  @override
  OptionalParser<T> copy() =>
      OptionalParser<T>(delegate as Parser<T>, otherwise);

  @override
  bool hasEqualProperties(OptionalParser<T> other) =>
      super.hasEqualProperties(other) && otherwise == other.otherwise;
}
