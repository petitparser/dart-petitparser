import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/char.dart';
import '../character/pattern.dart';
import '../misc/epsilon.dart';
import 'string.dart';

extension ToParserStringExtension on String {
  /// Converts this string to a corresponding parser.
  ///
  /// - [message] defines a custom error message.
  /// - If [isPattern] is `true`, the string is considered a character-class
  ///   like the ones accepted by [pattern].
  /// - If [ignoreCase] is `true`, the string is matched in a case-insensitive
  ///   manner.
  /// - If [unicode] is `true`, the string is matched using full unicode
  ///   character decoding (as opposed to match UTF-16 code units).
  @useResult
  Parser<String> toParser(
      {String? message,
      bool isPattern = false,
      bool ignoreCase = false,
      @Deprecated('Use `ignoreCase` instead') bool caseInsensitive = false,
      bool unicode = false}) {
    // If this is a pattern, let the pattern handle everything.
    if (isPattern) {
      return pattern(this,
          message: message,
          ignoreCase: ignoreCase || caseInsensitive,
          unicode: unicode);
    }
    // Depending on length of the input create different parsers.
    return switch (unicode ? runes.length : codeUnits.length) {
      0 => epsilonWith<String>(this),
      1 => char(this,
          message: message,
          ignoreCase: ignoreCase || caseInsensitive,
          unicode: unicode),
      _ => string(this,
          message: message, ignoreCase: ignoreCase || caseInsensitive),
    };
  }
}
