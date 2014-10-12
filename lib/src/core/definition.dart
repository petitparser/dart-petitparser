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
    return new _Reference(function, arguments);
  }

  /**
   * Builds a composite parser from this definition.
   *
   * The optional [start] reference specifies a different starting production into
   * the grammar. The optional [arguments] list parametrizes the called production.
   */
  Parser build({Function start: null, List arguments: const []}) {
    return _resolve(new _Reference(start != null ? start : this.start, arguments));
  }

  /**
   * Internal helper to resolve a production reference of this grammar definiton.
   */
  Parser _resolve(_Reference reference) {
    var mapping = new Map.fromIterables([reference], [reference.resolve()]);
    var seen = new Set.from(mapping.values);
    var todo = new List.from(mapping.values);
    while (todo.isNotEmpty) {
      var parent = todo.removeLast();
      for (var child in parent.children) {
        if (child is _Reference) {
          parent.replace(child, mapping.putIfAbsent(child, () {
            var replacement = child.resolve();
            seen.add(replacement);
            todo.add(replacement);
            return replacement;
          }));
        } else if (!seen.contains(child)) {
          seen.add(child);
          todo.add(child);
        }
      }
    }
    return mapping[reference];
  }

}

class _Reference extends Parser implements Object {

  final Function function;
  final List arguments;

  _Reference(this.function, this.arguments);

  Parser resolve() => Function.apply(function, arguments);

  @override
  bool operator ==(other) {
    if (other is! _Reference ||
        other.function != function ||
        other.arguments.length != arguments.length) {
      return false;
    }
    for (var i = 0; i < other.arguments.length; i++) {
      if (other.arguments[i] != arguments[i]) {
        return false;
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

