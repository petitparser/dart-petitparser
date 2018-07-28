library petitparser.core.actions.mapped;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that performs a transformation with a given function on the
/// successful parse result of the delegate.
class ActionParser extends DelegateParser {
  final Function _function;

  ActionParser(Parser delegate, this._function) : super(delegate);

  @override
  Result parseOn(Context context) {
    var result = delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(_function(result.value));
    } else {
      return result;
    }
  }

  @override
  Parser copy() => ActionParser(delegate, _function);

  @override
  bool hasEqualProperties(Parser other) {
    return other is ActionParser &&
        super.hasEqualProperties(other) &&
        _function == other._function;
  }
}
