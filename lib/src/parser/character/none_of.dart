import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/not.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts none of the specified characters.
@useResult
Parser<String> noneOf(String chars, [String? message]) => SingleCharacterParser(
    NotCharacterPredicate(optimizedString(chars)),
    message ?? 'none of "${toReadableString(chars)}" expected');
