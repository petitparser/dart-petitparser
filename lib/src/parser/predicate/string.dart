import 'package:collection/collection.dart' show equalsIgnoreAsciiCase;
import 'package:meta/meta.dart';

import '../../core/parser.dart';
import 'predicate.dart';

/// Returns a parser that accepts the string [element].
///
/// For example, `string('foo')` `succeeds and consumes the input string
/// `'foo'`. Fails for any other input.`
@useResult
Parser<String> string(String element, [String? message]) => predicate(
    element.length,
    (each) => element == each,
    message ?? '"$element" expected');

/// Returns a parser that accepts the string [element] ignoring the case.
///
/// For example, `stringIgnoreCase('foo')` succeeds and consumes the input
/// string `'Foo'` or `'FOO'`. Fails for any other input.
@useResult
Parser<String> stringIgnoreCase(String element, [String? message]) => predicate(
    element.length,
    (value) => equalsIgnoreAsciiCase(element, value),
    message ?? '"$element" (case-insensitive) expected');
