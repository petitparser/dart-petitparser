import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../utils/failure_joiner.dart';
import 'list.dart';

extension ChoiceParserExtension on Parser {
  /// Returns a parser that accepts the receiver or [other]. The resulting
  /// parser returns the parse result of the receiver, if the receiver fails
  /// it returns the parse result of [other] (exclusive ordered choice).
  ///
  /// An optional [failureJoiner] can be specified that determines which
  /// [Failure] to return in case both parsers fail. By default the last
  /// failure is returned [selectLast], but [selectFarthest] is another
  /// common choice that usually gives better error messages.
  ///
  /// For example, the parser `letter().or(digit())` accepts a letter or a
  /// digit. An example where the order matters is the following choice between
  /// overlapping parsers: `letter().or(char('a'))`. In the example the parser
  /// `char('a')` will never be activated, because the input is always consumed
  /// `letter()`. This can be problematic if the author intended to attach a
  /// production action to `char('a')`.
  ///
  /// Due to https://github.com/dart-lang/language/issues/1557 the resulting
  /// parser cannot be properly typed. Please use [ChoiceIterableExtension]
  /// as a workaround: `[first, second].toChoiceParser()`.
  @useResult
  ChoiceParser<dynamic> or(Parser other, {FailureJoiner? failureJoiner}) =>
      switch (this) {
        ChoiceParser(
          children: final children,
          failureJoiner: final thisFailureJoiner
        ) =>
          [
            ...children,
            other
          ].toChoiceParser(failureJoiner: failureJoiner ?? thisFailureJoiner),
        _ => [this, other].toChoiceParser(failureJoiner: failureJoiner)
      };

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [or] for details.
  @useResult
  ChoiceParser<dynamic> operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<R> on Iterable<Parser<R>> {
  /// Converts the parser in this iterable to a choice of parsers.
  ChoiceParser<R> toChoiceParser({FailureJoiner? failureJoiner}) =>
      ChoiceParser<R>(this, failureJoiner: failureJoiner);
}

/// A parser that uses the first parser that succeeds.
class ChoiceParser<R> extends ListParser<R, R> {
  ChoiceParser(super.children, {FailureJoiner? failureJoiner})
      : assert(children.isNotEmpty, 'Choice parser cannot be empty'),
        failureJoiner = failureJoiner ?? selectLast;

  /// Strategy to join multiple parse errors.
  final FailureJoiner failureJoiner;

  @override
  Result<R> parseOn(Context context) {
    // Check the first choice:
    final result = children[0].parseOn(context);
    if (result is! Failure) return result;
    var failure = result;
    // Check all other choices:
    for (var i = 1; i < children.length; i++) {
      final result = children[i].parseOn(context);
      if (result is! Failure) return result;
      failure = failureJoiner(failure, result);
    }
    return failure;
  }

  @override
  int fastParseOn(String buffer, int position) {
    var result = -1;
    for (var i = 0; i < children.length; i++) {
      result = children[i].fastParseOn(buffer, position);
      if (result >= 0) return result;
    }
    return result;
  }

  @override
  bool hasEqualProperties(ChoiceParser<R> other) =>
      super.hasEqualProperties(other) && failureJoiner == other.failureJoiner;

  @override
  ChoiceParser<R> copy() =>
      ChoiceParser<R>(children, failureJoiner: failureJoiner);
}
