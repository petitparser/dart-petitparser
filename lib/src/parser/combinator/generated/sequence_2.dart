// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../core/context.dart';
import '../../../core/parser.dart';
import '../../../core/result.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a [Parser] that consumes the 2 parsers passed as argument in
/// sequence and returns a [Record] with 2 positional parse results.
///
/// For example,
/// the parser `seq2(char('a'), char('b'))`
/// returns `('a', 'b')`
/// for the input `'ab'`.
@useResult
Parser<(R1, R2)> seq2<R1, R2>(
  Parser<R1> parser1,
  Parser<R2> parser2,
) =>
    SequenceParser2<R1, R2>(parser1, parser2);

/// Extensions on a [Record] with 2 positional [Parser]s.
extension RecordOfParsersExtension2<R1, R2> on (Parser<R1>, Parser<R2>) {
  /// Converts a [Record] of 2 positional parsers to a [Parser] that runs the
  /// parsers in sequence and returns a [Record] with 2 positional parse results.
  ///
  /// For example,
  /// the parser `(char('a'), char('b')).toSequenceParser()`
  /// returns `('a', 'b')`
  /// for the input `'ab'`.
  @useResult
  Parser<(R1, R2)> toSequenceParser() => SequenceParser2<R1, R2>($1, $2);
}

/// A parser that consumes a sequence of 2 parsers and returns a [Record] with
/// 2 positional parse results.
class SequenceParser2<R1, R2> extends Parser<(R1, R2)>
    implements SequentialParser {
  SequenceParser2(this.parser1, this.parser2);

  Parser<R1> parser1;
  Parser<R2> parser2;

  @override
  Result<(R1, R2)> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1 is Failure) return result1;
    final result2 = parser2.parseOn(result1);
    if (result2 is Failure) return result2;
    return result2.success((result1.value, result2.value));
  }

  @override
  int fastParseOn(String buffer, int position) {
    position = parser1.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser2.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children => [parser1, parser2];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (parser1 == source) parser1 = target as Parser<R1>;
    if (parser2 == source) parser2 = target as Parser<R2>;
  }

  @override
  SequenceParser2<R1, R2> copy() => SequenceParser2<R1, R2>(parser1, parser2);
}

/// Extension on a [Record] with 2 positional values.
extension RecordOfValuesExtension2<T1, T2> on (T1, T2) {
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

  /// Returns the last element of this record.
  @inlineVm
  @inlineJs
  @Deprecated(r'Instead use the canonical accessor $2')
  T2 get last => $2;

  /// Converts this [Record] with 2 positional values to a new type [R] using
  /// the provided [callback] with 2 positional arguments.
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2) callback) => callback($1, $2);
}

/// Extension on a [Parser] producing a [Record] of 2 positional values.
extension RecordParserExtension2<T1, T2> on Parser<(T1, T2)> {
  /// Maps a parsed [Record] to [R] using the provided [callback], see
  /// [MapParserExtension.map] for details.
  @useResult
  Parser<R> map2<R>(R Function(T1, T2) callback,
          {bool hasSideEffects = false}) =>
      map((record) => record.map(callback), hasSideEffects: hasSideEffects);
}
