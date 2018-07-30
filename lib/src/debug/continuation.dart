library petitparser.debug.continuation;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/debug/profile.dart';
import 'package:petitparser/src/debug/progress.dart';
import 'package:petitparser/src/debug/trace.dart';

/// Callback function for the [ContinuationHandler].
typedef Result<T> ContinuationCallback<T>(Context context);

/// Handler function for the [ContinuationParser].
typedef Result<T> ContinuationHandler<T>(
    ContinuationCallback<T> continuation, Context context);

/// Continuation parser that when activated captures a continuation function
/// and passes it together with the current context into the handler.
///
/// Handlers are not required to call the continuation, but can completely ignore
/// it, call it multiple times, and/or store it away for later use. Similarly
/// handlers can modify the current context and/or modify the returned result.
///
/// The following example shows a simple wrapper. Messages are printed before and
/// after the `digit()` parser is activated:
///
///     var wrapped = digit();
///     var parser = new ContinuationParser(wrapped, (continuation, context) {
///       print('Parser will be activated, the context is $context.');
///       var result = continuation(context);
///       print('Parser was activated, the result is $result.');
///       return result;
///     });
///
/// See [profile], [progress], and [trace] for more elaborate examples.
class ContinuationParser<T> extends DelegateParser<T> {
  final ContinuationHandler<T> handler;

  ContinuationParser(Parser<T> delegate, this.handler) : super(delegate);

  @override
  Result<T> parseOn(Context context) => handler(super.parseOn, context);

  @override
  ContinuationParser<T> copy() => ContinuationParser<T>(delegate, handler);

  @override
  bool hasEqualProperties(ContinuationParser<T> other) =>
      super.hasEqualProperties(other) && handler == other.handler;
}
