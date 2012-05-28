// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

abstract class CompositeParser extends DelegateParser {

  final Map<String, Parser> _defined = new Map();
  final Map<String, _MutableDelegateParser> _undefined = new Map();

  CompositeParser() : super(ref('start')) {
    initialize();
    _undefined.forEach((name, parser) {
      if (!_defined.containsKey(name)) {
        throw new Exception('Missing definition: $name');
      }
      parser.parser = _defined[name];
    });
  }

  Parser ref(String name) {
    return _undefined.putIfAbsent(name, () {
      return new _MutableDelegateParser();
    });
  }

  void def(String name, Parser parser) {
    if (_defined.containsKey(name)) {
      throw new Exception('Duplicated definition: $name');
    } else {
      _defined[name] = parser;
    }
  }

  void redef(String name, Function function) {
    if (!_defined.containsKey(name)) {
      throw new Exception('Invalid redefinition: $name');
    } else {
      _defined[name] = function(_defined[name]);
    }
  }

  abstract void initialize();

}

class _MutableDelegateParser extends Parser {
  Parser parser;
  _MutableDelegateParser();
  Result _parse(Context context) => parser._parse(context);
}
