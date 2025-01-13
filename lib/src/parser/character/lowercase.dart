import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicate/lowercase.dart';

/// Returns a parser that accepts any lowercase character. The accepted input is
/// equivalent to the character-set `a-z`.
@useResult
Parser<String> lowercase([String message = 'lowercase letter expected']) =>
    SingleCharacterParser(const LowercaseCharPredicate(), message);
