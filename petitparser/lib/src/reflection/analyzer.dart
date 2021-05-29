import '../core/parser.dart';
import '../parser/misc/epsilon.dart';
import 'internal/cycle_set.dart';
import 'internal/first_set.dart';
import 'internal/follow_set.dart';
import 'iterable.dart';

/// Helper to efficiently analyze properties of a grammar.
class Analyzer {
  Analyzer(this.root);

  /// The root of this parser.
  final Parser root;

  /// Returns a set of all parsers reachable from [root].
  Iterable<Parser> get parsers => _parsers;

  late final List<Parser> _parsers = allParser(root).toList(growable: false);

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
  /// end here.
  Iterable<Parser> followSet(Parser parser) => _followSet[parser]!;

  late final Map<Parser, Set<Parser>> _followSet = computeFollowSets(
      root: root, parsers: _parsers, firstSets: _firstSets, sentinel: sentinel);

  /// Returns the cycle-set of a [parser].
  Iterable<Parser> cycleSet(Parser parser) => _cycleSet[parser]!;

  late final Map<Parser, List<Parser>> _cycleSet =
      computeCycleSets(parsers: _parsers, firstSets: _firstSets);

  /// A marker to identify
  static final EpsilonParser sentinel = EpsilonParser<void>(null);
}
