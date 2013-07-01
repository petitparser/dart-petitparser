// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a lazy iterable over all parsers reachable from a [root]. Do
 * not modify the grammar while iterating over it, otherwise you might
 * get unexpected results.
 */
Iterable<ParserBuilder> allParser(ParserBuilder root) {
  return new _ParserIterable(root);
}

class _ParserIterable extends IterableBase<ParserBuilder> {

  final ParserBuilder _root;

  const _ParserIterable(this._root);

  @override
  Iterator<ParserBuilder> get iterator => new _ParserIterator(_root);

}

class _ParserIterator implements Iterator<ParserBuilder> {

  final List<ParserBuilder> _todo;
  final Set<ParserBuilder> _done;
  ParserBuilder current;

  _ParserIterator(ParserBuilder root)
      : _todo = new List.from([root]),
        _done = new Set();

  @override
  bool moveNext() {
    do {
      if (_todo.isEmpty) {
        current = null;
        return false;
      }
      current = _todo.removeLast();
    } while (_done.contains(current));
    _done.add(current);
    _todo.addAll(current.children);
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
ParserBuilder transformParser(ParserBuilder root, ParserBuilder function(ParserBuilder parser)) {
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
ParserBuilder removeSetables(ParserBuilder root) {
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

ParserBuilder _removeSetable(ParserBuilder parser) {
  while (parser is SetableParser) {
    parser = parser.children.first;
  }
  return parser;
}

/**
 * Removes duplicated parsers reachable from [root] in-place.
 */
ParserBuilder removeDuplicates(ParserBuilder root) {
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
ParserBuilder debug(ParserBuilder root) {
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

class _ContinuationParser extends DelegateParser {

  final Function _function;

  _ContinuationParser(parser, this._function) : super(parser);

  @override
  Result parseOn(Context context) {
    return _function(context, (result) => super.parseOn(result));
  }

  @override
  ParserBuilder copy() => new _ContinuationParser(_delegate, _function);

}
