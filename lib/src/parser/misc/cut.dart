import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/skip.dart';

extension CutParserExtension<R> on Parser<R> {
  /// Returns a parser that marks the parsed result as non-backtrackable, by
  /// invoking the [cut] operator after a successful parse.
  @useResult
  Parser<R> commit() => skip(after: cut());
}

/// Returns a parser that marks subsequent parses as non-backtrackable.
@useResult
Parser<void> cut() => CutParser();

/// A parser that prevents backtracking before this point.
class CutParser extends Parser<void> {
  CutParser();

  @override
  void parseOn(Context context) {
    context.value = null;
    context.isCut = true;
  }

  @override
  CutParser copy() => CutParser();
}
