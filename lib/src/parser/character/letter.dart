import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicates/letter.dart';

/// Returns a parser that accepts any letter character (lowercase or uppercase).
/// The accepted input is equivalent to the character-set `a-zA-Z`.
@useResult
Parser<String> letter({String message = 'letter expected'}) =>
    CharacterParser(const LetterCharPredicate(), message);
