library petitparser.core.combinators.choice;

import 'package:petitparser/src/core/combinators/list.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds.
class ChoiceParser extends ListParser {
  factory ChoiceParser(Iterable<Parser> children) {
    return new ChoiceParser._(new List.from(children, growable: false));
  }

  ChoiceParser._(List<Parser> children) : super(children);

  @override
  Result parseOn(Context context) {
    Result result;
    for (var i = 0; i < children.length; i++) {
      result = children[i].parseOn(context);
      if (result.isSuccess) {
        return result;
      }
    }
    return result;
  }

  @override
  Parser or(Parser other) {
    return new ChoiceParser(new List()
      ..addAll(children)
      ..add(other));
  }

  @override
  Parser copy() => new ChoiceParser(children);
}
