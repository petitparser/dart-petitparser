import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'code.dart';
import 'not.dart';
import 'optimize.dart';

/// Returns a parser that accepts none of the specified characters.
@useResult
Parser<String> noneOf(String chars, [String? message]) => SingleCharacterParser(
    NotCharacterPredicate(optimizedString(chars)),
    message ?? 'none of "${toReadableString(chars)}" expected');
