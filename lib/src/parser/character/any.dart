import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'internal/constant.dart';

/// Returns a parser that accepts any character.
///
/// For example, `any()` succeeds and consumes any given letter. It only
/// fails for an empty input.
@useResult
Parser<String> any({String message = 'input expected', bool unicode = false}) =>
    CharacterParser(const ConstantCharPredicate(true), message,
        unicode: unicode);
