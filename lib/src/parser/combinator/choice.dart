import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/failure.dart';
import '../../core/parser.dart';
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
  ChoiceParser or(Parser other) {
    final self = this;
    return self is ChoiceParser
        ? ChoiceParser([...self.children, other])
        : ChoiceParser([this, other]);
  }

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [or] for details.
  @useResult
  ChoiceParser operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<R> on Iterable<Parser<R>> {
  /// Converts the parser in this iterable to a choice of parsers.
  ChoiceParser<R> toChoiceParser() => ChoiceParser<R>(this);
}

/// A parser that uses the first parser that succeeds.
class ChoiceParser<R> extends ListParser<R, R> {
  ChoiceParser(super.children)
      : assert(children.isNotEmpty, 'Choice parser cannot be empty');

  @override
  void parseOn(Context context) {
    final position = context.position;
    final isCut = context.isCut;
    for (var i = 0; i < children.length; i++) {
      context.position = position;
      context.isCut = false;
      children[i].parseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      }
    }
  }

  @override
  void fastParseOn(Context context) {
    final position = context.position;
    final isCut = context.isCut;
    for (var i = 0; i < children.length; i++) {
      context.position = position;
      context.isCut = false;
      children[i].fastParseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      }
    }
  }

  @override
  bool hasEqualProperties(ChoiceParser<R> other) =>
      super.hasEqualProperties(other);

  @override
  ChoiceParser<R> copy() => ChoiceParser<R>(children);
}
