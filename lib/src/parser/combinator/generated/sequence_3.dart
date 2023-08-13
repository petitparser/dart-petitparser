// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../core/context.dart';
import '../../../core/parser.dart';
import '../../../core/result.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that consumes the 3 parsers passed as argument in
/// sequence and returns a [Record] with 3 positional parse results.
///
/// For example,
/// the parser `seq3(char('a'), char('b'), char('c'))`
/// returns `('a', 'b', 'c')`
/// for the input `'abc'`.
@useResult
Parser<(R1, R2, R3)> seq3<R1, R2, R3>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
) =>
    SequenceParser3<R1, R2, R3>(parser1, parser2, parser3);

/// Extensions on a [Record] with 3 positional [Parser]s.
extension RecordOfParsersExtension3<R1, R2, R3> on (
  Parser<R1>,
  Parser<R2>,
  Parser<R3>
) {
  /// Converts a [Record] of 3 positional parsers to a [Parser] that runs the
  /// parsers in sequence and returns a [Record] with 3 positional parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b'), char('c')).toSequenceParser()`
  /// returns `('a', 'b', 'c')`
  /// for the input `'abc'`.
  @useResult
  Parser<(R1, R2, R3)> toSequenceParser() =>
      SequenceParser3<R1, R2, R3>($1, $2, $3);
}

/// A parser that consumes a sequence of 3 parsers and returns a [Record] with
/// 3 positional parse results.
class SequenceParser3<R1, R2, R3> extends Parser<(R1, R2, R3)>
    implements SequentialParser {
  SequenceParser3(this.parser1, this.parser2, this.parser3);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;

  @override
  Result<(R1, R2, R3)> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1 is Failure) return result1;
    final result2 = parser2.parseOn(result1);
    if (result2 is Failure) return result2;
    final result3 = parser3.parseOn(result2);
    if (result3 is Failure) return result3;
    return result3.success((result1.value, result2.value, result3.value));
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = parser1.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser2.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser3.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children => [parser1, parser2, parser3];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (parser1 == source) parser1 = target as Parser<R1>;
    if (parser2 == source) parser2 = target as Parser<R2>;
    if (parser3 == source) parser3 = target as Parser<R3>;
  }

  @override
  SequenceParser3<R1, R2, R3> copy() =>
      SequenceParser3<R1, R2, R3>(parser1, parser2, parser3);
}

/// Extension on a [Record] with 3 positional values.
extension RecordOfValuesExtension3<T1, T2, T3> on (T1, T2, T3) {
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

  /// Returns the last element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $3')
  T3 get last => $3;

  /// Converts this [Record] with 3 positional values to a new type [R] using
  /// the provided [callback] with 3 positional arguments.
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3) callback) => callback($1, $2, $3);
}

/// Extension on a [Parser] producing a [Record] of 3 positional values.
extension RecordParserExtension3<T1, T2, T3> on Parser<(T1, T2, T3)> {
  /// Maps a parsed [Record] to [R] using the provided [callback], see
  /// [MapParserExtension.map] for details.
  @useResult
  Parser<R> map3<R>(R Function(T1, T2, T3) callback,
          {bool hasSideEffects = false}) =>
      map((record) => record.map(callback), hasSideEffects: hasSideEffects);
}
