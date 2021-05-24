import '../../parser.dart';
import '../core/parser.dart';
import 'iterable.dart';
import 'queries.dart';

/// Returns the first-set of [parser]. The first-set of a parser is the list
/// of terminal parsers that begin the parse derivable from that parser.
///
/// Note: This implementation is very inefficient when called on different
/// parser of the same connected parser graph, instead use [firstSets] to
/// calculate the first-sets for all parsers at once.
Set<Parser> firstSet(Parser parser) => firstSets(parser)[parser]!;

/// Returns a map of all parsers reachable from [root] as key and their
/// first-set as value. The first-set of a parser is the list of a terminal
/// parsers that begin the parse derivable from that parser.
Map<Parser, Set<Parser>> firstSets(Parser root) {
  final firstSets = <Parser, Set<Parser>>{};
  for (final parser in allParser(root)) {
    final firstSet = <Parser>{};
    if (isTerminal(parser)) {
      firstSet.add(parser);
    }
    if (isNullable(parser)) {
      firstSet.add(_nullableSentinel);
    }
    firstSets[parser] = firstSet;
  }
  var changed = true;
  while (changed) {
    changed = false;
    firstSets.forEach((parser, firstSet) {
      final length = firstSet.length;
      _firstSets(parser, firstSet, firstSets);
      changed |= length != firstSet.length;
    });
  }
  return firstSets;
}

/// Try to add additional elements from [parser] to the [firstSet], use the
/// incomplete [firstSets].
void _firstSets(
    Parser parser, Set<Parser> firstSet, Map<Parser, Set<Parser>> firstSets) {
  if (parser is SequenceParser || parser is TrimmingParser) {
    for (final child in parser.children) {
      var nullable = false;
      for (final first in firstSets[child]!) {
        if (isNullable(first)) {
          nullable = true;
        } else {
          firstSet.add(first);
        }
      }
      if (!nullable) {
        return;
      }
    }
    firstSet.add(_nullableSentinel);
  } else {
    for (final child in parser.children) {
      firstSet.addAll(firstSets[child]!);
    }
  }
}

/// A marker to propagate a nullable parser through
final _nullableSentinel = EpsilonParser(#nullableSentinel);
