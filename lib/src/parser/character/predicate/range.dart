import '../predicate.dart';

class RangeCharPredicate extends CharacterPredicate {
  const RangeCharPredicate(this.start, this.stop)
      : assert(start <= stop, 'Invalid range character range: $start-$stop');

  final int start;
  final int stop;

  @override
  bool test(int charCode) => start <= charCode && charCode <= stop;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangeCharPredicate && start == other.start && stop == other.stop;

  @override
  String toString() => '${super.toString()}($start, $stop)';
}
