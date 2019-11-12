library petitparser.core.repeaters.possessive;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'repeating.dart';
import 'unbounded.dart';

/// A greedy parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate.
class PossessiveRepeatingParser<T> extends RepeatingParser<T> {
  PossessiveRepeatingParser(Parser<T> parser, int min, int max)
      : super(parser, min, max);

  @override
  Result<List<T>> parseOn(Context context) {
    final elements = <T>[];
    var current = context;
    while (elements.length < min) {
      final result = delegate.parseOn(current);
      if (result.isFailure) {
        return result.failure(result.message);
      }
      elements.add(result.value);
      current = result;
    }
    while (max == unbounded || elements.length < max) {
      final result = delegate.parseOn(current);
      if (result.isFailure) {
        return current.success(elements);
      }
      elements.add(result.value);
      current = result;
    }
    return current.success(elements);
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
    while (max == unbounded || count < max) {
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) {
        return current;
      }
      current = result;
      count++;
    }
    return current;
  }

  @override
  PossessiveRepeatingParser<T> copy() =>
      PossessiveRepeatingParser<T>(delegate, min, max);
}
