// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

// This is not working yet, please ignore or see README.md

/** Iterable over all parsers reachable from a [root]. */
class ParserIterable implements Iterable<Parser> {

  final Parser _root;

  ParserIterable(this._root);

  ParserIterator iterator() {
    return new ParserIterator(_root);
  }

}

/** Iterator over all parsers reachable from a [root]. */
class ParserIterator implements Iterator<Parser> {

  final List<Parser> _todo;
  final Set<Parser> _done;

  ParserIterator(Parser root)
      : _todo = new List.from([root]),
        _done = new Set();

  bool hasNext() {
    return !_todo.isEmpty();
  }

  Parser next() {
    if (_todo.isEmpty()) {
      throw const NoMoreElementsException();
    }
    Parser parser = _todo.removeLast();
    _done.add(parser);
    _todo.addAll(parser.children.filter((each) => !_done.contains(each)));
    return parser;
  }

}

/** Collection of various common transformations. */
class Transformations {

  /** Pluggable transformation starting at [root]. */
  static Parser transform(Parser root, Function function) {
    Map<Parser, Parser> mapping = new Map();
    for (Parser parser in new ParserIterable(root)) {
      mapping[parser] = function(parser.copy());
    }
    bool changed;
    root = mapping[root];
    do {
      changed = false;
      for (Parser parent in new ParserIterable(root)) {
        for (Parser oldParser in parent.children) {
          Parser newParser = mapping[oldParser];
          if (newParser != null) {
            parent.replace(oldParser, newParser);
            changed = true;
          }
        }
      }
    } while (changed);
    return root;
  }

  /** Removes all wrappers starting at [root]. */
  static Parser removeWrappers(Parser root) {
    transform(root, (Parser each) => each is WrapperParser ? each.children[0] : each);
  }

}