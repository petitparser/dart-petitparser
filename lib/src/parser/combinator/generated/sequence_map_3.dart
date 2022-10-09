// AUTO-GENERATED CODE: DO NOT EDIT

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';

/// A parser that consumes a sequence of 3 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
class SequenceMapParser3<R1, R2, R3, R> extends Parser<R> {
  SequenceMapParser3(this.parser1, this.parser2, this.parser3, this.callback);

  Parser<R1> parser1;
  Parser<R2> parser2;
  Parser<R3> parser3;
  final R Function(R1, R2, R3) callback;

  @override
  Result<R> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1.isFailure) return result1.failure(result1.message);
    final result2 = parser2.parseOn(result1);
    if (result2.isFailure) return result2.failure(result2.message);
    final result3 = parser3.parseOn(result2);
    if (result3.isFailure) return result3.failure(result3.message);
    return result3
        .success(callback(result1.value, result2.value, result3.value));
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
  SequenceMapParser3<R1, R2, R3, R> copy() =>
      SequenceMapParser3<R1, R2, R3, R>(parser1, parser2, parser3, callback);
}
