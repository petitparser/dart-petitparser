// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../core/parser.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 8 parsers and returns a
/// typed sequence [Sequence8].
@useResult
Parser<Sequence8<R1, R2, R3, R4, R5, R6, R7, R8>>
    seq8<R1, R2, R3, R4, R5, R6, R7, R8>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
  Parser<R8> parser8,
) =>
        SequenceParser8<R1, R2, R3, R4, R5, R6, R7, R8>(
          parser1,
          parser2,
          parser3,
          parser4,
          parser5,
          parser6,
          parser7,
          parser8,
        );

/// A parser that consumes a sequence of 8 typed parsers and returns a typed
/// sequence [Sequence8].
class SequenceParser8<R1, R2, R3, R4, R5, R6, R7, R8>
    extends Parser<Sequence8<R1, R2, R3, R4, R5, R6, R7, R8>>
    implements SequentialParser {
  SequenceParser8(this.parser1, this.parser2, this.parser3, this.parser4,
      this.parser5, this.parser6, this.parser7, this.parser8);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;
  Parser<R6> parser6;
  Parser<R7> parser7;
  Parser<R8> parser8;

  @override
  void parseOn(Context context) {
    parser1.parseOn(context);
    if (!context.isSuccess) return;
    final result1 = context.value as R1;
    parser2.parseOn(context);
    if (!context.isSuccess) return;
    final result2 = context.value as R2;
    parser3.parseOn(context);
    if (!context.isSuccess) return;
    final result3 = context.value as R3;
    parser4.parseOn(context);
    if (!context.isSuccess) return;
    final result4 = context.value as R4;
    parser5.parseOn(context);
    if (!context.isSuccess) return;
    final result5 = context.value as R5;
    parser6.parseOn(context);
    if (!context.isSuccess) return;
    final result6 = context.value as R6;
    parser7.parseOn(context);
    if (!context.isSuccess) return;
    final result7 = context.value as R7;
    parser8.parseOn(context);
    if (!context.isSuccess) return;
    final result8 = context.value as R8;
    context.value = Sequence8<R1, R2, R3, R4, R5, R6, R7, R8>(
        result1, result2, result3, result4, result5, result6, result7, result8);
  }

  @override
  void fastParseOn(Context context) {
    parser1.fastParseOn(context);
    if (!context.isSuccess) return;
    parser2.fastParseOn(context);
    if (!context.isSuccess) return;
    parser3.fastParseOn(context);
    if (!context.isSuccess) return;
    parser4.fastParseOn(context);
    if (!context.isSuccess) return;
    parser5.fastParseOn(context);
    if (!context.isSuccess) return;
    parser6.fastParseOn(context);
    if (!context.isSuccess) return;
    parser7.fastParseOn(context);
    if (!context.isSuccess) return;
    parser8.fastParseOn(context);
    if (!context.isSuccess) return;
  }

  @override
  List<Parser> get children =>
      [parser1, parser2, parser3, parser4, parser5, parser6, parser7, parser8];

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
  }

  @override
  SequenceParser8<R1, R2, R3, R4, R5, R6, R7, R8> copy() =>
      SequenceParser8<R1, R2, R3, R4, R5, R6, R7, R8>(parser1, parser2, parser3,
          parser4, parser5, parser6, parser7, parser8);
}

/// Immutable typed sequence with 8 values.
@immutable
class Sequence8<T1, T2, T3, T4, T5, T6, T7, T8> {
  /// Constructs a sequence with 8 typed values.
  const Sequence8(this.first, this.second, this.third, this.fourth, this.fifth,
      this.sixth, this.seventh, this.eighth);

  /// Returns the first element of this sequence.
  final T1 first;

  /// Returns the second element of this sequence.
  final T2 second;

  /// Returns the third element of this sequence.
  final T3 third;

  /// Returns the fourth element of this sequence.
  final T4 fourth;

  /// Returns the fifth element of this sequence.
  final T5 fifth;

  /// Returns the sixth element of this sequence.
  final T6 sixth;

  /// Returns the seventh element of this sequence.
  final T7 seventh;

  /// Returns the eighth element of this sequence.
  final T8 eighth;

  /// Returns the last (or eighth) element of this sequence.
  @inlineVm
  @inlineJs
  T8 get last => eighth;

  /// Converts this sequence to a new type [R] with the provided [callback].
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8) callback) =>
      callback(first, second, third, fourth, fifth, sixth, seventh, eighth);

  @override
  int get hashCode =>
      Object.hash(first, second, third, fourth, fifth, sixth, seventh, eighth);

  @override
  bool operator ==(Object other) =>
      other is Sequence8<T1, T2, T3, T4, T5, T6, T7, T8> &&
      first == other.first &&
      second == other.second &&
      third == other.third &&
      fourth == other.fourth &&
      fifth == other.fifth &&
      sixth == other.sixth &&
      seventh == other.seventh &&
      eighth == other.eighth;

  @override
  String toString() =>
      '${super.toString()}($first, $second, $third, $fourth, $fifth, $sixth, $seventh, $eighth)';
}

extension ParserSequenceExtension8<T1, T2, T3, T4, T5, T6, T7, T8>
    on Parser<Sequence8<T1, T2, T3, T4, T5, T6, T7, T8>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map8<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8) callback) =>
      map((sequence) => sequence.map(callback));
}
