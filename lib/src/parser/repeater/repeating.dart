import '../combinator/delegate.dart';
import 'unbounded.dart';

/// An abstract parser that repeatedly parses between 'min' and 'max' instances
/// of its delegate.
abstract class RepeatingParser<T, R> extends DelegateParser<T, R> {
  RepeatingParser(super.parser, this.min, this.max)
      : assert(0 <= min, 'min must be at least 0, but got $min'),
        assert(min <= max, 'max must be at least $min, but got $max');

  /// The minimum amount of repetitions.
  final int min;

  /// The maximum amount of repetitions, or [unbounded].
  final int max;

  @override
  String toString() =>
      '${super.toString()}[$min..${max == unbounded ? '*' : max}]';

  @override
  bool hasEqualProperties(RepeatingParser<T, R> other) =>
      super.hasEqualProperties(other) && min == other.min && max == other.max;
}
