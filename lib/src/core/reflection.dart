// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of core;

/** Iterable over all parsers reachable from a [root]. */
class ParserIterable extends Iterable<Parser> {

  final Parser _root;

  ParserIterable(this._root);

  ParserIterator get iterator {
    return new ParserIterator(_root);
  }

}

/** Iterator over all parsers reachable from a [root]. */
class ParserIterator implements Iterator<Parser> {

  final List<Parser> _todo;
  final Set<Parser> _done;
  Parser _current;

  ParserIterator(Parser root)
      : _todo = new List.from([root]),
        _done = new Set();

  bool moveNext() {
    if (_todo.isEmpty) {
      _current = null;
      return false;
    }
    _current = _todo.removeLast();
    _done.add(_current);
    _todo.addAll(_current.children.where((each) => !_done.contains(each)));
    return true;
  }

  Parser get current => _current;

}

/** Collection of various common transformations. */
class Transformations {

  /** Pluggable transformation starting at [root]. */
  static Parser transform(Parser root, Parser function(Parser parser)) {
    var sources = new List(), targets = new List();
    do {
      sources.clear(); targets.clear();
      var parsers = new List.from(new ParserIterable(root));
      parsers.forEach((source) {
        var target = function(source);
        if (target != null && !identical(source, target)) {
          if (identical(source, root)) {
            root = target;
          }
          sources.add(source);
          targets.add(target);
        }
      });
      parsers.forEach((parser) {
        for (var i = 0; i < sources.length; i++) {
          parser.replace(sources[i], targets[i]);
        }
      });
    } while (!sources.isEmpty);
    return root;
  }

  /** Removes all settables starting at [root]. */
  static Parser removeSetables(Parser root) {
    return transform(root, (each) {
      return each is SetableParser ? each.children[0] : each;
    });
  }

}
