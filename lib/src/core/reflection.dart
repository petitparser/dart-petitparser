// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Iterable over all parsers reachable from a [root].
 */
class ParserIterable extends Iterable<Parser> {

  final Parser _root;

  ParserIterable(this._root);

  ParserIterator get iterator {
    return new ParserIterator(_root);
  }

}

/**
 * Iterator over all parsers reachable from a [root].
 */
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

/**
 * Collection of various common transformations.
 */
class Transformations {

  /**
   * Transforms all parsers reachable from [root] with the given [function].
   */
  static Parser transform(Parser root, Parser function(Parser parser)) {
    var mapping = new Map(), transformed = new Set();
    do {
      mapping.clear();
      var parsers = new ParserIterable(root).toList();
      parsers.forEach((source) {
        if (!transformed.contains(source)) {
          var target = function(source);
          if (target != null && !identical(source, target)) {
            if (identical(source, root)) {
              root = target;
            }
            mapping[source] = target;
          }
          transformed.add(source);
        }
      });
      parsers.forEach((parser) {
        mapping.forEach((previous, next) {
          parser.replace(previous, next);
        });
      });
    } while (!mapping.isEmpty);
    return root;
  }

  /**
   * Removes all setable parsers reachable from [root].
   */
  static Parser removeSetables(Parser root) {
    return transform(root, (parser) {
      return parser is SetableParser ? parser.children[0] : parser;
    });
  }

  /**
   * Adds debug handlers to each parser reachable from [root].
   */
  static Parser debug(Parser root) {
    var level = 0;
    return transform(root, (parser) {
      return parser is _PluggableParser
          ? parser
          : new _PluggableParser((context) {
              print('${_indent(level)}${parser}');
              level++;
              var result = parser._parse(context);
              level--;
              print('${_indent(level)}${result}');
              return result;
       });
    });
  }

  static String _indent(int level) {
    var result = new StringBuffer();
    for (var i = 0; i < level; i++) {
      result.write('  ');
    }
    return result.toString();
  }

}

/**
 * A pluggable parser taking block as parse action (use sparingly).
 */
class _PluggableParser extends Parser {

  final Function _function;

  _PluggableParser(this._function);

  Result _parse(Context context) => _function(context);

}
