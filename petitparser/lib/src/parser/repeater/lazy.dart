library petitparser.parser.repeater.lazy;

import '../../context/context.dart';
import '../../context/result.dart';
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
  Parser<List<T>> starLazy(Parser limit) => repeatLazy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the [plus]
  /// operator. The [limit] is not consumed.
  ///
  /// For example, the parser `char('{') & any().plusLazy(char('}')) &
  /// char('}')` only consumes the part `'{abc}'` of `'{abc}def}'`.
  ///
  /// See [plusGreedy] for the greedy and less efficient variation of
  /// this combinator.
  Parser<List<T>> plusLazy(Parser limit) => repeatLazy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a lazy non-blind implementation
  /// of the [repeat] operator. The [limit] is not consumed.
  ///
  /// This is the more generic variation of the [starLazy] and [plusLazy]
  /// combinators.
  Parser<List<T>> repeatLazy(Parser limit, int min, int max) =>
      LazyRepeatingParser<T>(this, limit, min, max);
}

/// A lazy repeating parser, commonly seen in regular expression
/// implementations. It limits its consumption to meet the 'limit' condition as
/// early as possible.
class LazyRepeatingParser<T> extends LimitedRepeatingParser<T> {
  LazyRepeatingParser(Parser<T> parser, Parser limit, int min, int max)
      : super(parser, limit, min, max);

  @override
  Result<List<T>> parseOn(Context context) {
    var current = context;
    final elements = <T>[];
    while (elements.length < min) {
      final result = delegate.parseOn(current);
      if (result.isFailure) {
        return result.failure(result.message);
      }
      elements.add(result.value);
      current = result;
    }
    for (;;) {
      final limiter = limit.parseOn(current);
      if (limiter.isSuccess) {
        return current.success(elements);
      } else {
        if (max != unbounded && elements.length >= max) {
          return limiter.failure(limiter.message);
        }
        final result = delegate.parseOn(current);
        if (result.isFailure) {
          return limiter.failure(limiter.message);
        }
        elements.add(result.value);
        current = result;
      }
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    var count = 0;
    var current = position;
    while (count < min) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) {
        return -1;
      }
      current = result;
      count++;
    }
    for (;;) {
      final limiter = limit.fastParseOn(buffer, current);
      if (limiter >= 0) {
        return current;
      } else {
        if (max != unbounded && count >= max) {
          return -1;
        }
        final result = delegate.fastParseOn(buffer, current);
        if (result < 0) {
          return -1;
        }
        current = result;
        count++;
      }
    }
  }

  @override
  LazyRepeatingParser<T> copy() =>
      LazyRepeatingParser<T>(delegate, limit, min, max);
}
