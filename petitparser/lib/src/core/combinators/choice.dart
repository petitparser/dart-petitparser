library petitparser.core.combinators.choice;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';
import 'list.dart';

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
    var result = -1;
    for (final parser in children) {
      result = parser.fastParseOn(buffer, position);
      if (result >= 0) {
        return result;
      }
    }
    return result;
  }

  @override
  Parser or(Parser other) => ChoiceParser([...children, other]);

  @override
  ChoiceParser copy() => ChoiceParser(children);
}
