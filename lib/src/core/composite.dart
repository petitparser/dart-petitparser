// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Helper to compose complex grammars from various primitive parsers.
 *
 * To create a new composite grammar subclass [CompositeParser]. Override
 * the method [initialize] and for every production call [def] giving the
 * parsers a name. The start production must be named 'start'. To refer to
 * other produtions use [ref]. To redefine or attach actions to productions
 * use [redef] and [action].
 */
class CompositeParser extends DelegateParser {

  final Map<String, Parser> _defined;
  final Map<String, WrapperParser> _undefined;

  CompositeParser()
      : super(failure('Uninitalized production: start')),
        _defined = new Map(),
        _undefined = new Map() {
    initialize();
    _delegate = ref('start');
    _undefined.forEach((String name, WrapperParser parser) {
      if (!_defined.containsKey(name)) {
        throw new StateError('Undefined production: $name');
      }
      parser._delegate = _defined[name];
    });
    replace(children[0], Transformations.removeWrappers(ref('start')));
  }

  /** Initializes the composite grammar. */
  abstract void initialize();

  /** Returns a reference to a production with a [name]. */
  Parser ref(String name) {
    return _undefined.putIfAbsent(name, () {
      return failure('Uninitalized production: $name').wrapper();
    });
  }

  /** Defines a production with a [name] and a [parser]. */
  void def(String name, Parser parser) {
    if (_defined.containsKey(name)) {
      throw new StateError('Duplicate production: $name');
    } else {
      _defined[name] = parser;
    }
  }

  /** Redefinies an existing production with a [name] and a [function] producing a new parser. */
  void redef(String name, Parser function(Parser)) {
    if (!_defined.containsKey(name)) {
      throw new StateError('Undefined production: $name');
    } else {
      _defined[name] = function(_defined[name]);
    }
  }

  /** Attaches an action [function] to an existing production [name]. */
  void action(String name, dynamic function(Dynamic)) {
    redef(name, (parser) => parser.map(function));
  }

  /**
   * Returns a reference to a defined production named [name]. This method should
   * only be called for fully initialized instances.
   */
  Parser operator [](String name) => _defined[name];

}