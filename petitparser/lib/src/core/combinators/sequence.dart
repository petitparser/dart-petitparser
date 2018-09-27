library petitparser.core.combinators.sequence;

import 'package:petitparser/src/core/combinators/list.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that parses a sequence of parsers.
class SequenceParser extends ListParser<List> {
  factory SequenceParser(Iterable<Parser> children) {
    return SequenceParser._(List.of(children, growable: false));
  }

  SequenceParser._(List<Parser> children) : super(children);

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
  Parser<List> seq(Parser other) => SequenceParser([]
    ..addAll(children)
    ..add(other));

  @override
  SequenceParser copy() => SequenceParser(children);
}
