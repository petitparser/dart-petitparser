import 'package:collection/collection.dart' show ListEquality;

import '../predicate.dart';

class RangesCharPredicate extends CharacterPredicate {
  const RangesCharPredicate(this.length, this.starts, this.stops);

  final int length;
  final List<int> starts;
  final List<int> stops;

  @override
  bool test(int charCode) {
    var min = 0;
    var max = length;
    while (min < max) {
      final mid = min + ((max - min) >> 1);
      final comp = starts[mid] - charCode;
      if (comp == 0) {
        return true;
      } else if (comp < 0) {
        min = mid + 1;
      } else {
        max = mid;
      }
    }
    return 0 < min && charCode <= stops[min - 1];
  }

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangesCharPredicate &&
      length == other.length &&
      _listEquality.equals(starts, other.starts) &&
      _listEquality.equals(stops, other.stops);

  @override
  String toString() => '${super.toString()}($length, $starts, $stops)';
}

const _listEquality = ListEquality<int>();
