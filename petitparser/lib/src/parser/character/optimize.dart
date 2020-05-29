library petitparser.parser.character.optimize;

import 'char.dart';
import 'constant.dart';
import 'lookup.dart';
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
  // 1. Sort the ranges:
  final sortedRanges = List.of(ranges, growable: false);
  sortedRanges.sort((first, second) {
    return first.start != second.start
        ? first.start - second.start
        : first.stop - second.stop;
  });

  // 2. Merge adjacent or overlapping ranges:
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

  // 3. Build the best resulting predicates:
  final matchingCount = mergedRanges.fold(
      0, (current, range) => current + (range.stop - range.start + 1));
  if (matchingCount == 0) {
    return const ConstantCharPredicate(false);
  } else if (matchingCount - 1 == 0xffff) {
    return const ConstantCharPredicate(true);
  } else if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop
        ? SingleCharPredicate(mergedRanges[0].start)
        : mergedRanges[0];
  } else {
    final rangesSize = 2 * mergedRanges.length;
    final rangesPredicate = RangesCharPredicate(
        mergedRanges.length,
        mergedRanges.map((range) => range.start).toList(growable: false),
        mergedRanges.map((range) => range.stop).toList(growable: false));
    // Arbitrary trade-off: Do not create lookup tables larger than 0xff
    // elements, unless the range tables are larger.
    final lookupSize = mergedRanges.last.stop - mergedRanges.first.start;
    if (lookupSize <= 0xff || lookupSize <= rangesSize) {
      return LookupCharPredicate(
          mergedRanges.first.start, mergedRanges.last.stop, rangesPredicate);
    }
    return rangesPredicate;
  }
}
