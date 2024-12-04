import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'internal/code.dart';
import 'internal/optimize.dart';

/// Returns a parser that accepts any of the specified characters (UTF-16 code
/// units).
@useResult
Parser<String> anyOf(String chars, [String? message]) => SingleCharacterParser(
    optimizedString(chars),
    message ?? 'any of "${toReadableString(chars)}" expected');

/// Returns a parser that accepts any of the specified characters (Unicode
/// code-points).
@useResult
Parser<String> anyOfUnicode(String chars, [String? message]) =>
    UnicodeCharacterParser(
        optimizedString(chars, unicode: true),
        message ??
            'any of "${toReadableString(chars, unicode: true)}" expected');
