// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 7 parsers and returns a
/// typed sequence [Sequence7].
Parser<Sequence7<R1, R2, R3, R4, R5, R6, R7>> seq7<R1, R2, R3, R4, R5, R6, R7>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
) =>
    SequenceParser7<R1, R2, R3, R4, R5, R6, R7>(
      parser1,
      parser2,
      parser3,
      parser4,
      parser5,
      parser6,
      parser7,
    );

/// A parser that consumes a sequence of 7 typed parsers and returns a typed
/// sequence [Sequence7].
class SequenceParser7<R1, R2, R3, R4, R5, R6, R7>
    extends Parser<Sequence7<R1, R2, R3, R4, R5, R6, R7>>
    implements SequentialParser {
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
  Result<Sequence7<R1, R2, R3, R4, R5, R6, R7>> parseOn(Context context) {
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
    final result6 = parser6.parseOn(result5);
    if (result6.isFailure) return result6.failure(result6.message);
    final result7 = parser7.parseOn(result6);
    if (result7.isFailure) return result7.failure(result7.message);
    return result7.success(Sequence7<R1, R2, R3, R4, R5, R6, R7>(
        result1.value,
        result2.value,
        result3.value,
        result4.value,
        result5.value,
        result6.value,
        result7.value));
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

/// Immutable typed sequence with 7 values.
@immutable
class Sequence7<T1, T2, T3, T4, T5, T6, T7> {
  Sequence7(this.value1, this.value2, this.value3, this.value4, this.value5,
      this.value6, this.value7);

  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;

  @override
  int get hashCode =>
      Object.hash(value1, value2, value3, value4, value5, value6, value7);

  @override
  bool operator ==(Object other) =>
      other is Sequence7<T1, T2, T3, T4, T5, T6, T7> &&
      value1 == other.value1 &&
      value2 == other.value2 &&
      value3 == other.value3 &&
      value4 == other.value4 &&
      value5 == other.value5 &&
      value6 == other.value6 &&
      value7 == other.value7;

  @override
  String toString() =>
      '${super.toString()}($value1, $value2, $value3, $value4, $value5, $value6, $value7)';
}

extension ParserSequenceExtension7<T1, T2, T3, T4, T5, T6, T7>
    on Parser<Sequence7<T1, T2, T3, T4, T5, T6, T7>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map7<R>(R Function(T1, T2, T3, T4, T5, T6, T7) callback) =>
      map((sequence) => callback(
          sequence.value1,
          sequence.value2,
          sequence.value3,
          sequence.value4,
          sequence.value5,
          sequence.value6,
          sequence.value7));
}
