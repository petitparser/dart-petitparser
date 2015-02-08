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
  for (var each in allParser(parser)) {
    mapping[each] = handler(each.copy());
  }
  var seen = new Set.from(mapping.values);
  var todo = new List.from(mapping.values);
  while (todo.isNotEmpty) {
    var parent = todo.removeLast();
    for (var child in parent.children) {
      if (mapping.containsKey(child)) {
        parent.replace(child, mapping[child]);
      } else if (!seen.contains(child)) {
        seen.add(child);
        todo.add(child);
      }
    }
  }
  return mapping[parser];
}
