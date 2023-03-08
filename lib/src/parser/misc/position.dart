import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';

/// Returns a parser that reports the current input position.
@useResult
Parser position() => PositionParser();

/// A parser that reports the current input position.
class PositionParser extends Parser<int> {
  PositionParser();

  @override
  void parseOn(Context context) {
    context.isSuccess = true;
    context.value = context.position;
  }

  @override
  PositionParser copy() => PositionParser();
}
