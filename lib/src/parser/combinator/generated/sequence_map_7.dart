// AUTO-GENERATED CODE: DO NOT EDIT

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';

/// A parser that consumes a sequence of 7 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
class SequenceMapParser7<R1, R2, R3, R4, R5, R6, R7, R> extends Parser<R> {
  SequenceMapParser7(this.parser1, this.parser2, this.parser3, this.parser4,
      this.parser5, this.parser6, this.parser7, this.callback);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  Parser<R4> parser4;
  Parser<R5> parser5;
  Parser<R6> parser6;
  Parser<R7> parser7;
  final R Function(R1, R2, R3, R4, R5, R6, R7) callback;

  @override
  Result<R> parseOn(Context context) {
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
    return result7.success(callback(result1.value, result2.value, result3.value,
        result4.value, result5.value, result6.value, result7.value));
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
  SequenceMapParser7<R1, R2, R3, R4, R5, R6, R7, R> copy() =>
      SequenceMapParser7<R1, R2, R3, R4, R5, R6, R7, R>(parser1, parser2,
          parser3, parser4, parser5, parser6, parser7, callback);
}
