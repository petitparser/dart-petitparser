library petitparser.core.actions.flatten;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that answers a substring of the range its delegate
/// parses.
class FlattenParser extends DelegateParser {
  FlattenParser(Parser delegate) : super(delegate);

  @override
  Result parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isSuccess) {
      var output = context.buffer.substring(context.position, result.position);
      return result.success(output);
    } else {
      return result;
    }
  }

  @override
  Parser copy() => FlattenParser(delegate);
}
