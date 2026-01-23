import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/letter.dart';

/// Returns a parser that accepts any letter character (lowercase or uppercase).
/// The accepted input is equivalent to the character-set `a-zA-Z`.
///
/// For example, the parser `letter()` accepts the character 'a' or 'A'.
@useResult
Parser<String> letter({String message = 'letter expected'}) =>
    CharacterParser(const LetterCharPredicate(), message);
