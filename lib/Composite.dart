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
    if (_defined.containsKey(name)) {
      return _defined[name];
    }
    if (_undefined.containsKey(name)) {
      return _undefined[name];
    }
    Parser parser = new FailureParser('Undefined parser: $name');
    return _undefined[name] = new _MutableDelegateParser(parser);
  }

  void def(String name, Parser parser) {
    if (_defined.containsKey(name)) {
      throw new Exception('Repeated definition: $name');
    } else {
      _defined[name] = parser;
    }
  }

  abstract void initialize();

}

class _MutableDelegateParser extends Parser {
  Parser parser;
  _MutableDelegateParser(this.parser);
  Result _parse(Context context) => parser._parse(context);
}
