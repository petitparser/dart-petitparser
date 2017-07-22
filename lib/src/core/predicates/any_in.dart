library petitparser.core.predicates.any_in;

import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/predicates/predicate.dart';

/// Returns a parser that accepts any of the [elements].
///
/// For example, `anyIn('ab')` succeeds and consumes either the letter
/// `'a'` or the letter `'b'`. For any other input the parser fails.
Parser anyIn(elements, [String message]) {
  return predicate(
      1, (each) => elements.indexOf(each) >= 0, message ?? 'any of $elements expected');
}
