// AUTO-GENERATED CODE: DO NOT EDIT

import '../../../context/context.dart';
import '../../../context/result.dart';
import '../../../core/parser.dart';
import '../../utils/sequential.dart';

/// A parser that consumes a sequence of 2 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
class SequenceMapParser2<R1, R2, R> extends Parser<R>
    implements SequentialParser {
  SequenceMapParser2(this.parser1, this.parser2, this.callback);

  Parser<R1> parser1;
  Parser<R2> parser2;
  final R Function(R1, R2) callback;

  @override
  Result<R> parseOn(Context context) {
    final result1 = parser1.parseOn(context);
    if (result1.isFailure) return result1.failure(result1.message);
    final result2 = parser2.parseOn(result1);
    if (result2.isFailure) return result2.failure(result2.message);
    return result2.success(callback(result1.value, result2.value));
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
  SequenceMapParser2<R1, R2, R> copy() =>
      SequenceMapParser2<R1, R2, R>(parser1, parser2, callback);
}
