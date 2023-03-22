import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'analyzer.dart';
import 'internal/optimize_rules.dart';

/// Function signature of a linter callback that is called whenever a linter
/// rule identifies an issue.
typedef ReplaceParser<R> = void Function(Parser<R> source, Parser<R> target);

/// Encapsulates a single optimization rule.
@immutable
abstract class OptimizeRule {
  /// Constructs a new optimization rule.
  const OptimizeRule();

  /// Executes this rule using a provided [analyzer] on a [parser].
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace);
}

// All default optimizer rules to be run.
const allOptimizerRules = [
  CharacterRepeater(),
  FlattenChoice(),
  RemoveDelegate(),
  RemoveDuplicate(),
];

/// Returns an optimized version of the parser.
@useResult
Parser<T> optimize<T>(Parser<T> parser, {List<OptimizeRule>? rules}) {
  final analyzer = Analyzer(parser);
  final selectedRules = rules ?? allOptimizerRules;
  final replacements = <Parser, Parser>{};
  for (final parser in analyzer.parsers) {
    parser.captureResultGeneric(<R>(parser) {
      for (final rule in selectedRules) {
        rule.run<R>(analyzer, parser, (a, b) => replacements[a] = b);
      }
    });
  }
  if (replacements.isNotEmpty) {
    for (final parser in analyzer.parsers) {
      for (final replacement in replacements.entries) {
        parser.replace(replacement.key, replacement.value);
      }
    }
    return replacements[parser] as Parser<T>? ?? parser;
  }
  return parser;
}

/// Collapses all duplicate parsers in-place.
@useResult
@Deprecated('Use `optimize(parser, rules: const [RemoveDuplicate()])` instead')
Parser<T> removeDuplicates<T>(Parser<T> parser) =>
    optimize(parser, rules: const [RemoveDuplicate()]);
