// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a lazy iterable over all parsers reachable from a [root]. Do
 * not modify the grammar while iterating over it, otherwise you might
 * get unexpected results.
 */
Iterable<Parser> allParser(Parser root) {
  return new _ParserIterable(root);
}

class _ParserIterable extends IterableBase<Parser> {

  final Parser _root;

  const _ParserIterable(this._root);

  @override
  Iterator<Parser> get iterator => new _ParserIterator(_root);

}

class _ParserIterator implements Iterator<Parser> {

  final List<Parser> _todo;
  final Set<Parser> _done;

  Parser current;

  _ParserIterator(Parser root)
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
      print('${_repeat(level, '  ')}${parser}');
      level++;
      var result = continuation(context);
      level--;
      print('${_repeat(level, '  ')}${result}');
      return result;
     });
  });
}

String _repeat(int count, String value) {
  var result = new StringBuffer();
  for (var i = 0; i < count; i++) {
    result.write(value);
  }
  return result.toString();
}

/**
 * Adds progress handlers to each parser reachable from [root].
 */
Parser progress(Parser root) {
  return transformParser(root, (parser) {
    return new _ContinuationParser(parser, (context, continuation) {
      print('${_repeat(context.position, '*')} $parser');
      return continuation(context);
    });
  });
}

/**
 * Adds profiling handlers to each parser reachable from [root].
 */
Parser profile(Parser root) {
  var count = new Map();
  var watch = new Map();
  var parsers = new List();
  return new _ContinuationParser(transformParser(root, (parser) {
    parsers.add(parser);
    return new _ContinuationParser(parser, (context, continuation) {
      count[parser]++;
      watch[parser].start();
      var result = continuation(context);
      watch[parser].stop();
      return result;
     });
  }), (context, continuation) {
    parsers.forEach((parser) {
      count[parser] = 0;
      watch[parser] = new Stopwatch();
    });
    var result = continuation(context);
    parsers.forEach((parser) {
      print('${count[parser]}\t'
        '${watch[parser].elapsedMicroseconds}\t'
        '${parser}');
    });
    return result;
  });
}

typedef Result _ContinuationHandler(Context context, Function continuation);

class _ContinuationParser extends DelegateParser {

  final _ContinuationHandler _handler;

  _ContinuationParser(parser, this._handler) : super(parser);

  @override
  Result parseOn(Context context) {
    return _handler(context, (result) => _delegate.parseOn(result));
  }

  @override
  Parser copy() => new _ContinuationParser(_delegate, _handler);

}
