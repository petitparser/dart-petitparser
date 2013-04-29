// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns an iterable over all parsers reachable from a [root].
 */
Iterable<Parser> allParser(Parser root) {
  return new _ParserIterable(root);
}

class _ParserIterable extends IterableBase<Parser> {
  final Parser _root;
  const _ParserIterable(this._root);
  Iterator<Parser> get iterator => new _ParserIterator(_root);
}

class _ParserIterator implements Iterator<Parser> {
  final List<Parser> _todo;
  final Set<Parser> _done;
  Parser current;
  _ParserIterator(Parser root)
      : _todo = new List.from([root]),
        _done = new Set();
  bool moveNext() {
    if (_todo.isEmpty) {
      current = null;
      return false;
    }
    _done.add(current = _todo.removeLast());
    _todo.addAll(current.children.where((each) => !_done.contains(each)));
    return true;
  }
}

/**
 * Transforms all parsers reachable from [root] with the given [function].
 * The identity function returns a copy of the the incoming parser.
 *
 * The implementation first creates a copy of each parser reachable in the
 * input grammar; then the resulting grammar is iteratively transfered and
 * all old parsers are replaced with the transformed ones until we end up
 * with a completely new grammar.
 */
Parser transformParser(Parser root, Parser function(Parser parser)) {
  var mapping = new Map();
  allParser(root).forEach((parser) {
    mapping[parser] = function(parser.copy());
  });
  while (true) {
    var changed = false;
    allParser(mapping[root]).forEach((parser) {
      parser.children.forEach((source) {
        if (mapping.containsKey(source)) {
          parser.replace(source, mapping[source]);
          changed = true;
        }
      });
    });
    if (!changed) {
      return mapping[root];
    }
  }
}

/**
 * Removes all setable parsers reachable from [root] in-place.
 */
Parser removeSetables(Parser root) {
  allParser(root).forEach((parent) {
    parent.children.forEach((source) {
      var target = _removeSetable(source);
      if (source != target) {
        parent.replace(source, target);
      }
    });
  });
  return _removeSetable(root);
}

Parser _removeSetable(Parser parser) {
  while (parser is SetableParser) {
    parser = parser.children.first;
  }
  return parser;
}

/**
 * Removes duplicated parsers reachable from [root] in-place.
 */
Parser removeDuplicates(Parser root) {
  var uniques = new Set();
  allParser(root).forEach((parent) {
    parent.children.forEach((source) {
      var target = uniques.firstWhere((each) {
        return source != each && source.match(each);
      }, orElse: () => null);
      if (target == null) {
        uniques.add(source);
      } else {
        parent.replace(source, target);
      }
    });
  });
  return root;
}

/**
 * Adds debug handlers to each parser reachable from [root].
 */
Parser debug(Parser root) {
  var level = 0;
  return transformParser(root, (parser) {
    return new _ContinuationParser(parser, (context, continuation) {
      print('${_debugIndent(level)}${parser}');
      level++;
      var result = continuation(context);
      level--;
      print('${_debugIndent(level)}${result}');
      return result;
     });
  });
}

String _debugIndent(int level) {
  var result = new StringBuffer();
  for (var i = 0; i < level; i++) {
    result.write('  ');
  }
  return result.toString();
}

class _ContinuationParser extends _DelegateParser {
  final Function _function;
  _ContinuationParser(parser, this._function) : super(parser);
  Result _parse(Context context) {
    return _function(context, (result) => _delegate._parse(result));
  }
  Parser copy() => new _ContinuationParser(_delegate, _function);
}
