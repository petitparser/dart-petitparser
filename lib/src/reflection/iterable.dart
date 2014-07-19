part of reflection;

/**
 * Returns a lazy iterable over all parsers reachable from a [root].
 *
 * For example, the following code prints the two parsers of the
 * defined grammar:
 *
 *   var parser = range('0', '9').star();
 *   allParser(parser).forEach((each) {
 *     print(each);
 *   });
 *
 */
Iterable<Parser> allParser(Parser root) => new _ParserIterable(root);

class _ParserIterable extends IterableBase<Parser> {

  final Parser root;

  _ParserIterable(this.root);

  @override
  Iterator<Parser> get iterator => new _ParserIterator([root]);

}

class _ParserIterator implements Iterator<Parser> {

  final List<Parser> todo;
  final Set<Parser> seen;

  Parser current;

  _ParserIterator(Iterable<Parser> roots)
      : todo = new List.from(roots),
        seen = new Set.from(roots);

  @override
  bool moveNext() {
    if (todo.isEmpty) {
      current = null;
      return false;
    } else {
      current = todo.removeLast();
      current.children.forEach((each) {
        if (!seen.contains(each)) {
          todo.add(each);
          seen.add(each);
        }
      });
      return true;
    }
  }

}
