import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/range.dart';
import 'utils/code.dart';

/// Returns a parser that accepts any character in the range
/// between [start] and [stop].
@useResult
Parser<String> range(String start, String stop,
        {String? message, bool unicode = false}) =>
    CharacterParser(
        RangeCharPredicate(toCharCode(start, unicode: unicode),
            toCharCode(stop, unicode: unicode)),
        message ??
            '[${toReadableString(start, unicode: unicode)}-'
                '${toReadableString(stop, unicode: unicode)}] expected',
        unicode: unicode);
