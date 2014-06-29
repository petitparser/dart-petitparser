part of reflection;

/**
 * A function transforming one parser to another one.
 */
typedef Parser TransformationHandler(Parser parser);

/**
 * Transforms all parsers reachable from [root] with the given [function].
 * The identity function returns a copy of the the incoming parser.
 *
 * The implementation first creates a copy of each parser reachable in the
 * input grammar; then the resulting grammar is iteratively transfered and
 * all old parsers are replaced with the transformed ones until we end up
 * with a completely new grammar.
 */
Parser transformParser(Parser root, TransformationHandler handler) {
  var mapping = new Map();
  allParser(root).forEach((parser) {
    mapping[parser] = handler(parser.copy());
  });
  while (true) {
    var changed = false;
    allParser(mapping[root]).forEach((parser) {
      parser.children.forEach((source) {
        if (mapping.containsKey(source)) {
          parser.replace(source, mapping[source]);
          changed = true;
        }
      });
    });
    if (!changed) {
      return mapping[root];
    }
  }
}