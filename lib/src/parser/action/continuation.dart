import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../parser/combinator/delegate.dart';

/// Handler function for the [ContinuationParser].
typedef ContinuationHandler<R, S> = Result<S> Function(
    ContinuationFunction<R> continuation, Context context);

/// Continuation function of the [ContinuationHandler].
typedef ContinuationFunction<R> = Result<R> Function(Context context);

extension ContinuationParserExtension<R> on Parser<R> {
  /// Returns a parser that when activated captures a continuation function
  /// and passes it together with the current context into the handler.
  ///
  /// Handlers are not required to call the continuation, but can completely
  /// ignore it, call it multiple times, and/or store it away for later use.
  /// Similarly handlers can modify the current context and/or modify the
  /// returned result.
  ///
  /// The following example shows a simple wrapper. Messages are printed before
  /// and after the `digit()` parser is activated:
  ///
  ///     final parser = digit().callCC((continuation, context) {
  ///       print('Parser will be activated, the context is $context.');
  ///       final result = continuation(context);
  ///       print('Parser was activated, the result is $result.');
  ///       return result;
  ///     });
  ///
  @useResult
  Parser<S> callCC<S>(ContinuationHandler<R, S> handler) =>
      ContinuationParser<R, S>(this, handler);
}

/// Continuation parser that when activated captures a continuation function
/// and passes it together with the current context into the handler.
class ContinuationParser<R, S> extends DelegateParser<R, S> {
  ContinuationParser(super.delegate, this.handler);

  /// Activation handler of the continuation.
  final ContinuationHandler<R, S> handler;

  @override
  Result<S> parseOn(Context context) => handler(_parseDelegateOn, context);

  Result<R> _parseDelegateOn(Context context) => delegate.parseOn(context);

  @override
  ContinuationParser<R, S> copy() =>
      ContinuationParser<R, S>(delegate, handler);

  @override
  bool hasEqualProperties(ContinuationParser<R, S> other) =>
      super.hasEqualProperties(other) && handler == other.handler;
}
