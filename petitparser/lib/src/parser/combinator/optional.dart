import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'delegate.dart';

extension OptionalParserExtension<T> on Parser<T> {
  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or `null` if not applicable.
  /// The returned value can be provided as an optional argument [otherwise].
  ///
  /// For example, the parser `letter().optional()` accepts a letter as input
  /// and returns that letter. When given something else the parser succeeds as
  /// well, does not consume anything and returns `null`.
  Parser<T> optional([T otherwise]) => OptionalParser<T>(this, otherwise);
}

/// A parser that optionally parsers its delegate, or answers nil.
class OptionalParser<T> extends DelegateParser<T> {
  final T otherwise;

  OptionalParser(Parser<T> delegate, this.otherwise) : super(delegate);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result;
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
  OptionalParser<T> copy() => OptionalParser<T>(delegate, otherwise);

  @override
  bool hasEqualProperties(OptionalParser<T> other) =>
      super.hasEqualProperties(other) && otherwise == other.otherwise;
}
