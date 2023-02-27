import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/skip.dart';
import 'epsilon.dart';

extension CutParserExtension<R> on Parser<R> {
  /// Returns a parser that marks the parsed result as non-backtrackable.
  @useResult
  Parser<R> commit() => skip(after: cut());
}

/// Returns a parser that marks subsequent parses as non-backtrackable.
@useResult
Parser<void> cut() => CutParser();

/// A parser that prevents backtracking before this point.
class CutParser extends EpsilonParser<void> {
  CutParser() : super(null);

  @override
  void parseOn(Context context) {
    context.value = null;
    context.isCut = true;
  }

  @override
  void fastParseOn(Context context) {
    context.isCut = true;
  }

  @override
  CutParser copy() => CutParser();
}
