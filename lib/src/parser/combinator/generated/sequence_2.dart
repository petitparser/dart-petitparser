// AUTO-GENERATED CODE: DO NOT EDIT

import 'package:meta/meta.dart';

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';
import '../../action/map.dart';
import '../../utils/sequential.dart';

/// Creates a parser that consumes a sequence of 2 parsers and returns a
/// typed sequence [Sequence2].
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
  Result<Sequence2<R1, R2>> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1.isFailure) return result1.failure(result1.message);
    final result2 = parser2.parseOn(result1);
    if (result2.isFailure) return result2.failure(result2.message);
    return result2.success(Sequence2<R1, R2>(result1.value, result2.value));
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

/// Immutable typed sequence with 2 values.
@immutable
class Sequence2<T1, T2> {
  Sequence2(this.value1, this.value2);

  final T1 value1;
  final T2 value2;

  @override
  int get hashCode => Object.hash(value1, value2);

  @override
  bool operator ==(Object other) =>
      other is Sequence2<T1, T2> &&
      value1 == other.value1 &&
      value2 == other.value2;

  @override
  String toString() => '${super.toString()}($value1, $value2)';
}

extension ParserSequenceExtension2<T1, T2> on Parser<Sequence2<T1, T2>> {
  /// Maps a typed sequence to [R] using the provided [callback].
  Parser<R> map2<R>(R Function(T1, T2) callback) =>
      map((sequence) => callback(sequence.value1, sequence.value2));
}
