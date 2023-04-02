import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/whitespace.dart';
import '../combinator/skip.dart';
import '../repeater/possessive.dart';

extension TrimmingParserExtension<R> on Parser<R> {
  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns the result of the receiver.
  /// The optional arguments are parsers that consume the excess input. By
  /// default `whitespace()` is used. Up to two arguments can be provided to
  /// have different parsers on the [left] and [right] side.
  ///
  /// For example, the parser `letter().plus().trim()` returns `['a', 'b']`
  /// for the input `' ab\n'` and consumes the complete input string.
  @useResult
  Parser<R> trim([Parser<void>? left, Parser<void>? right]) {
    final before = left ?? whitespace(), after = right ?? before;
    return skip(before: before.star(), after: after.star());
  }
}
