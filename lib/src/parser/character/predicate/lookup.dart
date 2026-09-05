import 'dart:typed_data';

import 'package:collection/collection.dart' show ListEquality;

import '../../../shared/pragma.dart';
import '../predicate.dart';
import 'range.dart';

class LookupCharPredicate extends CharacterPredicate {
  new fromRanges(Iterable<RangeCharPredicate> ranges)
    : start = ranges.first.start,
      stop = ranges.last.stop,
      bits = Uint32List(size(ranges)) {
    for (final range in ranges) {
      for (
        var index = range.start - start;
        index <= range.stop - start;
        index++
      ) {
        bits[index >> _shift] |= 1 << (index & _offset);
      }
    }
  }

  const new(this.start, this.stop, this.bits);

  final int start;
  final int stop;
  final Uint32List bits;

  @override
  bool test(int charCode) =>
      start <= charCode && charCode <= stop && _testBit(charCode - start);

  @preferInline
  @noBoundsChecks
  bool _testBit(int value) =>
      (bits[value >> _shift] & (1 << (value & _offset))) != 0;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is LookupCharPredicate &&
      start == other.start &&
      stop == other.stop &&
      _listEquality.equals(bits, other.bits);

  @override
  String toString() => '${super.toString()}($start, $stop, $bits)';

  static int size(Iterable<RangeCharPredicate> ranges) =>
      (ranges.last.stop - ranges.first.start + _offset + 1) >> _shift;
}

const _listEquality = ListEquality<int>();

const _shift = 5;
const _offset = 31;
