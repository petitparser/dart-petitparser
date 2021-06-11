import '../core/parser.dart';
import '../parser/misc/epsilon.dart';
import 'internal/cycle_set.dart';
import 'internal/first_set.dart';
import 'internal/follow_set.dart';
import 'iterable.dart';

/// Helper to reflect on properties of a grammar.
class Analyzer {
  /// Constructs an analyzer on the parser graph starting at [root].
  Analyzer(this.root);

  /// The start parser of analysis.
  final Parser root;

  /// Returns a set of all parsers reachable from [root].
  Iterable<Parser> get parsers => _parsers;

  late final Set<Parser> _parsers = allParser(root).toSet();

  /// Returns `true` if [parser] is transitively nullable, that is it can
  /// successfully parse nothing.
  bool isNullable(Parser parser) => _firstSets[parser]!.contains(sentinel);

  /// Returns the first-set of [parser].
  ///
  /// The first-set of a parser is the set of terminal parsers which can appear
  /// as the first element of any chain of parsers derivable from [parser].
  /// Includes [sentinel], if the set is nullable.
  Iterable<Parser> firstSet(Parser parser) => _firstSets[parser]!;

  late final Map<Parser, Set<Parser>> _firstSets =
      computeFirstSets(parsers: _parsers, sentinel: sentinel);

  /// Returns the follow-set of a [parser].
  ///
  /// The follow-set of a parser is the list of terminal parsers that can
  /// appear immediately after [parser]. Includes [sentinel], if the parse can
  /// complete when starting at [root].
  Iterable<Parser> followSet(Parser parser) => _followSet[parser]!;

  late final Map<Parser, Set<Parser>> _followSet = computeFollowSets(
      root: root, parsers: _parsers, firstSets: _firstSets, sentinel: sentinel);

  /// Returns the cycle-set of a [parser].
  Iterable<Parser> cycleSet(Parser parser) => _cycleSet[parser]!;

  late final Map<Parser, List<Parser>> _cycleSet =
      computeCycleSets(parsers: _parsers, firstSets: _firstSets);

  /// Helper to do a global replace of [source] with [target].
  void replaceAll(Parser source, Parser target) {
    for (final parent in _parsers) {
      parent.replace(source, target);
    }
  }

  /// A unique parser used as a marker in [firstSet] and [followSet]
  /// computations.
  static final EpsilonParser sentinel = EpsilonParser<void>(null);
}
