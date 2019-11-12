library petitparser.core.repeaters.lazy;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'limited.dart';
import 'unbounded.dart';

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
