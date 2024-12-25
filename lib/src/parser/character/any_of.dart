import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'internal/code.dart';
import 'internal/optimize.dart';

/// Returns a parser that accepts any of the specified characters.
@useResult
Parser<String> anyOf(String chars, {String? message, bool unicode = false}) =>
    CharacterParser(
        optimizedString(chars, unicode: unicode),
        message ??
            'any of "${toReadableString(chars, unicode: unicode)}" expected',
        unicode: unicode);
