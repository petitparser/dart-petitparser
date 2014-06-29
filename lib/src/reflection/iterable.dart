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
Iterable<Parser> allParser(Parser root) => new ParserIterable(root);

class ParserIterable extends IterableBase<Parser> {

  final Parser root;

  ParserIterable(this.root);

  @override
  Iterator<Parser> get iterator => new ParserIterator(root);

}

class ParserIterator implements Iterator<Parser> {

  final List<Parser> todo;
  final Set<Parser> done;

  Parser current;

  ParserIterator(Parser root)
      : todo = new List.from([root]),
        done = new Set();

  @override
  bool moveNext() {
    do {
      if (todo.isEmpty) {
        current = null;
        return false;
      }
      current = todo.removeLast();
    } while (done.contains(current));
    done.add(current);
    todo.addAll(current.children);
    return true;
  }

}