library petitparser.core.parsers.position;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Returns a parser that reports the current input position.
Parser position() => const PositionParser();

/// A parser that reports the current input position.
class PositionParser extends Parser<int> {
  const PositionParser();

  @override
  Result<int> parseOn(Context context) => context.success(context.position);

  @override
  int fastParseOn(String buffer, int position) => position;

  @override
  PositionParser copy() => this;
}
