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
  final List<Parser> _done;

  ParserIterator(Parser root)
      : _todo = new List.from([root]),
        _done = new List();

  bool hasNext() {
    return !_todo.isEmpty();
  }

  Parser next() {
    if (_todo.isEmpty()) {
      throw const NoMoreElementsException();
    }
    var parser = _todo.removeLast();
    _done.add(parser);
    _todo.addAll(parser.children.filter((each) => _done.indexOf(each) == -1));
    return parser;
  }

}

/** Collection of various common transformations. */
class Transformations {

  /** Pluggable transformation starting at [root]. */
  static Parser transform(Parser root, Parser function(Parser parser)) {
    var mapping = new Map();
    for (var parser in new ParserIterable(root)) {
      // TODO(renggli): need to copy parser, but how?
      mapping[parser] = function(parser);
    }
    bool changed;
    root = mapping[root];
    do {
      changed = false;
      for (var parent in new ParserIterable(root)) {
        for (var oldParser in parent.children) {
          var newParser = mapping[oldParser];
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
    // TODO(renggli): replace with exact class check
    transform(root, (each) => each is WrapperParser ? each.children[0] : each);
  }

}