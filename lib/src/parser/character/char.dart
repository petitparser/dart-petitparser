import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'predicates/char.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts a specific character [value].
///
/// - [message] defines a custom error message.
/// - If [ignoreCase] is `true`, the character is matched in a case-insensitive
///   manner.
/// - If [unicode] is `true`, the character is matched using full unicode
///   character parsing (as opposed to UTF-16 code units).
@useResult
Parser<String> char(String value,
    {String? message, bool ignoreCase = false, bool unicode = false}) {
  final charCode = toCharCode(value, unicode: unicode);
  final predicate = ignoreCase
      ? optimizedString('${value.toLowerCase()}${value.toUpperCase()}',
          unicode: unicode)
      : SingleCharPredicate(charCode);
  message ??= '"${toReadableString(value, unicode: unicode)}"'
      '${ignoreCase ? ' (case-insensitive)' : ''} expected';
  return CharacterParser(predicate, message, unicode: unicode);
}

@useResult
@Deprecated('Use `char(value, message: message, ignoreCase: true)` instead')
Parser<String> charIgnoringCase(String value, [String? message]) =>
    char(value, message: message, ignoreCase: true);
