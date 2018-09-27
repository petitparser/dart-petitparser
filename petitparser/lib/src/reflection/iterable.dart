library petitparser.reflection.iterable;

import 'dart:collection';

import 'package:petitparser/src/core/parser.dart';

/// Returns a lazy iterable over all parsers reachable from a [root].
///
/// For example, the following code prints the two parsers of the
/// defined grammar:
///
///     var parser = range('0', '9').star();
///     allParser(parser).forEach((each) {
///       print(each);
///     });
///
Iterable<Parser> allParser(Parser root) => ParserIterable(root);

class ParserIterable extends IterableBase<Parser> {
  final Parser root;

  ParserIterable(this.root);

  @override
  Iterator<Parser> get iterator => ParserIterator([root]);
}

class ParserIterator implements Iterator<Parser> {
  final List<Parser> todo;
  final Set<Parser> seen;

  ParserIterator(Iterable<Parser> roots)
      : todo = List.of(roots),
        seen = Set.of(roots);

  @override
  Parser current;

  @override
  bool moveNext() {
    if (todo.isEmpty) {
      current = null;
      return false;
    }
    current = todo.removeLast();
    for (var parser in current.children) {
      if (!seen.contains(parser)) {
        todo.add(parser);
        seen.add(parser);
      }
    }
    return true;
  }
}
