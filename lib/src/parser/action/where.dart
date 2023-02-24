import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';
import '../combinator/delegate.dart';

extension WhereParserExtension<T> on Parser<T> {
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
  Parser<T> where(
    Predicate<T> predicate, {
    String? message,
    Callback<T, String>? messageBuilder,
  }) =>
      WhereParser<T>(
          this,
          predicate,
          messageBuilder ??
              (message == null
                  ? (value) => 'unexpected "$value"'
                  : (value) => message));
}

class WhereParser<T> extends DelegateParser<T, T> {
  WhereParser(super.parser, this.predicate, this.messageBuilder);

  final Predicate<T> predicate;
  final Callback<T, String> messageBuilder;

  @override
  void parseOn(Context context) {
    final position = context.position;
    delegate.parseOn(context);
    if (context.isSuccess && !predicate(context.value)) {
      context.isSuccess = false;
      context.position = position;
      context.message = messageBuilder(context.value);
    }
  }

  @override
  Parser<T> copy() => WhereParser<T>(delegate, predicate, messageBuilder);

  @override
  bool hasEqualProperties(WhereParser<T> other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      messageBuilder == other.messageBuilder;
}
