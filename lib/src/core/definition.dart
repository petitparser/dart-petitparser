part of petitparser;

/**
 * Helper to conveniently define and build complex grammars from productions.
 *
 * To create a new grammar definition subclass [ParserDefinition]. For every
 * production create a method returning the parser defining it. The method
 * called [start] is supposed to return the start production of the grammar.
 *
 * Consider the following example to parse a list of numbers:
 *
 *     class NumberListGrammar extends ParserBuilder {
 *       start() => ref(list).end();
 *       list() => ref(element).separatedBy(char(','), includeSeparators: false);
 *       element() => digit().plus().flatten();
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
 *
 * Consider the following example to parse a list of numbers:
 *
 *     class NumberListGrammar extends ParserBuilder {
 *       start() => ref(list).end();
 *       list() => ref(element).separatedBy(char(','), includeSeparators: false);
 *       element() => digit().plus().flatten();
 *     }
 *
 * Note that every production is a method. Productions refer each other thorugh
 * method references passed to the [ref] helper.
 *
 * Production actions can be attached in subclasses by simply overriding the
 * method of the superclass:
 *
 *     class NumberListParser extends NumberListGrammar {
 *       element() => super.element().map((value) => int.parse(value));
 *     }
 *
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
  bool operator ==(other) => other is _Reference
      && other.function == function
      && other.arguments == arguments;

  @override
  int get hashCode => function.hashCode ^ arguments.hashCode;

  @override
  Parser copy() => throw new UnsupportedError('References cannot be copied.');

  @override
  Result parseOn(Context context) => throw new UnsupportedError('References cannot be parsed.');

}

