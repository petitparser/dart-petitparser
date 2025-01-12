import 'dart:typed_data';

import 'package:collection/collection.dart' show ListEquality;

import '../../shared/annotations.dart';
import 'predicate.dart';
import 'range.dart';

class LookupCharPredicate implements CharacterPredicate {
  LookupCharPredicate(List<RangeCharPredicate> ranges)
      : start = ranges.first.start,
        stop = ranges.last.stop,
        bits = Uint32List(
            (ranges.last.stop - ranges.first.start + 1 + _offset) >> _shift) {
    for (final range in ranges) {
      for (var index = range.start - start;
          index <= range.stop - start;
          index++) {
        bits[index >> _shift] |= _mask[index & _offset];
      }
    }
  }

  final int start;
  final int stop;
  final Uint32List bits;

  @override
  bool test(int value) =>
      start <= value && value <= stop && _testBit(value - start);

  @inlineJs
  @inlineVm
  bool _testBit(int value) =>
      (bits[value >> _shift] & _mask[value & _offset]) != 0;

  @override
  bool isEqualTo(CharacterPredicate other) =>
      other is LookupCharPredicate &&
      start == other.start &&
      stop == other.stop &&
      _listEquality.equals(bits, other.bits);
}

const _listEquality = ListEquality<int>();

const _shift = 5;
const _offset = 31;
const _mask = <int>[
  1,
  2,
  4,
  8,
  16,
  32,
  64,
  128,
  256,
  512,
  1024,
  2048,
  4096,
  8192,
  16384,
  32768,
  65536,
  131072,
  262144,
  524288,
  1048576,
  2097152,
  4194304,
  8388608,
  16777216,
  33554432,
  67108864,
  134217728,
  268435456,
  536870912,
  1073741824,
  2147483648,
];
