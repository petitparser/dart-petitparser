library petitparser.parser.misc.position;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';

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
