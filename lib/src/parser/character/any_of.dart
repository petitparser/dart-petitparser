import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'code.dart';
import 'optimize.dart';

/// Returns a parser that accepts any of the specified characters.
@useResult
Parser<String> anyOf(String chars, [String? message]) => SingleCharacterParser(
    optimizedString(chars),
    message ?? 'any of "${toReadableString(chars)}" expected');
