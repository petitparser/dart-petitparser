library petitparser.core.combinators.choice_first_failure;

import 'package:petitparser/src/core/combinators/choice.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds, if none succeeds returns
/// the first failure.
class ChoiceParserWithFirstFailure extends ChoiceParser {
  ChoiceParserWithFirstFailure(Iterable<Parser> children) : super.of(children);

  @override
  Result parseOn(Context context) {
    Result result;
    for (var i = 0; i < children.length; i++) {
      final current = children[i].parseOn(context);
      if (current.isSuccess) {
        return current;
      }
      if (i == 0) {
        result = current;
      }
    }
    return result;
  }

  @override
  ChoiceParser or(Parser other) => ChoiceParserWithFirstFailure([]
    ..addAll(children)
    ..add(other));

  @override
  ChoiceParserWithFirstFailure copy() => ChoiceParserWithFirstFailure(children);
}
