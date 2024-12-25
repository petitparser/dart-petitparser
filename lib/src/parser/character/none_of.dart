import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'internal/code.dart';
import 'internal/not.dart';
import 'internal/optimize.dart';

/// Returns a parser that accepts none of the specified characters.
@useResult
Parser<String> noneOf(String chars, {String? message, bool unicode = false}) =>
    CharacterParser(
        NotCharacterPredicate(optimizedString(chars, unicode: unicode)),
        message ??
            'none of "${toReadableString(chars, unicode: unicode)}" expected',
        unicode: unicode);
