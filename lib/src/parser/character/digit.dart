import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import 'internal/digit.dart';

/// Returns a parser that accepts any digit character. The accepted input is
/// equivalent to the character-set `0-9`.
@useResult
Parser<String> digit([String message = 'digit expected']) =>
    SingleCharacterParser(const DigitCharPredicate(), message);
