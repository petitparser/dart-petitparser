import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../predicate/character.dart';
import 'utils/code.dart';
import 'utils/optimize.dart';

/// Returns a parser that accepts any of the specified characters in [value].
@useResult
Parser<String> anyOf(String value,
    {String? message, bool ignoreCase = false, bool unicode = false}) {
  final predicate =
      optimizedString(value, ignoreCase: ignoreCase, unicode: unicode);
  message ??= 'any of "${toReadableString(value, unicode: unicode)}"'
      '${ignoreCase ? ' (case-insensitive)' : ''} expected';
  return CharacterParser(predicate, message, unicode: unicode);
}
