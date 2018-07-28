library petitparser.core.repeaters.lazy;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/limited.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// A lazy repeating parser, commonly seen in regular expression implementations. It
/// limits its consumption to meet the 'limit' condition as early as possible.
class LazyRepeatingParser extends LimitedRepeatingParser {
  LazyRepeatingParser(Parser parser, Parser limit, int min, int max)
      : super(parser, limit, min, max);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = [];
    while (elements.length < min) {
      var result = delegate.parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    for (;;) {
      var limiter = limit.parseOn(current);
      if (limiter.isSuccess) {
        return current.success(elements);
      } else {
        if (max != unbounded && elements.length >= max) {
          return limiter;
        }
        var result = delegate.parseOn(current);
        if (result.isFailure) {
          return limiter;
        }
        elements.add(result.value);
        current = result;
      }
    }
  }

  @override
  Parser copy() => LazyRepeatingParser(delegate, limit, min, max);
}
