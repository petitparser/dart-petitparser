library petitparser.core.combinators.sequence;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'list.dart';

/// A parser that parses a sequence of parsers.
class SequenceParser extends ListParser<List> {
  SequenceParser(Iterable<Parser> children) : super(children);

  @override
  Result<List> parseOn(Context context) {
    var current = context;
    final elements = List(children.length);
    for (var i = 0; i < children.length; i++) {
      final result = children[i].parseOn(current);
      if (result.isFailure) {
        return result.failure(result.message);
      }
      elements[i] = result.value;
      current = result;
    }
    return current.success(elements);
  }

  @override
  int fastParseOn(String buffer, int position) {
    for (final parser in children) {
      position = parser.fastParseOn(buffer, position);
      if (position < 0) {
        return position;
      }
    }
    return position;
  }

  @override
  Parser<List> seq(Parser other) => SequenceParser([...children, other]);

  @override
  SequenceParser copy() => SequenceParser(children);
}
