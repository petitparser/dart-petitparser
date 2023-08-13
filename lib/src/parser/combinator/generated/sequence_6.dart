// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../core/context.dart';
import '../../../core/parser.dart';
import '../../../core/result.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that consumes the 6 parsers passed as argument in
/// sequence and returns a [Record] with 6 positional parse results.
///
/// For example,
/// the parser `seq6(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'))`
/// returns `('a', 'b', 'c', 'd', 'e', 'f')`
/// for the input `'abcdef'`.
@useResult
Parser<(R1, R2, R3, R4, R5, R6)> seq6<R1, R2, R3, R4, R5, R6>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
) =>
    SequenceParser6<R1, R2, R3, R4, R5, R6>(
        parser1, parser2, parser3, parser4, parser5, parser6);

/// Extensions on a [Record] with 6 positional [Parser]s.
extension RecordOfParsersExtension6<R1, R2, R3, R4, R5, R6> on (
  Parser<R1>,
  Parser<R2>,
  Parser<R3>,
  Parser<R4>,
  Parser<R5>,
  Parser<R6>
) {
  /// Converts a [Record] of 6 positional parsers to a [Parser] that runs the
  /// parsers in sequence and returns a [Record] with 6 positional parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b'), char('c'), char('d'), char('e'), char('f')).toSequenceParser()`
  /// returns `('a', 'b', 'c', 'd', 'e', 'f')`
  /// for the input `'abcdef'`.
  @useResult
  Parser<(R1, R2, R3, R4, R5, R6)> toSequenceParser() =>
      SequenceParser6<R1, R2, R3, R4, R5, R6>($1, $2, $3, $4, $5, $6);
}

/// A parser that consumes a sequence of 6 parsers and returns a [Record] with
/// 6 positional parse results.
class SequenceParser6<R1, R2, R3, R4, R5, R6>
    extends Parser<(R1, R2, R3, R4, R5, R6)> implements SequentialParser {
  SequenceParser6(this.parser1, this.parser2, this.parser3, this.parser4,
      this.parser5, this.parser6);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;
  Parser<R6> parser6;

  @override
  Result<(R1, R2, R3, R4, R5, R6)> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1 is Failure) return result1;
    final result2 = parser2.parseOn(result1);
    if (result2 is Failure) return result2;
    final result3 = parser3.parseOn(result2);
    if (result3 is Failure) return result3;
    final result4 = parser4.parseOn(result3);
    if (result4 is Failure) return result4;
    final result5 = parser5.parseOn(result4);
    if (result5 is Failure) return result5;
    final result6 = parser6.parseOn(result5);
    if (result6 is Failure) return result6;
    return result6.success((
      result1.value,
      result2.value,
      result3.value,
      result4.value,
      result5.value,
      result6.value
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
    position = parser6.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children =>
      [parser1, parser2, parser3, parser4, parser5, parser6];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (parser1 == source) parser1 = target as Parser<R1>;
    if (parser2 == source) parser2 = target as Parser<R2>;
    if (parser3 == source) parser3 = target as Parser<R3>;
    if (parser4 == source) parser4 = target as Parser<R4>;
    if (parser5 == source) parser5 = target as Parser<R5>;
    if (parser6 == source) parser6 = target as Parser<R6>;
  }

  @override
  SequenceParser6<R1, R2, R3, R4, R5, R6> copy() =>
      SequenceParser6<R1, R2, R3, R4, R5, R6>(
          parser1, parser2, parser3, parser4, parser5, parser6);
}

/// Extension on a [Record] with 6 positional values.
extension RecordOfValuesExtension6<T1, T2, T3, T4, T5, T6> on (
  T1,
  T2,
  T3,
  T4,
  T5,
  T6
) {
  /// Returns the first element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $1')
  T1 get first => $1;

  /// Returns the second element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $2')
  T2 get second => $2;

  /// Returns the third element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $3')
  T3 get third => $3;

  /// Returns the fourth element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $4')
  T4 get fourth => $4;

  /// Returns the fifth element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $5')
  T5 get fifth => $5;

  /// Returns the sixth element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $6')
  T6 get sixth => $6;

  /// Returns the last element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $6')
  T6 get last => $6;

  /// Converts this [Record] with 6 positional values to a new type [R] using
  /// the provided [callback] with 6 positional arguments.
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3, T4, T5, T6) callback) =>
      callback($1, $2, $3, $4, $5, $6);
}

/// Extension on a [Parser] producing a [Record] of 6 positional values.
extension RecordParserExtension6<T1, T2, T3, T4, T5, T6>
    on Parser<(T1, T2, T3, T4, T5, T6)> {
  /// Maps a parsed [Record] to [R] using the provided [callback], see
  /// [MapParserExtension.map] for details.
  @useResult
  Parser<R> map6<R>(R Function(T1, T2, T3, T4, T5, T6) callback,
          {bool hasSideEffects = false}) =>
      map((record) => record.map(callback), hasSideEffects: hasSideEffects);
}
