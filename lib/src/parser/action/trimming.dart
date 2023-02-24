import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/annotations.dart';
import '../character/whitespace.dart';
import '../combinator/delegate.dart';
import '../utils/sequential.dart';

extension TrimmingParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns the result of the receiver.
  /// The optional arguments are parsers that consume the excess input. By
  /// default `whitespace()` is used. Up to two arguments can be provided to
  /// have different parsers on the [left] and [right] side.
  ///
  /// For example, the parser `letter().plus().trim()` returns `['a', 'b']`
  /// for the input `' ab\n'` and consumes the complete input string.
  @useResult
  Parser<T> trim([Parser<void>? left, Parser<void>? right]) =>
      TrimmingParser<T>(this, left ??= whitespace(), right ??= left);
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
    _trim(before, context);
    delegate.parseOn(context);
    if (context.isSuccess) {
      final value = context.value;
      _trim(after, context);
      context.isSuccess = true;
      context.value = value;
      return;
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
  List<Parser> get children => [delegate, before, after];

  @override
  void replace(covariant Parser source, covariant Parser target) {
    super.replace(source, target);
    if (before == source) {
      before = target;
    }
    if (after == source) {
      after = target;
    }
  }
}
