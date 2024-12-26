import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicates/whitespace.dart';

/// Returns a parser that accepts any whitespace character.
@useResult
Parser<String> whitespace({String message = 'whitespace expected'}) =>
    CharacterParser(const WhitespaceCharPredicate(), message);
