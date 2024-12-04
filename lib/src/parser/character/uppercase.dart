import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import 'internal/uppercase.dart';

/// Returns a parser that accepts any uppercase character. The accepted input is
/// equivalent to the character-set `A-Z` (UTF-16 code unit).
@useResult
Parser<String> uppercase([String message = 'uppercase letter expected']) =>
    SingleCharacterParser(const UppercaseCharPredicate(), message);
