import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'internal/uppercase.dart';

/// Returns a parser that accepts any uppercase character. The accepted input is
/// equivalent to the character-set `A-Z`.
@useResult
Parser<String> uppercase({String message = 'uppercase letter expected'}) =>
    CharacterParser(const UppercaseCharPredicate(), message);
