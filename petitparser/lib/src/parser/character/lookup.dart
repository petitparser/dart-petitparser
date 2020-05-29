library petitparser.parser.character.lookup;

import 'predicate.dart';

class LookupCharPredicate implements CharacterPredicate {
  final int start;
  final int stop;
  final List<bool> table;

  LookupCharPredicate(this.start, this.stop, CharacterPredicate predicate)
      : assert(start != null && 0 <= start, 'start must be positive'),
        assert(stop != null && start <= stop, 'stop must be larger than start'),
        table = List.generate(
          stop - start + 1,
          (value) => predicate.test(value + start),
          growable: false,
        );

  @override
  bool test(int value) =>
      start <= value && value <= stop && table[value - start];

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is LookupCharPredicate &&
      other.start == start &&
      other.stop == stop &&
      other.table == table;
}
