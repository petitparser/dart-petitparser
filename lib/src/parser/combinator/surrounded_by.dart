import '../../core/parser.dart';
import '../action/cast.dart';
import '../action/pick.dart';
import 'sequence.dart';

extension SurroundedByParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes input [before] and [after] the reciever, but
  /// discards their parse results and only returns the result of the reciever.
  ///
  /// If a single [before] parser is provided, the same parser is also used to
  /// consume input afterwards. To skip the [before] or [after] parsing pass an
  /// `epsilon()` parser.
  ///
  /// For example, the parser `digit().plus().surroundedBy(char('['), char(']'))`
  /// returns `'42'` for the input `'[42]'`.
  Parser<T> surroundedBy(Parser<void> before, [Parser<void>? after]) =>
      [before, this, after ?? before].toSequenceParser().pick(1).cast<T>();
}
