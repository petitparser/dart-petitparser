import 'package:collection/collection.dart' show equalsIgnoreAsciiCase;
import 'package:meta/meta.dart' show useResult;

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';

/// Returns a parser that accepts the [string].
///
/// - [message] defines a custom error message.
/// - If [ignoreCase] is `true`, the string is matched in a case-insensitive
///   manner.
///
/// For example, `string('foo')` succeeds and consumes the input string
/// `'foo'`. Fails for any other input.
@useResult
Parser<String> string(
  String string, {
  String? message,
  bool ignoreCase = false,
}) => ignoreCase
    ? StringIgnoreCaseParser(
        string,
        message ?? '"$string" (case-insensitive) expected',
      )
    : StringParser(string, message ?? '"$string" expected');

/// A parser for a literal string.
class StringParser extends Parser<String> {
  StringParser(this.literal, this.message);

  /// The literal to match.
  final String literal;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (buffer.startsWith(literal, position)) {
      return context.success(literal, position + literal.length);
    }
    return context.failure(message);
  }

  @override
  @noBoundsChecks
  int fastParseOn(String buffer, int position) =>
      buffer.startsWith(literal, position) ? position + literal.length : -1;

  @override
  StringParser copy() => StringParser(literal, message);

  @override
  bool hasEqualProperties(covariant StringParser other) =>
      super.hasEqualProperties(other) &&
      literal == other.literal &&
      message == other.message;
}

/// A parser for a literal string, case-insensitive.
class StringIgnoreCaseParser extends StringParser {
  StringIgnoreCaseParser(super.input, super.message);

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    final stop = position + literal.length;
    if (stop <= buffer.length) {
      final result = buffer.substring(position, stop);
      if (equalsIgnoreAsciiCase(literal, result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(message);
  }

  @override
  @noBoundsChecks
  int fastParseOn(String buffer, int position) {
    final stop = position + literal.length;
    return stop <= buffer.length &&
            equalsIgnoreAsciiCase(literal, buffer.substring(position, stop))
        ? stop
        : -1;
  }

  @override
  StringIgnoreCaseParser copy() => StringIgnoreCaseParser(literal, message);
}
