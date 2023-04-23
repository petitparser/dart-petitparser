import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/result.dart';
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
      before != null || after != null
          ? SkipParser<R>(this, before, after)
          : this;
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
  Result<R> parseOn(Context context) {
    final beforeParser = before;
    if (beforeParser != null) {
      final beforeContext = beforeParser.parseOn(context);
      if (beforeContext.isFailure) {
        return beforeContext.failure(beforeContext.message);
      }
      context = beforeContext;
    }
    final resultContext = delegate.parseOn(context);
    if (resultContext.isFailure) {
      return resultContext;
    }
    context = resultContext;
    final afterParser = after;
    if (afterParser != null) {
      final afterContext = afterParser.parseOn(context);
      if (afterContext.isFailure) {
        return afterContext.failure(afterContext.message);
      }
      context = afterContext;
    }
    return context.success(resultContext.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = before?.fastParseOn(buffer, position) ?? position;
    if (position < 0) return -1;
    position = delegate.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = after?.fastParseOn(buffer, position) ?? position;
    return position;
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
