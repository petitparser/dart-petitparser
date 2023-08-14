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
  /// optionally specified [factory] callback, the provided [message], or
  /// otherwise an automatically created error message.
  ///
  /// The following example parses two characters, but only succeeds if they
  /// are equal:
  ///
  ///     final inner = any() & any();
  ///     final parser = inner.where(
  ///         (value) => value[0] == value[1],
  ///         factory: (context, success) =>
  ///             context.failure('characters do not match'));
  ///     parser.parse('aa');   // ==> Success: ['a', 'a']
  ///     parser.parse('ab');   // ==> Failure: characters do not match
  ///
  @useResult
  Parser<R> where(
    Predicate<R> predicate, {
    String? message,
    FailureFactory<R>? factory,
    @Deprecated('Use `factory` instead') Callback<R, String>? failureMessage,
    @Deprecated('Use `factory` instead') Callback<R, int>? failurePosition,
    @Deprecated('Use `factory` instead') FailureFactory<R>? failureFactory,
  }) =>
      WhereParser<R>(
          this,
          predicate,
          createFactory_<R>(
              message: message,
              factory: factory ?? failureFactory,
              failureMessage: failureMessage,
              failurePosition: failurePosition));
}

typedef FailureFactory<R> = Result<R> Function(
    Context context, Success<R> success);

class WhereParser<R> extends DelegateParser<R, R> {
  WhereParser(super.parser, this.predicate, this.factory);

  final Predicate<R> predicate;
  final FailureFactory<R> factory;

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Success<R> && !predicate(result.value)) {
      return factory(context, result);
    }
    return result;
  }

  @override
  Parser<R> copy() => WhereParser<R>(delegate, predicate, factory);

  @override
  bool hasEqualProperties(WhereParser<R> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      factory == other.factory;
}

FailureFactory<R> createFactory_<R>({
  String? message,
  FailureFactory<R>? factory,
  Callback<R, String>? failureMessage,
  Callback<R, int>? failurePosition,
}) =>
    factory ??
    (context, success) => context.failure(
        failureMessage?.call(success.value) ??
            message ??
            'unexpected "${success.value}"',
        failurePosition?.call(success.value));
