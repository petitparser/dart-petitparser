import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicates/digit.dart';

/// Returns a parser that accepts any digit character. The accepted input is
/// equivalent to the character-set `0-9`.
@useResult
Parser<String> digit({String message = 'digit expected'}) =>
    CharacterParser(const DigitCharPredicate(), message);
