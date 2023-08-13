import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../parser/misc/epsilon.dart';
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
      SkipParser<R>(this,
          before: before ?? epsilon(), after: after ?? epsilon());
}

/// A parser that silently consumes input of another parser before and after
/// its delegate.
class SkipParser<R> extends DelegateParser<R, R> implements SequentialParser {
  SkipParser(super.delegate, {required this.before, required this.after});

  Parser<void> before;
  Parser<void> after;

  @override
  Result<R> parseOn(Context context) {
    final beforeContext = before.parseOn(context);
    if (beforeContext is Failure) return beforeContext;
    final resultContext = delegate.parseOn(beforeContext);
    if (resultContext is Failure) return resultContext;
    final afterContext = after.parseOn(resultContext);
    if (afterContext is Failure) return afterContext;
    return afterContext.success(resultContext.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = before.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = delegate.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return after.fastParseOn(buffer, position);
  }

  @override
  SkipParser<R> copy() => SkipParser<R>(delegate, before: before, after: after);

  @override
  List<Parser> get children => [before, delegate, after];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (before == source) before = target;
    if (after == source) after = target;
  }
}
