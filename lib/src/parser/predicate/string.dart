import 'package:meta/meta.dart';

import '../../core/parser.dart';
import 'predicate.dart';

/// Returns a parser that accepts the [string].
///
/// - [message] defines a custom error message.
/// - If [ignoreCase] is `true`, the string is matched in a case-insensitive
///   manner.
///
/// For example, `string('foo')` succeeds and consumes the input string
/// `'foo'`. Fails for any other input.
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
