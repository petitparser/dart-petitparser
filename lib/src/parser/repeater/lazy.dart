import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import 'greedy.dart';
import 'limited.dart';
import 'possessive.dart';
import 'unbounded.dart';

extension LazyRepeatingParserExtension<R> on Parser<R> {
  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [PossessiveRepeatingParserExtension.star] operator. The [limit] is not
  /// consumed.
  ///
  /// For example, the parser `char('{') & any().starLazy(char('}')) &
  /// char('}')` only consumes the part `'{abc}'` of `'{abc}def}'`.
  ///
  /// See [GreedyRepeatingParserExtension.starGreedy] for the greedy and less
  /// efficient variation of this combinator.
  @useResult
  Parser<List<R>> starLazy(Parser<void> limit) =>
      repeatLazy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [PossessiveRepeatingParserExtension.plus] operator. The [limit] is not
  /// consumed.
  ///
  /// For example, the parser `char('{') & any().plusLazy(char('}')) &
  /// char('}')` only consumes the part `'{abc}'` of `'{abc}def}'`.
  ///
  /// See [GreedyRepeatingParserExtension.plusGreedy] for the greedy and less
  /// efficient variation of this combinator.
  @useResult
  Parser<List<R>> plusLazy(Parser<void> limit) =>
      repeatLazy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a lazy non-blind implementation
  /// of the [PossessiveRepeatingParserExtension.repeat] operator. The [limit]
  /// is not consumed.
  ///
  /// This is the more generic variation of the [starLazy] and [plusLazy]
  /// combinators.
  @useResult
  Parser<List<R>> repeatLazy(Parser<void> limit, int min, int max) =>
      LazyRepeatingParser<R>(this, limit, min, max);
}

/// A lazy repeating parser, commonly seen in regular expression
/// implementations. It limits its consumption to meet the 'limit' condition as
/// early as possible.
class LazyRepeatingParser<R> extends LimitedRepeatingParser<R> {
  LazyRepeatingParser(super.parser, super.limit, super.min, super.max);

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
    for (;;) {
      final limiter = limit.parseOn(current);
      if (limiter is Failure) {
        if (elements.length >= max) return limiter;
        final result = delegate.parseOn(current);
        if (result is Failure) return limiter;
        elements.add(result.value);
        current = result;
      } else {
        return current.success(elements);
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
    for (;;) {
      final limiter = limit.fastParseOn(buffer, current);
      if (limiter < 0) {
        if (count >= max) return -1;
        final result = delegate.fastParseOn(buffer, current);
        if (result < 0) return -1;
        current = result;
        count++;
      } else {
        return current;
      }
    }
  }

  @override
  LazyRepeatingParser<R> copy() =>
      LazyRepeatingParser<R>(delegate, limit, min, max);
}
