import '../../core/parser.dart';
import '../character/any_of.dart';
import '../character/char.dart';
import '../misc/epsilon.dart';
import 'predicate.dart';

extension PredicateStringExtension on String {
  /// Converts this string to a corresponding parser.
  Parser<String> toParser({bool caseInsensitive = false, String message}) {
    if (isEmpty) {
      return epsilon(this);
    } else if (length == 1) {
      return caseInsensitive
          ? anyOf('${toLowerCase()}${toUpperCase()}', message)
          : char(this, message);
    } else {
      return caseInsensitive
          ? stringIgnoreCase(this, message)
          : string(this, message);
    }
  }
}

/// Returns a parser that accepts the string [element].
///
/// For example, `string('foo')` `succeeds and consumes the input string
/// `'foo'`. Fails for any other input.`
Parser<String> string(String element, [String message]) {
  return predicate(element.length, (each) => element == each,
      message ?? '$element expected');
}

/// Returns a parser that accepts the string [element] ignoring the case.
///
/// For example, `stringIgnoreCase('foo')` succeeds and consumes the input
/// string `'Foo'` or `'FOO'`. Fails for any other input.
Parser<String> stringIgnoreCase(String element, [String message]) {
  final lowerElement = element.toLowerCase();
  return predicate(element.length, (each) => lowerElement == each.toLowerCase(),
      message ?? '$element expected');
}
