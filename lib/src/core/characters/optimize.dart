library petitparser.core.characters.optimize;

import 'package:petitparser/src/core/characters/char.dart';
import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/characters/range.dart';
import 'package:petitparser/src/core/characters/ranges.dart';

CharacterPredicate optimizedString(String string) {
  return optimizedRanges(string.codeUnits.map((value) => new RangeCharPredicate(value, value)));
}

CharacterPredicate optimizedRanges(Iterable ranges) {
  // 1. sort the ranges
  List<RangeCharPredicate> sortedRanges = new List.from(ranges, growable: false);
  sortedRanges.sort((first, second) {
    return first.start != second.start ? first.start - second.start : first.stop - second.stop;
  });

  // 2. merge adjacent or overlapping ranges
  List<RangeCharPredicate> mergedRanges = [];
  for (var thisRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(thisRange);
    } else {
      var lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= thisRange.start) {
        var characterRange = new RangeCharPredicate(lastRange.start, thisRange.stop);
        mergedRanges[mergedRanges.length - 1] = characterRange;
      } else {
        mergedRanges.add(thisRange);
      }
    }
  }

  // 3. build the best resulting predicates
  if (mergedRanges.length == 1) {
    return mergedRanges[0].start == mergedRanges[0].stop
        ? new SingleCharPredicate(mergedRanges[0].start)
        : mergedRanges[0];
  } else {
    return new RangesCharPredicate(
        mergedRanges.length,
        mergedRanges.map((range) => range.start).toList(growable: false),
        mergedRanges.map((range) => range.stop).toList(growable: false));
  }
}
