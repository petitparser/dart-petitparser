import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/failure.dart';
import '../../context/result.dart';
import '../../context/success.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension WhereParserExtension<T> on Parser<T> {
  /// Returns a parser that evaluates the [predicate] with the successful
  /// parse result. If the predicate returns `true` the parser proceeds with
  /// the parse result, otherwise a parse failure is created using the
  /// optionally specified [failureMessage] and [failurePosition] callbacks.
  ///
  /// The function [failureMessage] receives the parse result and is expected
  /// to return an error string of the failed predicate. If no function is
  /// provided a default error message is created.
  ///
  /// Similarly, the [failurePosition] receives the parse result and is
  /// expected to return the position of the error of the failed predicate. If
  /// no function is provided the parser fails at the beginning of the
  /// delegate.
  ///
  /// The following example parses two characters, but only succeeds if they
  /// are equal:
  ///
  ///     final inner = any() & any();
  ///     final parser = inner.where(
  ///         (value) => value[0] == value[1],
  ///         failureFactory: (context, success) =>
  ///             context.failure('characters do not match'));
  ///     parser.parse('aa');   // ==> Success: ['a', 'a']
  ///     parser.parse('ab');   // ==> Failure: characters do not match
  ///
  @useResult
  Parser<T> where(
    Predicate<T> predicate, {
    FailureFactory<T>? failureFactory,
    @Deprecated('Use `failureFactory` instead')
        Callback<T, String>? failureMessage,
    @Deprecated('Use `failureFactory` instead')
        Callback<T, int>? failurePosition,
  }) =>
      WhereParser<T>(
          this,
          predicate,
          failureFactory ??
              ((failureMessage != null || failurePosition != null)
                  ? (context, success) => context.failure(
                      failureMessage?.call(success.value) ??
                          'unexpected "${success.value}"',
                      failurePosition?.call(success.value))
                  : (context, success) =>
                      context.failure('unexpected "${success.value}"')));
}

typedef FailureFactory<T> = Failure<T> Function(
    Context context, Success<T> success);

class WhereParser<T> extends DelegateParser<T, T> {
  WhereParser(super.parser, this.predicate, this.failureFactory);

  final Predicate<T> predicate;
  final FailureFactory<T> failureFactory;

  @override
  Result<T> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Success<T> && !predicate(result.value)) {
      return failureFactory(context, result);
    }
    return result;
  }

  @override
  Parser<T> copy() => WhereParser<T>(delegate, predicate, failureFactory);

  @override
  bool hasEqualProperties(WhereParser<T> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      failureFactory == other.failureFactory;
}
