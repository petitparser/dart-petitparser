import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts any of the specified characters.
@useResult
Parser<String> anyOf(String chars, {String? message}) => CharacterParser(
    optimizedString(chars),
    message ?? 'any of "${toReadableString(chars)}" expected');
