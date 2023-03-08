import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import 'lazy.dart';
import 'limited.dart';
import 'possessive.dart';
import 'unbounded.dart';

extension GreedyRepeatingParserExtension<T> on Parser<T> {
  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a greedy non-blind implementation of the
  /// [star] operator. The [limit] is not consumed.
  ///
  /// For example, the parser `char('{') & any().starGreedy(char('}')) &
  /// char('}')` consumes the complete input `'{abc}def}'` of `'{abc}def}'`.
  ///
  /// See [starLazy] for the lazy, more efficient, and generally preferred
  /// variation of this combinator.
  @useResult
  Parser<List<T>> starGreedy(Parser<void> limit) =>
      repeatGreedy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches [limit]. This is a greedy non-blind implementation of the [plus]
  /// operator. The [limit] is not consumed.
  ///
  /// For example, the parser `char('{') & any().plusGreedy(char('}')) &
  /// char('}')` consumes the complete input `'{abc}def}'` of `'{abc}def}'`.
  ///
  /// See [plusLazy] for the lazy, more efficient, and generally preferred
  /// variation of this combinator.
  @useResult
  Parser<List<T>> plusGreedy(Parser<void> limit) =>
      repeatGreedy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a greedy non-blind
  /// implementation of the [repeat] operator. The [limit] is not consumed.
  ///
  /// This is the more generic variation of the [starGreedy] and [plusGreedy]
  /// combinators.
  @useResult
  Parser<List<T>> repeatGreedy(Parser<void> limit, int min, int max) =>
      GreedyRepeatingParser<T>(this, limit, min, max);
}

/// A greedy repeating parser, commonly seen in regular expression
/// implementations. It aggressively consumes as much input as possible and then
/// backtracks to meet the 'limit' condition.
class GreedyRepeatingParser<R> extends LimitedRepeatingParser<R> {
  GreedyRepeatingParser(super.parser, super.limit, super.min, super.max);

  @override
  void fullParseOn(Context context) {
    final elements = <R>[];
    while (elements.length < min) {
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      elements.add(context.value);
    }
    final positions = <int>[context.position];
    while (elements.length < max) {
      delegate.parseOn(context);
      if (!context.isSuccess) break;
      elements.add(context.value);
      positions.add(context.position);
    }
    for (;;) {
      context.position = positions.last;
      limit.parseOn(context);
      if (context.isSuccess) {
        context.position = positions.last;
        context.value = elements;
        return;
      }
      if (elements.isEmpty) {
        return;
      }
      positions.removeLast();
      elements.removeLast();
      if (positions.isEmpty) {
        return;
      }
    }
  }

  @override
  void skipParseOn(Context context) {
    var count = 0;
    while (count < min) {
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      count++;
    }
    final positions = <int>[context.position];
    while (count < max) {
      delegate.parseOn(context);
      if (!context.isSuccess) break;
      count++;
      positions.add(context.position);
    }
    for (;;) {
      context.position = positions.last;
      limit.parseOn(context);
      if (context.isSuccess) {
        context.position = positions.last;
        return;
      }
      if (count == 0) {
        return;
      }
      positions.removeLast();
      count--;
      if (positions.isEmpty) {
        return;
      }
    }
  }

  @override
  GreedyRepeatingParser<R> copy() =>
      GreedyRepeatingParser<R>(delegate, limit, min, max);
}
