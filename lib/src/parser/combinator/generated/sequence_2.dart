// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../core/parser.dart';
import '../../../shared/annotations.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 2 parsers and returns a
/// typed sequence [Sequence2].
@useResult
Parser<Sequence2<R1, R2>> seq2<R1, R2>(
  Parser<R1> parser1,
  Parser<R2> parser2,
) =>
    SequenceParser2<R1, R2>(
      parser1,
      parser2,
    );

/// A parser that consumes a sequence of 2 typed parsers and returns a typed
/// sequence [Sequence2].
class SequenceParser2<R1, R2> extends Parser<Sequence2<R1, R2>>
    implements SequentialParser {
  SequenceParser2(this.parser1, this.parser2);

  Parser<R1> parser1;
  Parser<R2> parser2;

  @override
  void parseOn(Context context) {
    parser1.parseOn(context);
    if (!context.isSuccess) return;
    final result1 = context.value as R1;
    parser2.parseOn(context);
    if (!context.isSuccess) return;
    final result2 = context.value as R2;
    context.value = Sequence2<R1, R2>(result1, result2);
  }

  @override
  void fastParseOn(Context context) {
    parser1.fastParseOn(context);
    if (!context.isSuccess) return;
    parser2.fastParseOn(context);
    if (!context.isSuccess) return;
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

/// Immutable typed sequence with 2 values.
@immutable
class Sequence2<T1, T2> {
  /// Constructs a sequence with 2 typed values.
  const Sequence2(this.first, this.second);

  /// Returns the first element of this sequence.
  @inlineVm
  final T1 first;

  /// Returns the second element of this sequence.
  @inlineVm
  final T2 second;

  /// Returns the last (or second) element of this sequence.
  @inlineVm
  @inlineJs
  T2 get last => second;

  /// Converts this sequence to a new type [R] with the provided [callback].
  @inlineVm
  @inlineJs
  R map<R>(R Function(T1, T2) callback) => callback(first, second);

  @override
  int get hashCode => Object.hash(first, second);

  @override
  bool operator ==(Object other) =>
      other is Sequence2<T1, T2> &&
      first == other.first &&
      second == other.second;

  @override
  String toString() => '${super.toString()}($first, $second)';
}

extension ParserSequenceExtension2<T1, T2> on Parser<Sequence2<T1, T2>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map2<R>(R Function(T1, T2) callback) =>
      map((sequence) => sequence.map(callback));
}
