import '../context/context.dart';
import '../core/parser.dart';

extension AcceptParser<R> on Parser<R> {
  /// Tests if the [input] can be successfully parsed.
  ///
  /// For example, `letter().plus().accept('abc')` returns `true`, and
  /// `letter().plus().accept('123')` returns `false`.
  bool accept(String input, {int start = 0}) {
    final context = Context(input, position: start, isSkip: true);
    parseOn(context);
    return context.isSuccess;
  }
}
