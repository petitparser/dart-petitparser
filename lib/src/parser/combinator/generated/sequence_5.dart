// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that runs the 5 parsers passed as argument in sequence
/// and returns a [Record] with the parsed results.
///
/// For example,
/// the parser `seq5(char('a'), char('b'), char('c'), char('d'), char('e'))`
/// returns `('a', 'b', 'c', 'd', 'e')`
/// for the input `'abcde'`.
@useResult
Parser<(R1, R2, R3, R4, R5)> seq5<R1, R2, R3, R4, R5>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
) =>
    SequenceParser5<R1, R2, R3, R4, R5>(
        parser1, parser2, parser3, parser4, parser5);

/// Extension on a [Record] of 5 [Parser]s.
extension RecordOfParserExtension5<R1, R2, R3, R4, R5> on (
  Parser<R1>,
  Parser<R2>,
  Parser<R3>,
  Parser<R4>,
  Parser<R5>
) {
  /// Converts a [Record] of 5 parsers to a [Parser] that reads the input in
  /// sequence and returns a [Record] with 5 parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b'), char('c'), char('d'), char('e')).toParser()`
  /// returns `('a', 'b', 'c', 'd', 'e')`
  /// for the input `'abcde'`.
  @useResult
  Parser<(R1, R2, R3, R4, R5)> toParser() =>
      SequenceParser5<R1, R2, R3, R4, R5>($1, $2, $3, $4, $5);
}

/// A parser that consumes a sequence of 5 parsers and returns a [Record] with
/// 5 parse results.
class SequenceParser5<R1, R2, R3, R4, R5> extends Parser<(R1, R2, R3, R4, R5)>
    implements SequentialParser {
  SequenceParser5(
      this.parser1, this.parser2, this.parser3, this.parser4, this.parser5);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;

  @override
  Result<(R1, R2, R3, R4, R5)> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1.isFailure) return result1.failure(result1.message);
    final result2 = parser2.parseOn(result1);
    if (result2.isFailure) return result2.failure(result2.message);
    final result3 = parser3.parseOn(result2);
    if (result3.isFailure) return result3.failure(result3.message);
    final result4 = parser4.parseOn(result3);
    if (result4.isFailure) return result4.failure(result4.message);
    final result5 = parser5.parseOn(result4);
    if (result5.isFailure) return result5.failure(result5.message);
    return result5.success((
      result1.value,
      result2.value,
      result3.value,
      result4.value,
      result5.value
    ));
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = parser1.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser2.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser3.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser4.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser5.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children => [parser1, parser2, parser3, parser4, parser5];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (parser1 == source) parser1 = target as Parser<R1>;
    if (parser2 == source) parser2 = target as Parser<R2>;
    if (parser3 == source) parser3 = target as Parser<R3>;
    if (parser4 == source) parser4 = target as Parser<R4>;
    if (parser5 == source) parser5 = target as Parser<R5>;
  }

  @override
  SequenceParser5<R1, R2, R3, R4, R5> copy() =>
      SequenceParser5<R1, R2, R3, R4, R5>(
          parser1, parser2, parser3, parser4, parser5);
}

/// Extension on a parsed [Record] with 5 values.
extension Parsed5ResultsRecord<T1, T2, T3, T4, T5> on (T1, T2, T3, T4, T5) {
  /// Returns the first element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $1')
  T1 get first => $1;

  /// Returns the second element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $2')
  T2 get second => $2;

  /// Returns the third element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $3')
  T3 get third => $3;

  /// Returns the fourth element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $4')
  T4 get fourth => $4;

  /// Returns the fifth element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $5')
  T5 get fifth => $5;

  /// Returns the last element of this sequence.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $5')
  T5 get last => $5;

  /// Converts this [Record] to a new type [R] with the provided [callback].
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3, T4, T5) callback) =>
      callback($1, $2, $3, $4, $5);
}

/// Extension on a [Parser] reading a [Record] with 5 values.
extension RecordParserExtension5<T1, T2, T3, T4, T5>
    on Parser<(T1, T2, T3, T4, T5)> {
  /// Maps a parsed [Record] to [R] using the provided [callback].
  @useResult
  Parser<R> map5<R>(R Function(T1, T2, T3, T4, T5) callback) =>
      map((sequence) => sequence.map(callback));
}
