import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/annotations.dart';
import '../character/whitespace.dart';
import '../combinator/delegate.dart';
import '../utils/sequential.dart';

extension TrimmingParserExtension<R> on Parser<R> {
  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns the result of the receiver.
  /// The optional arguments are parsers that consume the excess input. By
  /// default `whitespace()` is used. Up to two arguments can be provided to
  /// have different parsers on the [left] and [right] side.
  ///
  /// For example, the parser `letter().plus().trim()` returns `['a', 'b']`
  /// for the input `' ab\n'` and consumes the complete input string.
  @useResult
  Parser<R> trim([Parser<void>? left, Parser<void>? right]) =>
      TrimmingParser<R>(this, left ??= whitespace(), right ??= left);
}

/// A parser that silently consumes input of another parser around
/// its delegate.
class TrimmingParser<R> extends DelegateParser<R, R>
    implements SequentialParser {
  TrimmingParser(super.delegate, this.before, this.after);

  /// Parser that consumes input before the delegate.
  Parser<void> before;

  /// Parser that consumes input after the delegate.
  Parser<void> after;

  @override
  void parseOn(Context context) {
    if (context.isSkip) {
      _trim(before, context);
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      _trim(after, context);
    } else {
      context.isSkip = true;
      _trim(before, context);
      context.isSkip = false;
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      final value = context.value;
      context.isSkip = true;
      _trim(after, context);
      context.isSkip = false;
      context.value = value;
    }
  }

  @inlineVm
  @inlineJs
  void _trim(Parser parser, Context context) {
    for (;;) {
      final position = context.position;
      parser.parseOn(context);
      if (!context.isSuccess) {
        context.isSuccess = true;
        context.position = position;
        break;
      }
    }
  }

  @override
  TrimmingParser<R> copy() => TrimmingParser<R>(delegate, before, after);

  @override
  List<Parser> get children => [before, delegate, after];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (before == source) {
      before = target;
    }
    if (after == source) {
      after = target;
    }
  }
}
