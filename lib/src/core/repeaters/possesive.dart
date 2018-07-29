library petitparser.core.repeaters.possessive;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/repeating.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// A greedy parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate.
class PossessiveRepeatingParser<T> extends RepeatingParser<T> {
  PossessiveRepeatingParser(Parser<T> parser, int min, int max)
      : super(parser, min, max);

  @override
  Result<List<T>> parseOn(Context context) {
    var current = context;
    var elements = <T>[];
    while (elements.length < min) {
      var result = delegate.parseOn(current);
      if (result.isFailure) {
        return result.failure(result.message);
      }
      elements.add(result.value);
      current = result;
    }
    while (max == unbounded || elements.length < max) {
      var result = delegate.parseOn(current);
      if (result.isFailure) {
        return current.success(elements);
      }
      elements.add(result.value);
      current = result;
    }
    return current.success(elements);
  }

  @override
  Parser<List<T>> copy() => PossessiveRepeatingParser(delegate, min, max);
}
