import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import 'lazy.dart';
import 'limited.dart';
import 'possessive.dart';
import 'unbounded.dart';

extension GreedyRepeatingParserExtension<R> on Parser<R> {
  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a greedy non-blind implementation of the
  /// [PossessiveRepeatingParserExtension.star] operator. The [limit] is not
  /// consumed.
  ///
  /// For example, the parser `char('{') & any().starGreedy(char('}')) &
  /// char('}')` consumes the complete input `'{abc}def}'` of `'{abc}def}'`.
  ///
  /// See [LazyRepeatingParserExtension.starLazy] for the lazy, more efficient,
  /// and generally preferred variation of this combinator.
  @useResult
  Parser<List<R>> starGreedy(Parser<void> limit) =>
      repeatGreedy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches [limit]. This is a greedy non-blind implementation of the
  /// [PossessiveRepeatingParserExtension.plus] operator. The [limit] is not
  /// consumed.
  ///
  /// For example, the parser `char('{') & any().plusGreedy(char('}')) &
  /// char('}')` consumes the complete input `'{abc}def}'` of `'{abc}def}'`.
  ///
  /// See [LazyRepeatingParserExtension.plusLazy] for the lazy, more efficient,
  /// and generally preferred variation of this combinator.
  @useResult
  Parser<List<R>> plusGreedy(Parser<void> limit) =>
      repeatGreedy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a greedy non-blind
  /// implementation of the [PossessiveRepeatingParserExtension.repeat]
  /// operator. The [limit] is not consumed.
  ///
  /// This is the more generic variation of the [starGreedy] and [plusGreedy]
  /// combinators.
  @useResult
  Parser<List<R>> repeatGreedy(Parser<void> limit, int min, int max) =>
      GreedyRepeatingParser<R>(this, limit, min, max);
}

/// A greedy repeating parser, commonly seen in regular expression
/// implementations. It aggressively consumes as much input as possible and then
/// backtracks to meet the 'limit' condition.
class GreedyRepeatingParser<R> extends LimitedRepeatingParser<R> {
  GreedyRepeatingParser(super.parser, super.limit, super.min, super.max);

  @override
  Result<List<R>> parseOn(Context context) {
    var current = context;
    final elements = <R>[];
    while (elements.length < min) {
      final result = delegate.parseOn(current);
      if (result is Failure) return result;
      elements.add(result.value);
      current = result;
    }
    final contexts = <Context>[current];
    while (elements.length < max) {
      final result = delegate.parseOn(current);
      if (result is Failure) break;
      elements.add(result.value);
      contexts.add(current = result);
    }
    for (;;) {
      final limiter = limit.parseOn(contexts.last);
      if (limiter is Failure) {
        if (elements.isEmpty) return limiter;
        contexts.removeLast();
        elements.removeLast();
        if (contexts.isEmpty) return limiter;
      } else {
        return contexts.last.success(elements);
      }
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    var count = 0;
    var current = position;
    while (count < min) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) return -1;
      current = result;
      count++;
    }
    final positions = <int>[current];
    while (count < max) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) break;
      positions.add(current = result);
      count++;
    }
    for (;;) {
      final limiter = limit.fastParseOn(buffer, positions.last);
      if (limiter < 0) {
        if (count == 0) return -1;
        positions.removeLast();
        count--;
        if (positions.isEmpty) return -1;
      } else {
        return positions.last;
      }
    }
  }

  @override
  GreedyRepeatingParser<R> copy() =>
      GreedyRepeatingParser<R>(delegate, limit, min, max);
}
