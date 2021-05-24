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
Iterable<Parser> allParser(Parser root) => _ParserIterable(root);

class _ParserIterable extends Iterable<Parser> {
  final Parser root;

  _ParserIterable(this.root);

  @override
  Iterator<Parser> get iterator => _ParserIterator(root);
}

class _ParserIterator extends Iterator<Parser> {
  final List<Parser> todo;
  final Set<Parser> seen;

  @override
  late Parser current;

  _ParserIterator(Parser root)
      : todo = [root],
        seen = {root};

  bool moveNext() {
    if (todo.isEmpty) {
      return false;
    }
    current = todo.removeLast();
    for (final parser in current.children) {
      if (seen.add(parser)) {
        todo.add(parser);
      }
    }
    return true;
  }
}
