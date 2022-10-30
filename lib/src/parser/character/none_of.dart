import 'package:meta/meta.dart';

import '../../core/parser.dart';
import 'code.dart';
import 'not.dart';
import 'optimize.dart';
import 'parser.dart';

/// Returns a parser that accepts none of the specified characters.
@useResult
Parser<String> noneOf(String chars, [String? message]) => CharacterParser(
    NotCharacterPredicate(optimizedString(chars)),
    message ?? 'none of "${toReadableString(chars)}" expected');
