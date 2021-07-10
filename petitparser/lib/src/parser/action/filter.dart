import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';
import '../utils/types.dart';

extension FilterParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates the [predicate] with the successful
  /// parse result. If the predicate returns `true` the parser proceeds with
  /// the parse result, otherwise a parse error with the provided error
  /// [message] is created.
  ///
  /// The following parser example parses two digits, but only succeeds if the
  /// two numbers match:
  ///
  ///     final inner = digit() & digit();
  ///     final parser = inner.filter(
  ///         (value) => value[0] == value[1],
  ///         'digits do not match');
  ///     parser.parse('11');   // ==> Success: ['1', '1']
  ///     parser.parse('12');   // ==> Failure: digits do not match
  Parser<T> filter(Predicate<T> predicate, String message) =>
      FilterParser<T>(this, predicate, message);
}

class FilterParser<T> extends DelegateParser<T, T> {
  final Predicate<T> predicate;
  final String message;

  FilterParser(Parser<T> parser, this.predicate, this.message) : super(parser);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    return result.isSuccess && !predicate(result.value)
        ? context.failure(message)
        : result;
  }

  @override
  Parser<T> copy() => FilterParser<T>(delegate, predicate, message);

  @override
  bool hasEqualProperties(FilterParser<T> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      message == other.message;
}
