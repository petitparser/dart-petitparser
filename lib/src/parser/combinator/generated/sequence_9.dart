// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../core/parser.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 9 parsers and returns a
/// typed sequence [Sequence9].
@useResult
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
  void parseOn(Context context) {
    if (context.isSkip) {
      parser1.parseOn(context);
      if (!context.isSuccess) return;
      parser2.parseOn(context);
      if (!context.isSuccess) return;
      parser3.parseOn(context);
      if (!context.isSuccess) return;
      parser4.parseOn(context);
      if (!context.isSuccess) return;
      parser5.parseOn(context);
      if (!context.isSuccess) return;
      parser6.parseOn(context);
      if (!context.isSuccess) return;
      parser7.parseOn(context);
      if (!context.isSuccess) return;
      parser8.parseOn(context);
      if (!context.isSuccess) return;
      parser9.parseOn(context);
      if (!context.isSuccess) return;
    } else {
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
      parser9.parseOn(context);
      if (!context.isSuccess) return;
      final result9 = context.value as R9;
      context.value = Sequence9<R1, R2, R3, R4, R5, R6, R7, R8, R9>(
          result1,
          result2,
          result3,
          result4,
          result5,
          result6,
          result7,
          result8,
          result9);
    }
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
  /// Constructs a sequence with 9 typed values.
  const Sequence9(this.first, this.second, this.third, this.fourth, this.fifth,
      this.sixth, this.seventh, this.eighth, this.ninth);

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

  /// Returns the ninth element of this sequence.
  final T9 ninth;

  /// Returns the last (or ninth) element of this sequence.
  @inlineVm
  @inlineJs
  T9 get last => ninth;

  /// Converts this sequence to a new type [R] with the provided [callback].
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) callback) => callback(
      first, second, third, fourth, fifth, sixth, seventh, eighth, ninth);

  @override
  int get hashCode => Object.hash(
      first, second, third, fourth, fifth, sixth, seventh, eighth, ninth);

  @override
  bool operator ==(Object other) =>
      other is Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9> &&
      first == other.first &&
      second == other.second &&
      third == other.third &&
      fourth == other.fourth &&
      fifth == other.fifth &&
      sixth == other.sixth &&
      seventh == other.seventh &&
      eighth == other.eighth &&
      ninth == other.ninth;

  @override
  String toString() =>
      '${super.toString()}($first, $second, $third, $fourth, $fifth, $sixth, $seventh, $eighth, $ninth)';
}

extension ParserSequenceExtension9<T1, T2, T3, T4, T5, T6, T7, T8, T9>
    on Parser<Sequence9<T1, T2, T3, T4, T5, T6, T7, T8, T9>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map9<R>(R Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) callback) =>
      map((sequence) => sequence.map(callback));
}
