library petitparser.core.combinators.choice_last_failure;

import 'package:petitparser/src/core/combinators/choice.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds, if none succeeds returns
/// the first failure.
class ChoiceParserWithLastFailure extends ChoiceParser {
  ChoiceParserWithLastFailure(Iterable<Parser> children) : super.of(children);

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
  ChoiceParser or(Parser other) => ChoiceParserWithLastFailure([]
    ..addAll(children)
    ..add(other));

  @override
  ChoiceParserWithLastFailure copy() => ChoiceParserWithLastFailure(children);
}
