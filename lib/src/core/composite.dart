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

  bool _completed = false;
  final Map<String, Parser> _defined = new Map();
  final Map<String, SetableParser> _undefined = new Map();

  CompositeParser() : super(failure('Uninitalized production: start')) {
    initialize();
    _complete();
  }

  /**
   * Initializes the composite grammar.
   */
  void initialize();

  /**
   * Internal method to complete the grammar.
   */
  void _complete() {
    _delegate = ref('start');
    _undefined.forEach((name, parser) {
      if (!_defined.containsKey(name)) {
        throw new StateError('Undefined production: $name');
      }
      parser.set(_defined[name]);
    });
    set(Transformations.removeSetables(ref('start')));
    _undefined.clear();
    _completed = true;
  }

  /**
   * Returns a reference to a production with a [name].
   *
   * This method works during initialization and after completion of the
   * initialization. During the initialization it returns delegate parsers
   * that are eventually replaced by the real parsers. Afterwards it
   * returns the defined parser (mostly useful for testing).
   */
  Parser ref(String name) {
    if (_completed) {
      if (_defined.containsKey(name)) {
        return _defined[name];
      } else {
        throw new StateError('Undefined production: $name');
      }
    } else {
      return _undefined.putIfAbsent(name, () {
        return failure('Uninitalized production: $name').setable();
      });
    }
  }

  /**
   * Convenience operator returning a reference to a production with
   * a [name]. See [CompositeParser#ref] for details.
   */
  Parser operator [](String name) => ref(name);

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
    if (_completed) {
      throw new StateError('Completed parsers cannot be changed');
    } else if (_defined.containsKey(name)) {
      throw new StateError('Duplicate production: $name');
    } else {
      _defined[name] = parser;
    }
  }

  /**
   * Redefinies an existing production with a [name] and a [replacement]
   * parser or function producing a new parser. The code raises a [StateError]
   * if [name] is an undefined production. Only call this method from
   * [initialize].
   *
   * The following example redefines the previously defined list production
   * by making it optional:
   *
   *     redef('list', (parser) => parser.optional());
   */
  void redef(String name, dynamic replacement) {
    if (_completed) {
      throw new StateError('Completed parsers cannot be changed');
    } else if (!_defined.containsKey(name)) {
      throw new StateError('Undefined production: $name');
    } else {
      _defined[name] = replacement is Parser ? replacement
          : replacement(_defined[name]);
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

}
