library petitparser.core.combinators.sequence;

import 'package:petitparser/src/core/combinators/list.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that parses a sequence of parsers.
class SequenceParser extends ListParser {
  factory SequenceParser(Iterable<Parser> children) {
    return new SequenceParser._(new List.from(children, growable: false));
  }

  SequenceParser._(List<Parser> children) : super(children);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List(children.length);
    for (var i = 0; i < children.length; i++) {
      var result = children[i].parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements[i] = result.value;
      current = result;
    }
    return current.success(elements);
  }

  @override
  Parser seq(Parser other) {
    return new SequenceParser([]
      ..addAll(children)
      ..add(other));
  }

  @override
  Parser copy() => new SequenceParser(children);
}
