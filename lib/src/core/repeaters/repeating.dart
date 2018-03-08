library petitparser.core.repeaters.repeating;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';

/// An abstract parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate.
abstract class RepeatingParser extends DelegateParser {
  final int min;
  final int max;

  RepeatingParser(Parser parser, this.min, this.max) : super(parser) {
    if (min < 0) {
      throw new ArgumentError(
          'Minimum repetitions must be positive, but got $min.');
    }
    if (max != unbounded && max < min) {
      throw new ArgumentError(
          'Maximum repetitions must be larger than $min, but got $max.');
    }
  }

  @override
  String toString() =>
      '${super.toString()}[$min..${max == unbounded ? '*' : max}]';

  @override
  bool hasEqualProperties(Parser other) {
    return other is RepeatingParser &&
        super.hasEqualProperties(other) &&
        min == other.min &&
        max == other.max;
  }
}
