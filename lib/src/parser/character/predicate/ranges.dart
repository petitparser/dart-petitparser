import 'dart:typed_data';

import 'package:collection/collection.dart' show ListEquality;

import '../../../shared/pragma.dart';
import '../predicate.dart';
import 'range.dart';

class RangesCharPredicate extends CharacterPredicate {
  RangesCharPredicate.fromRanges(Iterable<RangeCharPredicate> ranges)
      : ranges = Uint32List(size(ranges)) {
    var i = 0;
    for (final range in ranges) {
      this.ranges[i++] = range.start;
      this.ranges[i++] = range.stop;
    }
  }

  const RangesCharPredicate(this.ranges);

  final Uint32List ranges;

  @override
  @noBoundsChecks
  bool test(int charCode) {
    var min = 0;
    var max = ranges.length - 2;
    while (min <= max) {
      final mid = (min + ((max - min) >> 1)) & ~1;
      if (ranges[mid] <= charCode && charCode <= ranges[mid + 1]) {
        return true;
      } else if (charCode < ranges[mid]) {
        max = mid - 2;
      } else {
        min = mid + 2;
      }
    }
    return false;
  }

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is RangesCharPredicate &&
      _listEquality.equals(ranges, other.ranges);

  @override
  String toString() => '${super.toString()}($ranges)';

  static int size(Iterable<RangeCharPredicate> ranges) => 2 * ranges.length;
}

const _listEquality = ListEquality<int>();
