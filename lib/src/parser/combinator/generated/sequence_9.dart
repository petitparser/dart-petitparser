// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 9 parsers and returns a
/// typed sequence [Sequence9].
Parser<Sequence9<R1, R2, R3, R4, R5, R6, R7, R8, R9>>
    seq9<R1, R2, R3, R4, R5, R6, R7, R8, R9>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
  Parser<R8> parser8,
  Parser<R9> parser9,
) =>
        SequenceParser9<R1, R2, R3, R4, R5, R6, R7, R8, R9>(
          parser1,
          parser2,
          parser3,
          parser4,
          parser5,
          parser6,
          parser7,
          parser8,
          parser9,
        );

/// A parser that consumes a sequence of 9 typed parsers and returns a typed
/// sequence [Sequence9].
class SequenceParser9<R1, R2, R3, R4, R5, R6, R7, R8, R9>
    extends Parser<Sequence9<R1, R2, R3, R4, R5, R6, R7, R8, R9>>
    implements SequentialParser {
  SequenceParser9(this.parser1, this.parser2, this.parser3, this.parser4,
      this.parser5, this.parser6, this.parser7, this.parser8, this.parser9);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;
  Parser<R6> parser6;
  Parser<R7> parser7;
  Parser<R8> parser8;
  Parser<R9> parser9;

  @override
  Result<Sequence9<R1, R2, R3, R4, R5, R6, R7, R8, R9>> parseOn(
      Context context) {
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
    final result8 = parser8.parseOn(result7);
    if (result8.isFailure) return result8.failure(result8.message);
    final result9 = parser9.parseOn(result8);
    if (result9.isFailure) return result9.failure(result9.message);
    return result9.success(Sequence9<R1, R2, R3, R4, R5, R6, R7, R8, R9>(
        result1.value,
        result2.value,
        result3.value,
        result4.value,
        result5.value,
        result6.value,
        result7.value,
        result8.value,
        result9.value));
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
    position = parser8.fastParseOn(buffer, position);
    if (position < 0) return -1;
    position = parser9.fastParseOn(buffer, position);
    if (position < 0) return -1;
    return position;
  }

  @override
  List<Parser> get children => [
        parser1,
        parser2,
        parser3,
        parser4,
        parser5,
        parser6,
        parser7,
        parser8,
        parser9
      ];

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
    if (parser8 == source) parser8 = target as Parser<R8>;
    if (parser9 == source) parser9 = target as Parser<R9>;
  }

  @override
  SequenceParser9<R1, R2, R3, R4, R5, R6, R7, R8, R9> copy() =>
      SequenceParser9<R1, R2, R3, R4, R5, R6, R7, R8, R9>(parser1, parser2,
          parser3, parser4, parser5, parser6, parser7, parser8, parser9);
}

/// Immutable typed sequence with 9 values.
@immutable
class Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9> {
  Sequence9(this.value1, this.value2, this.value3, this.value4, this.value5,
      this.value6, this.value7, this.value8, this.value9);

  final T1 value1;
  final T2 value2;
  final T3 value3;
  final T4 value4;
  final T5 value5;
  final T6 value6;
  final T7 value7;
  final T8 value8;
  final T9 value9;

  /// Converts this sequence to a new type [R] with the provided [callback].
  R map<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) callback) => callback(
      value1, value2, value3, value4, value5, value6, value7, value8, value9);

  @override
  int get hashCode => Object.hash(
      value1, value2, value3, value4, value5, value6, value7, value8, value9);

  @override
  bool operator ==(Object other) =>
      other is Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9> &&
      value1 == other.value1 &&
      value2 == other.value2 &&
      value3 == other.value3 &&
      value4 == other.value4 &&
      value5 == other.value5 &&
      value6 == other.value6 &&
      value7 == other.value7 &&
      value8 == other.value8 &&
      value9 == other.value9;

  @override
  String toString() =>
      '${super.toString()}($value1, $value2, $value3, $value4, $value5, $value6, $value7, $value8, $value9)';
}

extension ParserSequenceExtension9<T1, T2, T3, T4, T5, T6, T7, T8, T9>
    on Parser<Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map9<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) callback) =>
      map((sequence) => sequence.map(callback));
}
