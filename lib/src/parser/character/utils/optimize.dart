import '../predicate.dart';
import '../predicates/char.dart';
import '../predicates/constant.dart';
import '../predicates/lookup.dart';
import '../predicates/range.dart';

/// Creates an optimized character from a string.
CharacterPredicate optimizedString(String string, {required bool unicode}) =>
    optimizedRanges(
        (unicode ? string.runes : string.codeUnits)
            .map((value) => RangeCharPredicate(value, value)),
        unicode: unicode);

/// Creates an optimized predicate from a list of range predicates.
CharacterPredicate optimizedRanges(Iterable<RangeCharPredicate> ranges,
    {required bool unicode}) {
  // 1. Sort the ranges:
  final sortedRanges = List.of(ranges, growable: false);
  sortedRanges.sort((first, second) => first.start != second.start
      ? first.start - second.start
      : first.stop - second.stop);

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

  // 3. Build the best resulting predicate:
  final matchingCount = mergedRanges.fold<int>(
      0, (current, range) => current + (range.stop - range.start + 1));
  if (matchingCount == 0) {
    return const ConstantCharPredicate(false);
  } else if ((unicode && matchingCount - 1 == 0x10ffff) ||
      (!unicode && matchingCount - 1 == 0xffff)) {
    return const ConstantCharPredicate(true);
  } else if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop
        ? SingleCharPredicate(mergedRanges[0].start)
        : mergedRanges[0];
  } else {
    return LookupCharPredicate.fromRanges(mergedRanges);
  }
}
