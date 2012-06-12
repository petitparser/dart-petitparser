// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Helper to compose complex grammars from various primitive parsers. To create
 * a new complex grammar subclass {@link CompositeParser}. Override the method
 * [initialize()] and for every production call [define(String, Parser)] giving
 * the parsers a name. The start production must be named 'start'. To refer to
 * other produtions use [ref(String)].
 */
abstract class CompositeParser extends DelegateParser {

  final Map<String, Parser> _defined;
  final Map<String, DelegateParser> _undefined;

  CompositeParser()
    : super(null),
      _defined = new Map(),
      _undefined = new Map() {
    initialize();
    _delegate = ref('start');
    _undefined.forEach((String name, DelegateParser parser) {
      if (!_defined.containsKey(name)) {
        throw new Exception('Missing production: $name');
      }
      parser._delegate = _defined[name];
    });
    // TODO(renggli): remove the delegates as soon as dart allows object copying
    replace(children[0], ref('start'));
  }

  /** Returns a reference to a production with a [name]. */
  Parser ref(String name) {
    return _undefined.putIfAbsent(name, () {
      return new FailureParser('Uninitalized production: $name').wrapper();
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

  /** Attaches an action [function] to an existing production [name]. */
  void action(String name, Dynamic function(Dynamic)) {
    redefine(name, (parser) => parser.map(function));
  }

  /** Initializes the composite grammar. */
  abstract void initialize();

}