import '../core/parser.dart';
import 'iterable.dart';

/// A function transforming one parser to another one.
typedef TransformationHandler = Parser Function(Parser parser);

/// Transforms all parsers reachable from [parser] with the given [handler].
/// The identity function returns a copy of the the incoming parser.
///
/// The implementation first creates a copy of each parser reachable in the
/// input grammar; then the resulting grammar is traversed until all references
/// to old parsers are replaced with the transformed ones.
Parser transformParser(Parser parser, TransformationHandler handler) {
  final mapping = Map<Parser, Parser>.identity();
  for (final each in allParser(parser)) {
    mapping[each] = handler(each.copy());
  }
  final todo = [...mapping.values];
  final seen = {...mapping.values};
  while (todo.isNotEmpty) {
    final parent = todo.removeLast();
    for (final child in parent.children) {
      if (mapping.containsKey(child)) {
        parent.replace(child, mapping[child]!);
      } else if (!seen.contains(child)) {
        seen.add(child);
        todo.add(child);
      }
    }
  }
  return mapping[parser]!;
}
