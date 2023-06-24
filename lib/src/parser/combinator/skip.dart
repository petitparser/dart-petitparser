import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
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
      before != null && after != null
          ? _BeforeAfterSkipParser<R>(this, before, after)
          : before != null
              ? _BeforeSkipParser<R>(this, before)
              : after != null
                  ? _AfterSkipParser<R>(this, after)
                  : this;
}

/// A parser that silently consumes input of another parser around
/// its delegate.
abstract class SkipParser<R> extends DelegateParser<R, R>
    implements SequentialParser {
  SkipParser(super.delegate);
}

/// A parser that silently consumes input of another parser before and after
/// its delegate.
class _BeforeAfterSkipParser<R> extends SkipParser<R> {
  _BeforeAfterSkipParser(super.delegate, this.before, this.after);

  Parser<void> before;
  Parser<void> after;

  @override
  Result<R> parseOn(Context context) {
    final beforeContext = before.parseOn(context);
    if (beforeContext.isFailure) {
      return beforeContext.failure(beforeContext.message);
    }
    context = beforeContext;
    final resultContext = delegate.parseOn(context);
    if (resultContext.isFailure) return resultContext;
    context = resultContext;
    final afterContext = after.parseOn(context);
    if (afterContext.isFailure) {
      return afterContext.failure(afterContext.message);
    }
    context = afterContext;
    return context.success(resultContext.value);
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
  SkipParser<R> copy() => _BeforeAfterSkipParser<R>(delegate, before, after);

  @override
  List<Parser> get children => [before, delegate, after];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (before == source) before = target;
    if (after == source) after = target;
  }
}

/// A parser that silently consumes input of another parser before its delegate.
class _BeforeSkipParser<R> extends SkipParser<R> {
  _BeforeSkipParser(super.delegate, this.before);

  Parser<void> before;

  @override
  Result<R> parseOn(Context context) {
    final beforeContext = before.parseOn(context);
    if (beforeContext.isFailure) {
      return beforeContext.failure(beforeContext.message);
    }
    context = beforeContext;
    final resultContext = delegate.parseOn(context);
    if (resultContext.isFailure) return resultContext;
    context = resultContext;
    return context.success(resultContext.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = before.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = delegate.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  SkipParser<R> copy() => _BeforeSkipParser<R>(delegate, before);

  @override
  List<Parser> get children => [before, delegate];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (before == source) before = target;
  }
}

/// A parser that silently consumes input of another parser after its delegate.
class _AfterSkipParser<R> extends SkipParser<R> {
  _AfterSkipParser(super.delegate, this.after);

  Parser<void> after;

  @override
  Result<R> parseOn(Context context) {
    final resultContext = delegate.parseOn(context);
    if (resultContext.isFailure) return resultContext;
    context = resultContext;
    final afterContext = after.parseOn(context);
    if (afterContext.isFailure) {
      return afterContext.failure(afterContext.message);
    }
    context = afterContext;
    return context.success(resultContext.value);
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = delegate.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return after.fastParseOn(buffer, position);
  }

  @override
  SkipParser<R> copy() => _AfterSkipParser<R>(delegate, after);

  @override
  List<Parser> get children => [delegate, after];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (after == source) after = target;
  }
}
