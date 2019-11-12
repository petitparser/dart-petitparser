library petitparser.reflection.iterable;

import '../core/parser.dart';

/// Returns a lazy iterable over all parsers reachable from a [root].
///
/// For example, the following code prints the two parsers of the
/// defined grammar:
///
///     final parser = range('0', '9').star();
///     allParser(parser).forEach((each) {
///       print(each);
///     });
///
Iterable<Parser> allParser(Parser root) sync* {
  final todo = [root];
  final seen = Set.of(todo);
  while (todo.isNotEmpty) {
    final current = todo.removeLast();
    yield current;
    for (final parser in current.children) {
      if (!seen.contains(parser)) {
        todo.add(parser);
        seen.add(parser);
      }
    }
  }
}
