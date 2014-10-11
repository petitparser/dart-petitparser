part of core;

/**
 * Builder to conveniently build complex grammars from productions.
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
abstract class ParserBuilder {

  /**
   * The starting production of this parser.
   */
  Parser start();

  /**
   * Wraps a method referene into a parser that can be passed around and that
   * will be resolved at a later point.
   */
  Parser ref(Function reference, [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]) {
    var arguments = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]
        .takeWhile((each) => each != null)
        .toList(growable: false);
    return new _Reference(reference, arguments);
  }


  /**
   * Internal helper to expand the complete parser graph.
   */
  Parser build([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]) {
    return _resolve(ref(start, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8));
  }

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

  /**
   * Resolves the reference to an actual parser.
   */
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

