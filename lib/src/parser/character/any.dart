import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/single_character.dart';
import '../predicate/unicode_character.dart';
import 'internal/constant.dart';

/// Returns a parser that accepts any character (UTF-16 code unit).
///
/// For example, `any()` succeeds and consumes any given letter. It only
/// fails for an empty input.
@useResult
Parser<String> any([String message = 'input expected']) =>
    SingleCharacterParser(const ConstantCharPredicate(true), message);

/// Returns a parser that accepts any character (Unicode code-point).
///
/// For example, `any()` succeeds and consumes any given unicode letter. It
/// only fails for an empty input.
@useResult
Parser<String> anyUnicode([String message = 'input expected']) =>
    UnicodeCharacterParser(const ConstantCharPredicate(true), message);
