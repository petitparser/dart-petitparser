library petitparser.core.characters.optimize;

import 'char.dart';
import 'predicate.dart';
import 'range.dart';
import 'ranges.dart';

/// Creates an optimized character from a string.
CharacterPredicate optimizedString(String string) {
  return optimizedRanges(
      string.codeUnits.map((value) => RangeCharPredicate(value, value)));
}

/// Creates an optimized predicate from a list of range predicates.
CharacterPredicate optimizedRanges(Iterable<RangeCharPredicate> ranges) {
  // 1. sort the ranges
  final sortedRanges = List.of(ranges, growable: false);
  sortedRanges.sort((first, second) {
    return first.start != second.start
        ? first.start - second.start
        : first.stop - second.stop;
  });

  // 2. merge adjacent or overlapping ranges
  final mergedRanges = <RangeCharPredicate>[];
  for (final thisRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(thisRange);
    } else {
      final lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= thisRange.start) {
        final characterRange =
            RangeCharPredicate(lastRange.start, thisRange.stop);
        mergedRanges[mergedRanges.length - 1] = characterRange;
      } else {
        mergedRanges.add(thisRange);
      }
    }
  }

  // 3. build the best resulting predicates
  if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop
        ? SingleCharPredicate(mergedRanges[0].start)
        : mergedRanges[0];
  } else {
    return RangesCharPredicate(
        mergedRanges.length,
        mergedRanges.map((range) => range.start).toList(growable: false),
        mergedRanges.map((range) => range.stop).toList(growable: false));
  }
}
