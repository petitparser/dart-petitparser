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
 * Consider the following example to parse a list of numbers:
 *
 *     class NumberListGrammar extends CompositeParser {
 *       void initialize() {
 *         def('element', digit().plus().flatten());
 *         def('list', ref('element').separatedBy(char(',')));
 *         def('start', ref('list').end());
 *       }
 *     }
 *
 * You might want to create future subclasses of your composite grammar
 * to redefine the grammar or attach custom actions. In such a subclass
 * override the method [initialize] again and call super. Then use
 * [redef] to redefine an existing production, and [action] to attach an
 * action to an existing production.
 *
 * Consider the following example that attaches a production action and
 * converts the digits to actual numbers:
 *
 *     class NumberListParser extends NumberListGrammar {
 *       void initialize() {
 *         action('element', (value) => int.parse(value));
 *       }
 *     }
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
        throw new UndefinedProductionError(name);
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
        throw new UndefinedProductionError(name);
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
      throw new CompletedParserError();
    } else if (_defined.containsKey(name)) {
      throw new RedefinedProductionError(name);
    } else {
      _defined[name] = parser;
    }
  }

  /**
   * Redefinies an existing production with a [name] and a [replacement]
   * parser or function producing a new parser. The code raises an
   * [UndefinedProductionError] if [name] is an undefined production. Only call
   * this method from [initialize].
   *
   * The following example redefines the previously defined list production
   * by making it optional:
   *
   *     redef('list', (parser) => parser.optional());
   */
  void redef(String name, dynamic replacement) {
    if (_completed) {
      throw new CompletedParserError();
    } else if (!_defined.containsKey(name)) {
      throw new UndefinedProductionError(name);
    } else {
      _defined[name] = replacement is Parser ? replacement
          : replacement(_defined[name]);
    }
  }

  /**
   * Attaches an action [function] to an existing production [name]. The code
   * raises an [UndefinedProductionError] if [name] is an undefined production.
   * Only call this method from [initialize].
   *
   * The following example attaches an action returning the size of list of
   * the previously defined list production:
   *
   *     action('list', (list) => list.length);
   */
  void action(String name, dynamic function(Dynamic)) {
    redef(name, (parser) => parser.map(function));
  }

}

/**
 * Experimental helper to compose complex grammars from various primitive
 * parsers using variable references.
 *
 * The difference of this implementation and [CompositeParser] is that
 * subclasses can define and refer to productions using variables. The
 * accessors themselves are not actually implement anywhere, but their
 * behavior is defined in [noSuchMethod] and mapped a collection using
 * the behavior defined in the superclass.
 *
 * Consider the following example to parse a list of numbers:
 *
 *     class NumberListGrammar2 extends CompositeParser2 {
 *       void initialize() {
 *         element = digit().plus().flatten();
 *         list = element.separatedBy(char(',')));
 *         start = list.end();
 *       }
 *     }
 *
 * Production actions can be attached in subclasses by calling the production,
 * as in the following example:
 *
 *     class NumberListParser2 extends NumberListGrammar2 {
 *       void initialize() {
 *         action('element', (value) => int.parse(value));
 *       }
 *     }
 *
 * Creavats: The Dart editor currently shows an abundance of spurious warnings,
 * as all productions are undefined from the perspective of the analyzer. Pay
 * attention with production names that conflict with methods defined in the
 * superclasses. The generated JavaScript code is noticably bigger, due to the
 * use of [noSuchMethod]. The resulting parsers are identical, after parser
 * construction there is no speed difference for the actual parsing.
 */
class CompositeParser2 extends CompositeParser {

  dynamic noSuchMethod(InvocationMirror mirror) {
    if (!mirror.memberName.startsWith('_')) {
      if (mirror.isGetter) {
        return ref(mirror.memberName);
      } else if (!_completed) {
        if (mirror.isSetter) {
          return def(mirror.memberName.substring(0, mirror.memberName.length - 1),
              mirror.positionalArguments.first);
        } else if (mirror.isMethod && mirror.positionalArguments.length == 1) {
          var argument = mirror.positionalArguments.first;
          return argument is Parser
              ? redef(mirror.memberName, argument)
              : action(mirror.memberName, argument);
        }
      }
    }
    return super.noSuchMethod(mirror);
  }

}

/**
 * Error raised when somebody tries to modify a [CompositeParser] outside
 * the [CompositeParser#initialize] method.
 */
class CompletedParserError implements Error {
  CompletedParserError();
  String toString() => 'Completed parser error';
}

/**
 * Error raised when an undefined production is accessed.
 */
class UndefinedProductionError implements Error {
  final String name;
  UndefinedProductionError(this.name);
  String toString() => 'Undefined production: $name';
}

/**
 * Error raised when a production is accidentally redefined.
 */
class RedefinedProductionError implements Error {
  final String name;
  RedefinedProductionError(this.name);
  String toString() => 'Redefined production: $name';
}