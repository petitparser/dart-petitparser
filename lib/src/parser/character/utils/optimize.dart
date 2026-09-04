import 'dart:math' as math;

import '../predicate.dart';
import '../predicate/char.dart';
import '../predicate/constant.dart';
import '../predicate/lookup.dart';
import '../predicate/range.dart';

/// Creates an optimized character from a string.
CharacterPredicate optimizedString(
  String string, {
  required bool unicode,
  bool ignoreCase = false,
}) {
  if (ignoreCase) string = '${string.toLowerCase()}${string.toUpperCase()}';
  return optimizedRanges(
    (unicode ? string.runes : string.codeUnits).map(
      (value) => RangeCharPredicate(value, value),
    ),
    unicode: unicode,
  );
}

/// Creates an optimized predicate from a list of range predicates.
CharacterPredicate optimizedRanges(
  Iterable<RangeCharPredicate> ranges, {
  required bool unicode,
}) {
  // 1. Sort the ranges:
  final sortedRanges = List.of(ranges, growable: false);
  sortedRanges.sort(
    (first, second) => first.start != second.start
        ? first.start - second.start
        : first.stop - second.stop,
  );

  // 2. Merge adjacent or overlapping ranges:
  final mergedRanges = <RangeCharPredicate>[];
  for (final thisRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(thisRange);
    } else {
      final lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= thisRange.start) {
        // The ranges are sorted by (start, stop), so `thisRange` can still be
        // fully contained in `lastRange`; take the larger stop, or the merge
        // would drop the characters between the two stops.
        final characterRange = RangeCharPredicate(
          lastRange.start,
          math.max(lastRange.stop, thisRange.stop),
        );
        mergedRanges[mergedRanges.length - 1] = characterRange;
      } else {
        mergedRanges.add(thisRange);
      }
    }
  }

  // 3. Build the best resulting predicate:
  if (mergedRanges.isEmpty) {
    return ConstantCharPredicate.none;
  } else if (mergedRanges.length == 1) {
    final range = mergedRanges[0];
    if (range.start <= 0 && range.stop >= (unicode ? 0x10ffff : 0xffff)) {
      return ConstantCharPredicate.any;
    } else if (range.start == range.stop) {
      return SingleCharPredicate(range.start);
    } else {
      return range;
    }
  } else {
    return LookupCharPredicate.fromRanges(mergedRanges);
  }
}
