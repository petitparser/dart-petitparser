import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../predicate.dart';
import 'range.dart';

class RangesCharPredicate extends CharacterPredicate {
  RangesCharPredicate.fromRanges(List<RangeCharPredicate> ranges)
      : this(
          Uint32List.fromList(ranges.map((range) => range.start).toList()),
          Uint32List.fromList(ranges.map((range) => range.stop).toList()),
        );

  const RangesCharPredicate(this.starts, this.stops)
      : assert(starts.length == stops.length);

  final List<int> starts;
  final List<int> stops;

  @override
  bool test(int value) {
    var min = 0;
    var max = starts.length;
    while (min < max) {
      final mid = min + ((max - min) >> 1);
      final comp = starts[mid] - value;
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

  @override
  bool operator ==(Object other) =>
      other is RangesCharPredicate &&
      _listEquality.equals(starts, other.starts) &&
      _listEquality.equals(stops, other.stops);

  @override
  int get hashCode => _listEquality.hash(starts) ^ _listEquality.hash(stops);

  @override
  String toString() => '${super.toString()}($starts, $stops)';
}

const _listEquality = ListEquality<int>();
