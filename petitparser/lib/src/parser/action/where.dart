import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';
import '../utils/types.dart';

extension WhereParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates the [predicate] with the successful
  /// parse result. If the predicate returns `true` the parser proceeds with
  /// the parse result, otherwise a parse failure is created:
  ///
  /// - [onFailure] is called to generate an failure message,
  /// - [failureMessage] is used to as the failure message, or
  /// - a standard error message with the parsed input is created.
  ///
  /// The following example parses two digits, but only succeeds if the two
  /// numbers match:
  ///
  ///     final inner = digit() & digit();
  ///     final parser = inner.where(
  ///         (value) => value[0] == value[1],
  ///         failureMessage: 'digits do not match');
  ///     parser.parse('11');   // ==> Success: ['1', '1']
  ///     parser.parse('12');   // ==> Failure: digits do not match
  ///
  Parser<T> where(Predicate<T> predicate,
          {Callback<T, String>? onFailure, String? failureMessage}) =>
      WhereParser<T>(
          this,
          predicate,
          onFailure ??
              (failureMessage != null
                  ? (value) => failureMessage
                  : (value) => 'unexpected "$value"'));
}

class WhereParser<T> extends DelegateParser<T, T> {
  final Predicate<T> predicate;
  final Callback<T, String> onFailure;

  WhereParser(Parser<T> parser, this.predicate, this.onFailure) : super(parser);

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    return result.isSuccess && !predicate(result.value)
        ? context.failure(onFailure(result.value))
        : result;
  }

  @override
  Parser<T> copy() => WhereParser<T>(delegate, predicate, onFailure);

  @override
  bool hasEqualProperties(WhereParser<T> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      onFailure == other.onFailure;
}
