// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../core/context.dart';
import '../../../core/parser.dart';
import '../../../core/result.dart';
import '../../../shared/pragma.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that consumes the 7 parsers passed as argument in
/// sequence and returns a [Record] with the 7 positional parse results.
///
/// For example,
/// the parser `seq7(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'), char('g'))`
/// returns `('a', 'b', 'c', 'd', 'e', 'f', 'g')`
/// for the input `'abcdefg'`.
@useResult
Parser<(R1, R2, R3, R4, R5, R6, R7)> seq7<R1, R2, R3, R4, R5, R6, R7>(
        Parser<R1> parser1,
        Parser<R2> parser2,
        Parser<R3> parser3,
        Parser<R4> parser4,
        Parser<R5> parser5,
        Parser<R6> parser6,
        Parser<R7> parser7) =>
    SequenceParser7<R1, R2, R3, R4, R5, R6, R7>(
        parser1, parser2, parser3, parser4, parser5, parser6, parser7);

/// Extensions on a [Record] with 7 positional [Parser]s.
extension RecordOfParsersExtension7<R1, R2, R3, R4, R5, R6, R7> on (
  Parser<R1>,
  Parser<R2>,
  Parser<R3>,
  Parser<R4>,
  Parser<R5>,
  Parser<R6>,
  Parser<R7>
) {
  /// Converts a [Record] of 7 positional parsers to a [Parser] that runs the
  /// parsers in sequence and returns a [Record] with 7 positional parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b'), char('c'), char('d'), char('e'), char('f'), char('g')).toSequenceParser()`
  /// returns `('a', 'b', 'c', 'd', 'e', 'f', 'g')`
  /// for the input `'abcdefg'`.
  @useResult
  Parser<(R1, R2, R3, R4, R5, R6, R7)> toSequenceParser() =>
      SequenceParser7<R1, R2, R3, R4, R5, R6, R7>($1, $2, $3, $4, $5, $6, $7);
}

/// A parser that consumes a sequence of 7 parsers and returns a [Record] with
/// 7 positional parse results.
class SequenceParser7<R1, R2, R3, R4, R5, R6, R7>
    extends Parser<(R1, R2, R3, R4, R5, R6, R7)> implements SequentialParser {
  SequenceParser7(this.parser1, this.parser2, this.parser3, this.parser4,
      this.parser5, this.parser6, this.parser7);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;
  Parser<R6> parser6;
  Parser<R7> parser7;

  @override
  Result<(R1, R2, R3, R4, R5, R6, R7)> parseOn(Context context) {
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
    final result7 = parser7.parseOn(result6);
    if (result7 is Failure) return result7;
    return result7.success((
      result1.value,
      result2.value,
      result3.value,
      result4.value,
      result5.value,
      result6.value,
      result7.value
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
    position = parser7.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children =>
      [parser1, parser2, parser3, parser4, parser5, parser6, parser7];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (parser1 == source) parser1 = target as Parser<R1>;
    if (parser2 == source) parser2 = target as Parser<R2>;
    if (parser3 == source) parser3 = target as Parser<R3>;
    if (parser4 == source) parser4 = target as Parser<R4>;
    if (parser5 == source) parser5 = target as Parser<R5>;
    if (parser6 == source) parser6 = target as Parser<R6>;
    if (parser7 == source) parser7 = target as Parser<R7>;
  }

  @override
  SequenceParser7<R1, R2, R3, R4, R5, R6, R7> copy() =>
      SequenceParser7<R1, R2, R3, R4, R5, R6, R7>(
          parser1, parser2, parser3, parser4, parser5, parser6, parser7);
}

/// Extension on a [Record] with 7 positional values.
extension RecordOfValuesExtension7<T1, T2, T3, T4, T5, T6, T7> on (
  T1,
  T2,
  T3,
  T4,
  T5,
  T6,
  T7
) {
  /// Converts this [Record] with 7 positional values to a new type [R] using
  /// the provided [callback] with 7 positional arguments.
  @preferInline
  R map<R>(R Function(T1, T2, T3, T4, T5, T6, T7) callback) =>
      callback($1, $2, $3, $4, $5, $6, $7);
}

/// Extension on a [Parser] producing a [Record] of 7 positional values.
extension RecordParserExtension7<T1, T2, T3, T4, T5, T6, T7>
    on Parser<(T1, T2, T3, T4, T5, T6, T7)> {
  /// Maps a parsed [Record] to [R] using the provided [callback], see
  /// [MapParserExtension.map] for details.
  @useResult
  Parser<R> map7<R>(R Function(T1, T2, T3, T4, T5, T6, T7) callback,
          {bool hasSideEffects = false}) =>
      map((record) => record.map(callback), hasSideEffects: hasSideEffects);
}
