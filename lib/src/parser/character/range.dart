import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'internal/code.dart';
import 'internal/range.dart';

/// Returns a parser that accepts any character in the range
/// between [start] and [stop] (UTF-16 code unit).
@useResult
Parser<String> range(String start, String stop, [String? message]) =>
    SingleCharacterParser(
        RangeCharPredicate(toCharCode(start), toCharCode(stop)),
        message ??
            '[${toReadableString(start)}-${toReadableString(stop)}] expected');

/// Returns a parser that accepts any character in the range
/// between [start] and [stop] (Unicode code-point).
@useResult
Parser<String> rangeUnicode(String start, String stop, [String? message]) =>
    UnicodeCharacterParser(
        RangeCharPredicate(
            toCharCode(start, unicode: true), toCharCode(stop, unicode: true)),
        message ??
            '[${toReadableString(start, unicode: true)}-'
                '${toReadableString(stop, unicode: true)}] expected');
