library petitparser.core.parsers.position;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that succeeds at the end of input.
class PositionParser extends Parser<int> {
  const PositionParser();

  @override
  Result<int> parseOn(Context context) => context.success(context.position);

  @override
  PositionParser copy() => this;
}
