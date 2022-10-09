import '../../core/parser.dart';
import 'sequence_map.dart';

extension SkipParserExtension<T> on Parser<T> {
  /// Returns a parser that consumes input [before] and [after] the receiver,
  /// but discards the parse results of [before] and [after] and only returns
  /// the result of the receiver.
  ///
  /// For example, the parser `digit().skip(char('['), char(']'))`
  /// returns `'3'` for the input `'[3]'`.
  Parser<T> skip({Parser<void>? before, Parser<void>? after}) => before == null
      ? after == null
          ? this
          : seqMap2(this, after, (value, _) => value)
      : after == null
          ? seqMap2(before, this, (_, value) => value)
          : seqMap3(before, this, after, (_, value, __) => value);
}
