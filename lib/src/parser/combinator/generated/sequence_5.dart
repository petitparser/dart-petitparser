// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../core/context.dart';
import '../../../core/parser.dart';
import '../../../core/result.dart';
import '../../../shared/pragma.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that consumes the 5 parsers passed as argument in
/// sequence and returns a [Record] with the 5 positional parse results.
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
) => SequenceParser5<R1, R2, R3, R4, R5>(
  parser1,
  parser2,
  parser3,
  parser4,
  parser5,
);

/// Extensions on a [Record] with 5 positional [Parser]s.
extension RecordOfParsersExtension5<R1, R2, R3, R4, R5>
    on (Parser<R1>, Parser<R2>, Parser<R3>, Parser<R4>, Parser<R5>) {
  /// Converts a [Record] of 5 positional parsers to a [Parser] that runs the
  /// parsers in sequence and returns a [Record] with 5 positional parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b'), char('c'), char('d'), char('e')).toSequenceParser()`
  /// returns `('a', 'b', 'c', 'd', 'e')`
  /// for the input `'abcde'`.
  @useResult
  Parser<(R1, R2, R3, R4, R5)> toSequenceParser() =>
      SequenceParser5<R1, R2, R3, R4, R5>($1, $2, $3, $4, $5);
}

/// A parser that consumes a sequence of 5 parsers and returns a [Record] with
/// 5 positional parse results.
class SequenceParser5<R1, R2, R3, R4, R5> extends Parser<(R1, R2, R3, R4, R5)>
    implements SequentialParser {
  SequenceParser5(
    this.parser1,
    this.parser2,
    this.parser3,
    this.parser4,
    this.parser5,
  );

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;

  @override
  Result<(R1, R2, R3, R4, R5)> parseOn(Context context) {
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
    return result5.success((
      result1.value,
      result2.value,
      result3.value,
      result4.value,
      result5.value,
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
        parser1,
        parser2,
        parser3,
        parser4,
        parser5,
      );
}

/// Extension on a [Record] with 5 positional values.
extension RecordOfValuesExtension5<T1, T2, T3, T4, T5> on (T1, T2, T3, T4, T5) {
  /// Converts this [Record] with 5 positional values to a new type [R] using
  /// the provided [callback] with 5 positional arguments.
  @preferInline
  R map<R>(R Function(T1, T2, T3, T4, T5) callback) =>
      callback($1, $2, $3, $4, $5);
}

/// Extension on a [Parser] producing a [Record] of 5 positional values.
extension RecordParserExtension5<T1, T2, T3, T4, T5>
    on Parser<(T1, T2, T3, T4, T5)> {
  /// Maps a parsed [Record] to [R] using the provided [callback], see
  /// [MapParserExtension.map] for details.
  @useResult
  Parser<R> map5<R>(
    R Function(T1, T2, T3, T4, T5) callback, {
    bool hasSideEffects = false,
  }) => map((record) => record.map(callback), hasSideEffects: hasSideEffects);
}
