library petitparser.core.actions.flatten;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that answers a substring of the range its delegate
/// parses.
class FlattenParser extends DelegateParser<String> {
  FlattenParser(Parser delegate) : super(delegate);

  @override
  Result<String> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isSuccess) {
      final output = context.buffer.substring(context.position, result.position);
      return result.success(output);
    } else {
      return result.failure(result.message);
    }
  }

  @override
  FlattenParser copy() => FlattenParser(delegate);
}
