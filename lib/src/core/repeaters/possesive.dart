library petitparser.core.repeaters.possessive;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/repeating.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// A greedy parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate.
class PossessiveRepeatingParser extends RepeatingParser {
  PossessiveRepeatingParser(Parser parser, int min, int max) : super(parser, min, max);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < min) {
      var result = delegate.parseOn(current);
      if (result.isFailure) {
        return result;
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
  Parser copy() => new PossessiveRepeatingParser(delegate, min, max);
}
