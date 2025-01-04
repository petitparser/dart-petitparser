import 'dart:typed_data';

import 'package:collection/collection.dart' show ListEquality;

import '../predicate.dart';
import 'range.dart';

class RangesCharPredicate extends CharacterPredicate {
  factory RangesCharPredicate.fromRanges(Iterable<RangeCharPredicate> ranges) {
    final flattened = Uint32List(size(ranges));
    var i = 0;
    for (final range in ranges) {
      flattened[i++] = range.start;
      flattened[i++] = range.stop;
    }
    return RangesCharPredicate(flattened);
  }

  const RangesCharPredicate(this.ranges);

  final Uint32List ranges;

  @override
  bool test(int value) {
    var min = 0;
    var max = ranges.length - 2;
    while (min <= max) {
      final mid = (min + ((max - min) >> 1)) & ~1;
      if (ranges[mid] <= value && value <= ranges[mid + 1]) {
        return true;
      } else if (value < ranges[mid]) {
        max = mid - 2;
      } else {
        min = mid + 2;
      }
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is RangesCharPredicate &&
      _listEquality.equals(ranges, other.ranges);

  @override
  int get hashCode => _listEquality.hash(ranges);

  @override
  String toString() => '${super.toString()}($ranges)';

  static int size(Iterable<RangeCharPredicate> ranges) => 2 * ranges.length;
}

const _listEquality = ListEquality<int>();
