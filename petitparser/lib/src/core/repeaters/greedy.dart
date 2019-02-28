library petitparser.core.repeaters.greedy;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/limited.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// A greedy repeating parser, commonly seen in regular expression
/// implementations. It aggressively consumes as much input as possible and then
/// backtracks to meet the 'limit' condition.
class GreedyRepeatingParser<T> extends LimitedRepeatingParser<T> {
  GreedyRepeatingParser(Parser<T> parser, Parser limit, int min, int max)
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
    final contexts = <Context>[current];
    while (max == unbounded || elements.length < max) {
      final result = delegate.parseOn(current);
      if (result.isFailure) {
        break;
      }
      elements.add(result.value);
      contexts.add(current = result);
    }
    for (;;) {
      final limiter = limit.parseOn(contexts.last);
      if (limiter.isSuccess) {
        return contexts.last.success(elements);
      }
      if (elements.isEmpty) {
        return limiter.failure(limiter.message);
      }
      contexts.removeLast();
      elements.removeLast();
      if (contexts.isEmpty) {
        return limiter.failure(limiter.message);
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
    final positions = <int>[current];
    while (max == unbounded || count < max) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) {
        break;
      }
      positions.add(current = result);
      count++;
    }
    for (;;) {
      final limiter = limit.fastParseOn(buffer, positions.last);
      if (limiter >= 0) {
        return positions.last;
      }
      if (count == 0) {
        return -1;
      }
      positions.removeLast();
      count--;
      if (positions.isEmpty) {
        return -1;
      }
    }
  }

  @override
  GreedyRepeatingParser<T> copy() =>
      GreedyRepeatingParser<T>(delegate, limit, min, max);
}
