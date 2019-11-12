library petitparser.core.parsers.position;

import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';

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
