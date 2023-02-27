import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension WhereParserExtension<R> on Parser<R> {
  /// Returns a parser that evaluates the [predicate] with the successful
  /// parse result. If the predicate returns `true` the parser proceeds with
  /// the parse result, otherwise a parse failure is created using either
  /// the provided error [message], or by calling the [messageBuilder] with
  /// the parsed result.
  ///
  /// The following example parses two characters, but only succeeds if they
  /// are equal:
  ///
  ///     final inner = any() & any();
  ///     final parser = inner.where(
  ///         (value) => value[0] == value[1],
  ///         message: 'characters do not match');
  ///     parser.parse('aa');   // ==> Success: ['a', 'a']
  ///     parser.parse('ab');   // ==> Failure: characters do not match
  ///
  @useResult
  Parser<R> where(
    Predicate<R> predicate, {
    String? message,
    Callback<R, String>? messageBuilder,
  }) =>
      WhereParser<R>(
          this,
          predicate,
          messageBuilder ??
              (message == null
                  ? (value) => 'unexpected "$value"'
                  : (value) => message));
}

class WhereParser<R> extends DelegateParser<R, R> {
  WhereParser(super.parser, this.predicate, this.messageBuilder);

  final Predicate<R> predicate;
  final Callback<R, String> messageBuilder;

  @override
  void parseOn(Context context) {
    final position = context.position;
    final isSkip = context.isSkip;
    context.isSkip = false;
    delegate.parseOn(context);
    if (context.isSuccess) {
      final value = context.value as R;
      if (!predicate(value)) {
        context.isSuccess = false;
        context.position = position;
        context.message = messageBuilder(value);
      }
    }
    context.isSkip = isSkip;
  }

  @override
  WhereParser<R> copy() => WhereParser<R>(delegate, predicate, messageBuilder);

  @override
  bool hasEqualProperties(WhereParser<R> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      messageBuilder == other.messageBuilder;
}
