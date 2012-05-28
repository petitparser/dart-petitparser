// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

abstract class CompositeParser extends _MutableDelegateParser {

  final Map<String, Parser> _defined;
  final Map<String, _MutableDelegateParser> _undefined;

  CompositeParser()
    : _defined = new Map(),
      _undefined = new Map() {
    initialize();
    _parser = ref('start');
    _undefined.forEach((name, parser) {
      if (!_defined.containsKey(name)) {
        throw new Exception('Missing production definition: $name');
      }
      parser._parser = _defined[name];
    });
  }

  /** Returns a reference to a production with a [name]. */
  Parser ref(String name) {
    return _undefined.putIfAbsent(name, () {
      return new _MutableDelegateParser();
    });
  }

  /** Defines a production with a [name] and a [parser]. */
  void define(String name, Parser parser) {
    if (_defined.containsKey(name)) {
      throw new Exception('Duplicate production: $name');
    } else {
      _defined[name] = parser;
    }
  }

  /** Redefinies an existing production with a [name] and a [function] producing a new parser. */
  void redefine(String name, Parser function(Parser)) {
    if (!_defined.containsKey(name)) {
      throw new Exception('Unknown production: $name');
    } else {
      _defined[name] = function(_defined[name]);
    }
  }

  /** Attaches an action to an existing production. */
  void attach(String name, Function function) {
    redefine(name, (parser) => parser.map(function));
  }

  /** Initializes the composite grammar. */
  abstract void initialize();

}

class _MutableDelegateParser extends Parser {
  Parser _parser;
  _MutableDelegateParser();
  Result _parse(Context context) => _parser._parse(context);
}
