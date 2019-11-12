library petitparser.core.predicates.any_in;

import '../parser.dart';
import 'predicate.dart';

/// Returns a parser that accepts any of the [elements].
///
/// For example, `anyIn('ab')` succeeds and consumes either the letter
/// `'a'` or the letter `'b'`. For any other input the parser fails.
Parser<String> anyIn(String elements, [String message]) {
  return predicate(1, (each) => elements.contains(each),
      message ?? 'any of $elements expected');
}
