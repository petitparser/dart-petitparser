part of reflection;

/**
 * A function transforming one parser to another one.
 */
typedef Parser TransformationHandler(Parser parser);

/**
 * Transforms all parsers reachable from [parser] with the given [handler].
 * The identity function returns a copy of the the incoming parser.
 *
 * The implementation first creates a copy of each parser reachable in the
 * input grammar; then the resulting grammar is traversed until all references
 * to old parsers are replaced with the transformed ones.
 */
Parser transformParser(Parser parser, TransformationHandler handler) {
  var mapping = new Map.identity();
  for (var parser in allParser(parser)) {
    mapping[parser] = handler(parser.copy());
  }
  var seen = new Set.from(mapping.values);
  var todo = new List.from(mapping.values);
  while (todo.isNotEmpty) {
    var parent = todo.removeLast();
    for (var source in parent.children) {
      if (mapping.containsKey(source)) {
        parent.replace(source, mapping[source]);
      } else if (!seen.contains(source)) {
        seen.add(source);
        todo.add(source);
      }
    }
  }
  return mapping[parser];
}