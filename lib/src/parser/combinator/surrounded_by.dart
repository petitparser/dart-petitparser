import '../../core/parser.dart';
import '../action/map.dart';
import 'sequence.dart';

extension SurroundedByParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes input [before] and [after] the receiver,
  /// but discards their parse results and only returns the result of the
  /// receiver.
  ///
  /// If a single [before] parser is provided, the same parser is also used to
  /// consume input afterwards. To skip the [before] or [after] parsing pass an
  /// `epsilon()` parser.
  ///
  /// For example, the parser `digit().surroundedBy(char('['), char(']'))`
  /// returns `'3'` for the input `'[3]'`.
  Parser<T> surroundedBy(Parser<void> before, [Parser<void>? after]) => [
        before,
        this,
        after ?? before,
      ].toSequenceParser().map((list) => list[1] as T);
}
