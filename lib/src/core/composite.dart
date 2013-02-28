// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Helper to compose complex grammars from various primitive parsers.
 *
 * To create a new composite grammar subclass [CompositeParser]. Override
 * the method [initialize] and for every production call [def] giving the
 * production a name. The start production must be named 'start'. To refer
 * to other produtions (forward and backward) use [ref].
 *
 * You might want to create future subclasses of your composite grammar
 * to redefine the grammar or attach custom actions. In such a subclass
 * override the method [initialize] again and call super. Then use
 * [redef] to redefine an existing production, and [action] to attach an
 * action to an existing production.
 */
abstract class CompositeParser extends _SetableParser {

  final Map<String, Parser> _defined;
  final Map<String, SetableParser> _undefined;

  CompositeParser()
      : super(failure('Uninitalized production: start')),
        _defined = new Map(),
        _undefined = new Map() {
    initialize();
    _delegate = ref('start');
    _undefined.forEach((name, parser) {
      if (!_defined.containsKey(name)) {
        throw new StateError('Undefined production: $name');
      }
      parser.set(_defined[name]);
    });
    set(Transformations.removeSetables(ref('start')));
  }

  /**
   * Initializes the composite grammar.
   */
  void initialize();

  /**
   * Defines a production with a [name] and a [parser]. Only call this method
   * from [initialize].
   *
   * The following example defines a list production that consumes
   * several elements separated by a comma.
   *
   *     def('list', ref('element').separatedBy(char(',')));
   */
  void def(String name, Parser parser) {
    if (_defined.containsKey(name)) {
      throw new StateError('Duplicate production: $name');
    } else {
      _defined[name] = parser;
    }
  }

  /**
   * Returns a reference to a production with a [name]. Only call this method
   * from [initialize].
   *
   * At the point of calling [ref] the production does not necessaryily have
   * to be defined yet. The constructor of the class makes sure to replace
   * and optimize references away before the grammar is run.
   */
  Parser ref(String name) {
    return _undefined.putIfAbsent(name, () {
      return failure('Uninitalized production: $name').setable();
    });
  }

  /**
   * Redefinies an existing production with a [name] and a [function]
   * producing a new parser. The code raises a [StateError] if [name]
   * is an undefined production. Only call this method from [initialize].
   *
   * The following example redefines the previously defined list production
   * by making it optional:
   *
   *     redef('list', (parser) => parser.optional());
   */
  void redef(String name, Parser function(Parser)) {
    if (!_defined.containsKey(name)) {
      throw new StateError('Undefined production: $name');
    } else {
      _defined[name] = function(_defined[name]);
    }
  }

  /**
   * Attaches an action [function] to an existing production [name]. The code
   * raises a [StateError] if [name] is an undefined production. Only call this
   * method from [initialize].
   *
   * The following example attaches an action returning the size of list of
   * the previously defined list production:
   *
   *     action('list', (list) => list.length);
   *
   */
  void action(String name, dynamic function(Dynamic)) {
    redef(name, (parser) => parser.map(function));
  }

  /**
   * Returns a reference to the production with the given [name]. This method
   * should only be called for fully initialized instances.
   */
  Parser operator [](String name) => _defined[name];

}
