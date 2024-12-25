import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/char.dart';
import '../character/pattern.dart';
import '../misc/epsilon.dart';
import 'predicate.dart';

extension PredicateStringExtension on String {
  /// Converts this string to a corresponding parser.
  ///
  /// - [message] defines a custom error message.
  /// - If [isPattern] is `true`, the string is considered a character-class
  ///   like the ones accepted by [pattern].
  /// - If [ignoreCase] is `true`, the string is matched in a case-insensitive
  ///   manner.
  /// - If [unicode] is `true`, the string is matched using full unicode
  ///   character parsing (as opposed to UTF-16 code units).
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
    return switch (unicode ? codeUnits.length : runes.length) {
      0 => epsilonWith<String>(''),
      1 => char(this,
          message: message,
          ignoreCase: ignoreCase || caseInsensitive,
          unicode: unicode),
      _ => string(this,
          message: message, ignoreCase: ignoreCase || caseInsensitive),
    };
  }
}

/// Returns a parser that accepts the [string].
///
/// - [message] defines a custom error message.
/// - If [ignoreCase] is `true`, the string is matched in a case-insensitive
///   manner.
///
/// For example, `string('foo')` `succeeds and consumes the input string
/// `'foo'`. Fails for any other input.`
@useResult
Parser<String> string(String string,
    {String? message, bool ignoreCase = false}) {
  if (ignoreCase) {
    final lowerCaseString = string.toLowerCase();
    return predicate(
        string.length,
        (each) => lowerCaseString == each.toLowerCase(),
        message ?? '"$string" (case-insensitive) expected');
  } else {
    return predicate(string.length, (each) => string == each,
        message ?? '"$string" expected');
  }
}

@useResult
@Deprecated('Use `string(value, ignoreCase: true)` instead')
Parser<String> stringIgnoreCase(String value, [String? message]) =>
    string(value, message: message, ignoreCase: true);
