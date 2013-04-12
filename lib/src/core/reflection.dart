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
    var mapping = new Map();
    new ParserIterable(root).forEach((parser) {
      mapping[parser] = function(parser.copy());
    });
    while (true) {
      var changed = false;
      new ParserIterable(mapping[root]).forEach((parser) {
        parser.children.forEach((source) {
          if (mapping.containsKey(source)) {
            parser.replace(source, mapping[source]);
          }
        });
      });
      if (!changed) {
        return mapping[root];
      }
    }
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
      return new _ContinuationParser(parser, (context, continuation) {
        print('${_indent(level)}${parser}');
        level++;
        var result = continuation(context);
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
 * A delegate parser continuation-passing-style (CPS).
 */
class _ContinuationParser extends _DelegateParser {
  final Function _function;
  _ContinuationParser(parser, this._function) : super(parser);
  Result _parse(Context context) {
    return _function(context, (result) => super._parse(result));
  }
  Parser copy() => new _ContinuationParser(_delegate, _function);
}
