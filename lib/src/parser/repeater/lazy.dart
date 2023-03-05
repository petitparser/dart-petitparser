import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import 'greedy.dart';
import 'limited.dart';
import 'possessive.dart';
import 'unbounded.dart';

extension LazyRepeatingParserExtension<T> on Parser<T> {
  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the [star]
  /// operator. The [limit] is not consumed.
  ///
  /// For example, the parser `char('{') & any().starLazy(char('}')) &
  /// char('}')` only consumes the part `'{abc}'` of `'{abc}def}'`.
  ///
  /// See [starGreedy] for the greedy and less efficient variation of
  /// this combinator.
  @useResult
  Parser<List<T>> starLazy(Parser<void> limit) =>
      repeatLazy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the [plus]
  /// operator. The [limit] is not consumed.
  ///
  /// For example, the parser `char('{') & any().plusLazy(char('}')) &
  /// char('}')` only consumes the part `'{abc}'` of `'{abc}def}'`.
  ///
  /// See [plusGreedy] for the greedy and less efficient variation of
  /// this combinator.
  @useResult
  Parser<List<T>> plusLazy(Parser<void> limit) =>
      repeatLazy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a lazy non-blind implementation
  /// of the [repeat] operator. The [limit] is not consumed.
  ///
  /// This is the more generic variation of the [starLazy] and [plusLazy]
  /// combinators.
  @useResult
  Parser<List<T>> repeatLazy(Parser<void> limit, int min, int max) =>
      LazyRepeatingParser<T>(this, limit, min, max);
}

/// A lazy repeating parser, commonly seen in regular expression
/// implementations. It limits its consumption to meet the 'limit' condition as
/// early as possible.
class LazyRepeatingParser<R> extends LimitedRepeatingParser<R> {
  LazyRepeatingParser(super.parser, super.limit, super.min, super.max);

  @override
  void parseOn(Context context) {
    final elements = <R>[];
    while (elements.length < min) {
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      elements.add(context.value);
    }
    final isCut = context.isCut;
    for (;;) {
      final position = context.position;
      context.isCut = false;
      limit.parseOn(context);
      if (context.isSuccess) {
        context.position = position;
        context.value = elements;
        context.isCut |= isCut;
        return;
      } else if (context.isCut || elements.length >= max) {
        context.isCut |= isCut;
        return;
      }
      final limitPosition = context.position;
      final limitMessage = context.message;
      context.position = position;
      context.isCut = false;
      delegate.parseOn(context);
      if (context.isSuccess) {
        elements.add(context.value);
      } else if (context.isCut) {
        return;
      } else {
        context.position = limitPosition;
        context.message = limitMessage;
        context.isCut |= isCut;
        return;
      }
    }
  }

  @override
  void fastParseOn(Context context) {
    var count = 0;
    while (count < min) {
      delegate.fastParseOn(context);
      if (!context.isSuccess) return;
      count++;
    }
    final isCut = context.isCut;
    for (;;) {
      final position = context.position;
      context.isCut = false;
      limit.fastParseOn(context);
      if (context.isSuccess) {
        context.position = position;
        context.isCut |= isCut;
        return;
      } else if (context.isCut || count >= max) {
        context.isCut |= isCut;
        return;
      }
      final limitPosition = context.position;
      final limitMessage = context.message;
      context.position = position;
      context.isCut = false;
      delegate.fastParseOn(context);
      if (context.isSuccess) {
        count++;
      } else if (context.isCut) {
        return;
      } else {
        context.position = limitPosition;
        context.message = limitMessage;
        context.isCut |= isCut;
        return;
      }
    }
  }

  @override
  LazyRepeatingParser<R> copy() =>
      LazyRepeatingParser<R>(delegate, limit, min, max);
}
