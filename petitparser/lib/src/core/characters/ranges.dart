library petitparser.core.characters.ranges;

import 'package:petitparser/src/core/characters/predicate.dart';

class RangesCharPredicate implements CharacterPredicate {
  final int length;
  final List<int> starts;
  final List<int> stops;

  const RangesCharPredicate(this.length, this.starts, this.stops);

  @override
  bool test(int value) {
    var min = 0;
    var max = length;
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      var comp = starts[mid] - value;
      if (comp == 0) {
        return true;
      } else if (comp < 0) {
        min = mid + 1;
      } else {
        max = mid;
      }
    }
    return 0 < min && value <= stops[min - 1];
  }
}
