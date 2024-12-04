import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import 'internal/whitespace.dart';

/// Returns a parser that accepts any whitespace character (UTF-16 code unit).
@useResult
Parser<String> whitespace([String message = 'whitespace expected']) =>
    SingleCharacterParser(const WhitespaceCharPredicate(), message);
