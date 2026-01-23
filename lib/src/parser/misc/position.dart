import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';

/// Returns a parser that reports the current input position.
///
/// For example, the parser `position()` returns the current index in the
/// input string.
@useResult
Parser position() => PositionParser();

/// A parser that reports the current input position.
class PositionParser extends Parser<int> {
  PositionParser();

  @override
  Result<int> parseOn(Context context) => context.success(context.position);

  @override
  int fastParseOn(String buffer, int position) => position;

  @override
  PositionParser copy() => PositionParser();
}
