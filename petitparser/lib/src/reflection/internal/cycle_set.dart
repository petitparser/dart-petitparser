import '../../core/parser.dart';
import 'utilities.dart';

Set<Parser> computeCycleSet({
  required Parser root,
  required Map<Parser, Set<Parser>> firstSets,
}) {
  final result = <Parser>{};
  expandCycleSet(parser: root, firstSets: firstSets, stack: [], result: result);
  return result;
}

void expandCycleSet({
  required Parser parser,
  required Map<Parser, Set<Parser>> firstSets,
  required List<Parser> stack,
  required Set<Parser> result,
}) {
  if (isTerminal(parser)) {
    return;
  }
  final index = stack.lastIndexOf(parser);
  if (index >= 0) {
    result.addAll(stack.sublist(index));
    return;
  }
  stack.add(parser);
  final children = [];
  if (isSequence(parser)) {
    for (final child in parser.children) {
      children.add(child);
      if (!firstSets[child]!.any(isNullable)) {
        break;
      }
    }
  } else {
    children.addAll(parser.children);
  }
  for (final child in children) {
    expandCycleSet(
        parser: child, firstSets: firstSets, stack: stack, result: result);
  }
  stack.removeLast();
}
