import 'package:collection/collection.dart' show equalsIgnoreAsciiCase;
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
        {String? message, bool ignoreCase = false}) =>
    ignoreCase
        ? predicate(
            string.length,
            (value) => equalsIgnoreAsciiCase(string, value),
            message ?? '"$string" (case-insensitive) expected')
        : predicate(string.length, (value) => string == value,
            message ?? '"$string" expected');
