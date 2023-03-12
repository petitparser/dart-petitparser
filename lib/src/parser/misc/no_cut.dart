import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';

extension NoCutParserExtension<R> on Parser<R> {
  /// Returns a parser that allows backtracking, regardless of whether cuts
  /// happen within the delegated parser.
  @useResult
  Parser<R> noCut() => NoCutParser<R>(this);
}

/// A parser that allows backtracking, regardless of whether cuts happen within
/// the delegated parser.
class NoCutParser<R> extends DelegateParser<R, R> {
  NoCutParser(super.parser);

  @override
  void parseOn(Context context) {
    final isCut = context.isCut;
    delegate.parseOn(context);
    context.isCut = isCut;
  }

  @override
  NoCutParser<R> copy() => NoCutParser<R>(delegate);
}
