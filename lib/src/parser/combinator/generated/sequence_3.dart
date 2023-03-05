// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../core/parser.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 3 parsers and returns a
/// typed sequence [Sequence3].
@useResult
Parser<Sequence3<R1, R2, R3>> seq3<R1, R2, R3>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
) =>
    SequenceParser3<R1, R2, R3>(
      parser1,
      parser2,
      parser3,
    );

/// A parser that consumes a sequence of 3 typed parsers and returns a typed
/// sequence [Sequence3].
class SequenceParser3<R1, R2, R3> extends Parser<Sequence3<R1, R2, R3>>
    implements SequentialParser {
  SequenceParser3(this.parser1, this.parser2, this.parser3);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;

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
    context.value = Sequence3<R1, R2, R3>(result1, result2, result3);
  }

  @override
  void fastParseOn(Context context) {
    parser1.fastParseOn(context);
    if (!context.isSuccess) return;
    parser2.fastParseOn(context);
    if (!context.isSuccess) return;
    parser3.fastParseOn(context);
    if (!context.isSuccess) return;
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

/// Immutable typed sequence with 3 values.
@immutable
class Sequence3<T1, T2, T3> {
  /// Constructs a sequence with 3 typed values.
  const Sequence3(this.first, this.second, this.third);

  /// Returns the first element of this sequence.
  @inlineVm
  final T1 first;

  /// Returns the second element of this sequence.
  @inlineVm
  final T2 second;

  /// Returns the third element of this sequence.
  @inlineVm
  final T3 third;

  /// Returns the last (or third) element of this sequence.
  @inlineVm
  @inlineJs
  T3 get last => third;

  /// Converts this sequence to a new type [R] with the provided [callback].
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2, T3) callback) => callback(first, second, third);

  @override
  int get hashCode => Object.hash(first, second, third);

  @override
  bool operator ==(Object other) =>
      other is Sequence3<T1, T2, T3> &&
      first == other.first &&
      second == other.second &&
      third == other.third;

  @override
  String toString() => '${super.toString()}($first, $second, $third)';
}

extension ParserSequenceExtension3<T1, T2, T3>
    on Parser<Sequence3<T1, T2, T3>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map3<R>(R Function(T1, T2, T3) callback) =>
      map((sequence) => sequence.map(callback));
}
