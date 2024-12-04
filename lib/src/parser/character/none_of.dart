import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import 'internal/code.dart';
import 'internal/not.dart';
import 'internal/optimize.dart';

/// Returns a parser that accepts none of the specified characters (UTF-16 code
/// units).
@useResult
Parser<String> noneOf(String chars, [String? message]) => SingleCharacterParser(
    NotCharacterPredicate(optimizedString(chars)),
    message ?? 'none of "${toReadableString(chars)}" expected');

/// Returns a parser that accepts none of the specified characters (Unicode
/// code-points).
@useResult
Parser<String> noneOfUnicode(String chars, [String? message]) =>
    SingleCharacterParser(
        NotCharacterPredicate(optimizedString(chars, unicode: true)),
        message ??
            'none of "${toReadableString(chars, unicode: true)}" expected');
