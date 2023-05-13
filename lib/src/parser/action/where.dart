import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension WhereParserExtension<R> on Parser<R> {
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
  Parser<R> where(
    Predicate<R> predicate, {
    FailureFactory<R>? failureFactory,
    @Deprecated('Use `failureFactory` instead')
        Callback<R, String>? failureMessage,
    @Deprecated('Use `failureFactory` instead')
        Callback<R, int>? failurePosition,
  }) =>
      WhereParser<R>(
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

typedef FailureFactory<R> = Failure<R> Function(
    Context context, Success<R> success);

class WhereParser<R> extends DelegateParser<R, R> {
  WhereParser(super.parser, this.predicate, this.failureFactory);

  final Predicate<R> predicate;
  final FailureFactory<R> failureFactory;

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    return switch (result) {
      Success(value: final value) when !predicate(value) =>
        failureFactory(context, result),
      _ => result
    };
  }

  @override
  Parser<R> copy() => WhereParser<R>(delegate, predicate, failureFactory);

  @override
  bool hasEqualProperties(WhereParser<R> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      failureFactory == other.failureFactory;
}
