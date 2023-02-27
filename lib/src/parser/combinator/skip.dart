import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../utils/sequential.dart';
import 'delegate.dart';

extension SkipParserExtension<R> on Parser<R> {
  /// Returns a parser that consumes input [before] and [after] the receiver,
  /// but discards the parse results of [before] and [after] and only returns
  /// the result of the receiver.
  ///
  /// For example, the parser `digit().skip(char('['), char(']'))`
  /// returns `'3'` for the input `'[3]'`.
  @useResult
  Parser<R> skip({Parser<void>? before, Parser<void>? after}) =>
      before == null && after == null
          ? this
          : SkipParser<R>(this, before, after);
}

/// A parser that silently consumes input of another parser around
/// its delegate.
class SkipParser<R> extends DelegateParser<R, R> implements SequentialParser {
  SkipParser(super.delegate, this.before, this.after);

  /// Parser that consumes input before the delegate.
  Parser<void>? before;

  /// Parser that consumes input after the delegate.
  Parser<void>? after;

  @override
  void parseOn(Context context) {
    final beforeParser = before;
    if (beforeParser != null) {
      beforeParser.fastParseOn(context);
      if (!context.isSuccess) return;
    }
    delegate.parseOn(context);
    if (!context.isSuccess) return;
    final value = context.value;
    final afterParser = after;
    if (afterParser != null) {
      afterParser.fastParseOn(context);
      if (!context.isSuccess) return;
    }
    context.value = value;
  }

  @override
  void fastParseOn(Context context) {
    final beforeParser = before;
    if (beforeParser != null) {
      beforeParser.fastParseOn(context);
      if (!context.isSuccess) return;
    }
    delegate.fastParseOn(context);
    if (!context.isSuccess) return;
    final afterParser = after;
    if (afterParser != null) {
      afterParser.fastParseOn(context);
    }
  }

  @override
  SkipParser<R> copy() => SkipParser<R>(delegate, before, after);

  @override
  List<Parser> get children => [
        if (before != null) before!,
        delegate,
        if (after != null) after!,
      ];

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
