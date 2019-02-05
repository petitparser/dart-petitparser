library petitparser.core.combinators.choice;

import 'package:petitparser/src/core/combinators/list.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds.
class ChoiceParser extends ListParser {
  ChoiceParser(Iterable<Parser> children) : super(children) {
    if (children.isEmpty) {
      throw ArgumentError('Choice parser cannot be empty.');
    }
  }

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
  int fastParseOn(String buffer, int position) {
    int result;
    for (var parser in children) {
      result = parser.fastParseOn(buffer, position);
      if (result >= 0) {
        return result;
      }
    }
    return result;
  }

  @override
  Parser or(Parser other) => ChoiceParser([]
    ..addAll(children)
    ..add(other));

  @override
  ChoiceParser copy() => ChoiceParser(children);
}
