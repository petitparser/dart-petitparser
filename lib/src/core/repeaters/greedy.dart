library petitparser.core.repeaters.greedy;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/limited.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// A greedy repeating parser, commonly seen in regular expression implementations. It
/// aggressively consumes as much input as possible and then backtracks to meet the
/// 'limit' condition.
class GreedyRepeatingParser extends LimitedRepeatingParser {
  GreedyRepeatingParser(Parser parser, Parser limit, int min, int max)
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
    List<Context> contexts = <Context>[current];
    while (max == unbounded || elements.length < max) {
      var result = delegate.parseOn(current);
      if (result.isFailure) {
        break;
      }
      elements.add(result.value);
      contexts.add(current = result);
    }
    for (;;) {
      var limiter = limit.parseOn(contexts.last);
      if (limiter.isSuccess) {
        return contexts.last.success(elements);
      }
      if (elements.isEmpty) {
        return limiter;
      }
      contexts.removeLast();
      elements.removeLast();
      if (contexts.isEmpty) {
        return limiter;
      }
    }
  }

  @override
  Parser copy() => new GreedyRepeatingParser(delegate, limit, min, max);
}
