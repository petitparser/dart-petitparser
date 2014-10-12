part of petitparser;

/**
 * Helper to conveniently define and build complex, recursive grammars using
 * plain Dart code.
 *
 * To create a new grammar definition subclass [GrammarDefinition]. For every
 * production create a new method returning the primitive parser defining it.
 * The method called [start] is supposed to return the start production of the
 * grammar. To refer to a proudction defined in the same definition use [ref]
 * with the function reference as the first argument.
 *
 * Consider the following example to parse a list of numbers:
 *
 *     class ListGrammarDefinition extends GrammarDefinition {
 *       start()   => ref(list).end();
 *       list()    => ref(element) & char(',') & ref(list)
 *                  | ref(element);
 *       element() => digit().plus().flatten();
 *     }
 *
 * Since this is plain Dart code, common refactorings such as renaming a production
 * updates all references correctly. Also code navigation and code completion
 * works as expected.
 *
 * To attach custom production actions you might want to further subclass your
 * grammar definition and override overriding the necessary productions defined
 * in the superclass:
 *
 *     class ListParserDefinition extends ListGrammarDefinition {
 *       element() => super.element().map((value) => int.parse(value));
 *     }
 *
 * Note that productions can be parametrized. Define such productions with positional
 * arguments and reference to multiple instances by passing the arguments to [ref].
 *
 * Consider extending the above grammar with a parametrized token production:
 *
 *     class TokenizedListGrammarDefinition extends GrammarDefinition {
 *       start()   => ref(list).end();
 *       list()    => ref(element) & ref(token, char(',')) & ref(list)
 *                  | ref(element);
 *       element() => ref(token, digit().plus());
 *       token(p)  => p.token().trim();
 *     }
  */
abstract class GrammarDefinition {

  /**
   * The starting production of this definition.
   */
  Parser start();

  /**
   * Returns a parser reference to a production defined by a [function].
   *
   * The optional arguments parametrize the called production.
   */
  Parser ref(Function function, [arg1, arg2, arg3, arg4, arg5, arg6]) {
    var arguments = [arg1, arg2, arg3, arg4, arg5, arg6]
        .takeWhile((each) => each != null)
        .toList(growable: false);
    return new _ReferenceParser(function, arguments);
  }

  /**
   * Builds a composite parser from this definition.
   *
   * The optional [start] reference specifies a different starting production into
   * the grammar. The optional [arguments] list parametrizes the called production.
   */
  Parser build({Function start: null, List arguments: const []}) {
    return _resolve(new _ReferenceParser(start != null ? start : this.start, arguments));
  }

  /**
   * Internal helper to resolve all production references reachable from the
   * provided [reference].
   */
  Parser _resolve(_ReferenceParser reference) {
    Map<_ReferenceParser, Parser> mapping = new Map();
    Parser _dereference(_ReferenceParser reference) {
      var resolved = mapping[reference];
      if (resolved == null) {
        resolved = reference.resolve();
        if (resolved is _ReferenceParser) {
          if (resolved == reference) {
            throw new StateError('Production is referring to itself: ${reference.function}');
          } else {
            resolved = _resolve(resolved);
          }
        }
        mapping[reference] = resolved;
      }
      return resolved;
    }
    Parser result = _dereference(reference);
    List<Parser> todo = new List.from([result]);
    Set<Parser> seen = new Set.from(todo);
    while (todo.isNotEmpty) {
      var parent = todo.removeLast();
      for (var child in parent.children) {
        if (child is _ReferenceParser) {
          var resolved = _dereference(child);
          parent.replace(child, resolved);
          child = resolved;
        }
        if (!seen.contains(child)) {
          todo.add(child);
          seen.add(child);
        }
      }
    }
    return result;
  }

}

class GrammarParser extends DelegateParser {
  GrammarParser(GrammarDefinition definition) : super(definition.build());
}

class _ReferenceParser extends Parser {

  final Function function;
  final List arguments;

  _ReferenceParser(this.function, this.arguments);

  Parser resolve() => Function.apply(function, arguments);

  @override
  bool operator ==(other) {
    if (other is! _ReferenceParser ||
        other.function != function ||
        other.arguments.length != arguments.length) {
      return false;
    }
    for (var i = 0; i < arguments.length; i++) {
      if (arguments[i] is Parser) {
        // for parsers do a deep equality check
        if (!arguments[i].equals(other.arguments[i])) {
          return false;
        }
      } else {
        // for everything else just do standard equality
        if (arguments[i] != other.arguments[i]) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  int get hashCode => function.hashCode;

  @override
  Parser copy() => throw new UnsupportedError('References cannot be copied.');

  @override
  Result parseOn(Context context) => throw new UnsupportedError('References cannot be parsed.');

}

