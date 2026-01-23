import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/word.dart';

/// Returns a parser that accepts any word character (lowercase, uppercase,
/// underscore, or digit). The accepted input is equivalent to the character-set
/// `a-zA-Z_0-9`.
///
/// For example, the parser `word()` accepts the character 'a' or '0'.
@useResult
Parser<String> word({String message = 'letter or digit expected'}) =>
    CharacterParser(const WordCharPredicate(), message);
