library petitparser.core.combinators.choice_custom_failure;

import 'package:petitparser/src/core/combinators/choice.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds, if none succeeds returns
/// a custom failure at the beginning of the choice.
class ChoiceParserWithCustomFailure extends ChoiceParser {
  ChoiceParserWithCustomFailure(Iterable<Parser> children, this.failureMessage)
      : super.of(children);

  final String failureMessage;

  @override
  Result parseOn(Context context) {
    for (var i = 0; i < children.length; i++) {
      final current = children[i].parseOn(context);
      if (current.isSuccess) {
        return current;
      }
    }
    return context.failure(failureMessage);
  }

  @override
  ChoiceParser or(Parser other) => ChoiceParserWithCustomFailure(
      []
        ..addAll(children)
        ..add(other),
      failureMessage);

  @override
  bool hasEqualProperties(ChoiceParserWithCustomFailure other) =>
      super.hasEqualProperties(other) && failureMessage == other.failureMessage;

  @override
  ChoiceParserWithCustomFailure copy() =>
      ChoiceParserWithCustomFailure(children, failureMessage);
}
